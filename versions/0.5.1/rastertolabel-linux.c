#include <cups/cups.h>
#include <cups/raster.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(int argc, char **argv)
{
    int num_options = 0;
    cups_option_t *options = NULL;

    if (argc >= 6)
        num_options = cupsParseOptions(argv[5], 0, &options);

    int darkness = 2;
    const char *darkness_opt = cupsGetOption("Darkness", num_options, options);

    if (darkness_opt && strcmp(darkness_opt, "Default") != 0) {
        int value = atoi(darkness_opt);
        if (value >= 0 && value <= 4)
            darkness = value;
    }

    int align = 1;
    const char *align_opt = cupsGetOption("MediaAlign", num_options, options);
    int feed_offset = 0;
    const char *feed_opt = cupsGetOption("FeedOffset", num_options, options);
    if (feed_opt && strcmp(feed_opt, "Default") != 0) {
        feed_offset = atoi(feed_opt);
        if (feed_offset < 0)
            feed_offset = 0;
        else if (feed_offset > 10)
            feed_offset = 10;
    }
    int feed_dots = (int)((feed_offset * 203.0 / 25.4) + 0.5);

    if (align_opt) {
        if (strcmp(align_opt, "Left") == 0)
            align = 0;
        else if (strcmp(align_opt, "Right") == 0)
            align = 2;
    }

    int media_mode = 0;
    const char *media_opt =
        cupsGetOption("zeMediaTracking", num_options, options);

    if (media_opt && strcmp(media_opt, "Perforated") == 0)
        media_mode = 3;

    int media_command = (media_mode == 3) ? 3 : 1;

    if (argc != 6 && argc != 7 && argc != 8) {
        fprintf(stderr,
                "usage: %s <density> <width> <height> <copies> <device> <raster> <output>\\n",
                argv[0]);
        return 2;
    }

    const char *raster_path = (argc >= 7) ? argv[6] : NULL;
    const char *out_path = (argc == 8) ? argv[7] : NULL;

    FILE *rf = raster_path ? fopen(raster_path, "rb") : stdin;
    if (!rf) {
        perror("raster input");
        return 1;
    }

    cups_raster_t *ras = cupsRasterOpen(fileno(rf), CUPS_RASTER_READ);
    if (!ras) {
        fprintf(stderr, "cupsRasterOpen failed\\n");
        if (rf != stdin)
            fclose(rf);
        return 1;
    }

    /*
     * Open output once for the whole job.
     * Important for multi-page jobs.
     */
    FILE *of = (argc == 8) ? fopen(out_path, "wb") : stdout;
    if (!of) {
        perror(out_path ? out_path : "stdout");
        cupsRasterClose(ras);
        if (rf != stdin)
            fclose(rf);
        return 1;
    }

    cups_page_header2_t h;
    memset(&h, 0, sizeof(h));

    /*
     * One iteration = one CUPS raster page.
     */
    while (cupsRasterReadHeader2(ras, &h)) {

        fprintf(stderr,
                "page: %u x %u, bpc=%u bpp=%u bpl=%u colorspace=%u\\n",
                h.cupsWidth, h.cupsHeight,
                h.cupsBitsPerColor,
                h.cupsBitsPerPixel,
                h.cupsBytesPerLine,
                h.cupsColorSpace);

        const unsigned width = h.cupsWidth;
        const unsigned height = h.cupsHeight;
        const unsigned out_bpl = (width + 7) / 8;

        unsigned char *line = malloc(h.cupsBytesPerLine);
        unsigned char *bitmap = malloc((size_t)out_bpl * height);

        if (!line || !bitmap) {
            fprintf(stderr, "out of memory\\n");
            free(line);
            free(bitmap);

            cupsRasterClose(ras);
            if (rf != stdin)
                fclose(rf);

            if (of != stdout)
                fclose(of);

            return 1;
        }

        memset(bitmap, 0xff, (size_t)out_bpl * height);

        for (unsigned y = 0; y < height; ++y) {

            if (cupsRasterReadPixels(ras, line, h.cupsBytesPerLine)
                    != h.cupsBytesPerLine) {

                fprintf(stderr,
                        "short raster read at line %u\\n", y);

                free(line);
                free(bitmap);

                cupsRasterClose(ras);
                if (rf != stdin)
                    fclose(rf);

                if (of != stdout)
                    fclose(of);

                return 1;
            }

            for (unsigned x = 0; x < width; ++x) {

                unsigned bit = 0;

                if (h.cupsBitsPerPixel == 1) {

                    bit = (line[x >> 3]
                           >> (7 - (x & 7))) & 1;

                } else if (h.cupsBitsPerPixel == 24) {

                    unsigned byte = x * 3;
                    unsigned r = line[byte];
                    unsigned g = line[byte + 1];
                    unsigned b = line[byte + 2];

                    unsigned gray =
                        (299 * r + 587 * g + 114 * b) / 1000;

                    bit = (gray >= 128);
                }

                /*
                 * A10a:
                 * sent bit 1 = black
                 * sent bit 0 = white
                 *
                 * bitmap starts at 0xff, therefore clear white pixels.
                 */
                if (bit) {
                    bitmap[(size_t)y * out_bpl + (x >> 3)]
                        &= (unsigned char)~(1u << (7 - (x & 7)));
                }
            }

            /*
             * Unused padding bits in the last byte must be white.
             */
            if (width & 7) {
                bitmap[(size_t)y * out_bpl + out_bpl - 1]
                    &= (unsigned char)(0xff << (8 - (width & 7)));
            }
        }


        /*
         * PeriPage uncompressed raster command:
         *
         * 1d 76 30 00
         * widthBytes LE16
         * height     LE16
         */
        unsigned char hdr[8];

        hdr[0] = 0x1d;
        hdr[1] = 0x76;
        hdr[2] = 0x30;
        hdr[3] = 0x00;

        hdr[4] = (unsigned char)(out_bpl & 0xff);
        hdr[5] = (unsigned char)((out_bpl >> 8) & 0xff);

        hdr[6] = (unsigned char)(height & 0xff);
        hdr[7] = (unsigned char)((height >> 8) & 0xff);


        unsigned char init[] = {
            0x10, 0xff, 0xfe, 0x01,
            0x10,0xff,0x10,0x03,(unsigned char)media_command,
            0x1b, 0x40, 0x00,
            0x10, 0xff, 0x10, 0x00, (unsigned char)darkness,
            0x1b, 0x61, (unsigned char)align
        };

        fwrite(init, 1, sizeof(init), of);

        fwrite(hdr, 1, sizeof(hdr), of);

        fwrite(bitmap, 1,
               (size_t)out_bpl * height, of);
        if (feed_dots > 0) {
            int remaining = feed_dots;

            while (remaining > 255) {
                unsigned char feed[] = { 0x1b, 0x4a, 0xff };
                fwrite(feed, 1, sizeof(feed), of);
                remaining -= 255;
            }

            if (remaining > 0) {
                unsigned char feed[] = { 0x1b, 0x4a, (unsigned char)remaining };
                fwrite(feed, 1, sizeof(feed), of);
            }
        }

        if (media_mode == 3) {
            unsigned char media_end[] = { 0x1d, 0x0c };
            fwrite(media_end, 1, sizeof(media_end), of);
        } else {
            unsigned char media_end[] = { 0x10, 0x50 };
            fwrite(media_end, 1, sizeof(media_end), of);
        }

        unsigned char end_print[] = { 0x10, 0xff, 0xfe, 0x45 };
        fwrite(end_print, 1, sizeof(end_print), of);


        /*
         * Page finished.
         */
        free(bitmap);
        free(line);
    }


    /*
     * Whole raster job finished.
     */
    cupsRasterClose(ras);

    if (rf != stdin)
        fclose(rf);

    if (of != stdout)
        fclose(of);
    else
        fflush(of);


    fprintf(stderr,
            "wrote uncompressed raster to %s\n",
            out_path ? out_path : "stdout");

    cupsFreeOptions(num_options, options);
    return 0;
}