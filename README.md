# Voilá Mosaic #

A pair of scripts that take a directory of images and a master image and -- in a 2-step process -- assemble the images into a black-and-white mosaic of the master image.

Uses the RMagick gem, which is, in turn dependent on the ImageMagick library.

## INSTRUCTIONS ##

1. Put the master image at `mosaic/master_image.jpg`
2. Put the tiling images in `sources/`
3. Run `ruby scripts/normalize.rb` to resize and grayscale the source images
4. Run `ruby scripts/mosaic.rb`

Voilá!