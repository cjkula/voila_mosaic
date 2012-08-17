# Voilá Mosaic

A pair of scripts that take a directory of images and a master image and -- in a 2-step process -- assemble the images into a black-and-white mosaic of the master image.

Uses the RMagick gem, which is, in turn dependent on the ImageMagick library.

## INSTRUCTIONS

1. Put the master image at `mosaic/master_image.jpg`
2. Put the tiling images in `sources/`
3. Run `ruby scripts/normalize.rb` to resize and grayscale the source images
4. Run `ruby scripts/mosaic.rb`

Voilá!

## Helpful hints

* This utility will *not* duplicate source images in the result. Every tile will come from a different source. If there are not enough tile images, you will get whitespace. (This is a feature, not a bug.)
* The delicate dance is between contrast in the big image being assembled, and keeping individual tiles from looking over- or underexposed. This is all about massaging the master image: this utility is not going to make any judgements here. It's between you and Photoshop.