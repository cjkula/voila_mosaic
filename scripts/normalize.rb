require 'RMagick'
include Magick

PROJECT_DIR = File.join(File.dirname(__FILE__), '..') # up a level

SOURCE_FILE_DIR = File.join(PROJECT_DIR, 'sources')   # files to be normalized
DEST_FILE_DIR = File.join(PROJECT_DIR, 'normalized')  # where to put the results

# dimensions of output files
THUMB_WIDTH = 100
THUMB_HEIGHT = 125

Dir.mkdir DEST_FILE_DIR unless Dir.exists? DEST_FILE_DIR # make sure destination dir exists

# get the sources
Dir.chdir SOURCE_FILE_DIR
files = Dir.entries(SOURCE_FILE_DIR)            # all files
           .select{ |f| !f.match /^\./}         # ...except hidden files
           .select{ |f| !File.directory?(f) }   # ...and directories
           # .select{ |f| f[/pattern/] }          # optionally, filter files on a pattern
source_images = ImageList.new *files            # load sources

## cycle through the source image list and output processed thumbs
source_images.each do |src| 
  puts src.filename # report progress
  grayscale = src.quantize(256, Magick::GRAYColorspace) # convert to grayscale
  thumb = grayscale.crop_resized(THUMB_WIDTH, THUMB_HEIGHT, Magick::CenterGravity) # scale
  thumb.write "#{DEST_FILE_DIR}/#{src.filename}"    # write out file
end

exit

