require 'RMagick'
include Magick

PROJECT_DIR = File.join(File.dirname(__FILE__), '..')  # up a level

# the source for the big images made up by the tiles
MASTER_IMAGE = File.join(PROJECT_DIR, 'mosaic/master_image.jpg')

# directory for the images for the tiles
# these should be pre-sized and scaled with the 'normalize.rb' script
SOURCE_FILE_DIR = File.join(PROJECT_DIR, 'normalized')

# destination directory and file name
DEST_FILE_DIR = File.join(PROJECT_DIR, 'mosaic')
DEST_FILE_NAME = 'mosaic.jpg'

# pixels across
NUM_COLUMNS = 38

# pixel size of the tile images
# this is used to lay out the tiles and to compensate for the non-square aspect ratio
# should be the same dimensions used in 'normalize.rb'
THUMB_WIDTH = 120
THUMB_HEIGHT = 150

master = (Image.read MASTER_IMAGE)[0]
original_aspect_ratio = master.columns.to_f / master.rows.to_f
thumb_aspect_ratio = THUMB_WIDTH.to_f / THUMB_HEIGHT.to_f
width = NUM_COLUMNS
# calculate output image rows compensating for aspect ratio of tile images
height = (NUM_COLUMNS * thumb_aspect_ratio / original_aspect_ratio).to_i

# scale the master image to the specified X-by-Y size
resized = master.scale(width, height)

# make a list of pixels in the resized pic with its color
# 'pixels' is an array of hashes, one hash for each pixel
pixels = []
for col in 0..width-1
  for row in 0..height-1
    pixels << { # pixel hash constructor 
        x: col,
        y: row,
        color: resized.pixel_color(col, row).red.to_i # the images are assumed to be greyscale
    }                                                 # so the red component is as good as any
  end
end

# sort the pixel list by color
pixels.sort!{ |a,b| a[:color] <=> b[:color] }

# get the thumbnails
Dir.chdir SOURCE_FILE_DIR
files = Dir.entries(SOURCE_FILE_DIR)          # all files in the source directory
           .select{ |f| !f.match /^\./}       # ...except hidden files
           .select{ |f| !File.directory?(f) } # ...and directories
source_images = ImageList.new *files

# get the average color of each and store it in the object
source_images.each do |image|
  one_by_one = image.scale(1,1)                                 # scale to 1x1
  image[:average_color] = one_by_one.pixel_color(0,0).red.to_s  # and get the red value (as good as any)
end

# sort the images by color -- dark to light
source_images.sort! { |a,b| a[:average_color].to_i <=> b[:average_color].to_i }

## At this point we have two parallel lists: the master image pixels sorted dark to light
## and the tile images sorted dark to light. The images are going to get assigned, directly
## across, to the corresponding pixel. We will, however, adjust the level of each image to
## match the master pixel level below.

adjusted_images = ImageList.new # new image list for the adjusted images

# got through the sorted list of source images
source_images.each_with_index do |image, index|
  
  pixel = pixels[index] # corresponding pixel in the parallel sorted list
  break unless pixel    # stop when we run out of pixels to tile
  col = pixel[:x]
  row = pixel[:y]
  
  # now the level adjustment
  # current_avg = image[:average_color].to_f  # what we got
  desired_avg = pixel[:color].to_f          # what we want
  desired_avg = 100.0 if desired_avg < 100  # less than 100 is absurd if it's still an image
  adjusted_image = image.clone              # clone for the new list
  
  # contrast adjustments for the extremes
  if desired_avg < 10000  # extra constrast on the dark side
    adjusted_image = adjusted_image.contrast(true)
  elsif desired_avg > 25000 # less contrast on the light side
    adjusted_image = adjusted_image.contrast(false).contrast(false).contrast(false)
  elsif desired_avg > 22000
    adjusted_image = adjusted_image.contrast(false).contrast(false)
  end
  
  # adjust the level
  adjusted_image = adjusted_image.modulate(desired_avg/32768)
  
  # assign the image's place in the mosaic
  adjusted_image.page = Rectangle.new(THUMB_WIDTH, THUMB_HEIGHT, col * THUMB_WIDTH, row * THUMB_HEIGHT)
  
  # add to the new list
  adjusted_images << adjusted_image
end

# so we know something is happening
puts "MOSAIC #{adjusted_images.size} images >> #{width}x#{height}"

# do it
Dir.mkdir DEST_FILE_DIR unless Dir.exists? DEST_FILE_DIR  # make sure dest directory exists
mosaic = adjusted_images.mosaic                           # assemble the mosaic
mosaic.write "#{DEST_FILE_DIR}/#{DEST_FILE_NAME}"         # write it to the file
`open #{DEST_FILE_DIR}/#{DEST_FILE_NAME}`                 # open with local OS (works for OS X)
