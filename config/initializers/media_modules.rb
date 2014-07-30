# Media Module Intializer

# Example:
#
#   # get path for a media module
#   MEDIA_MODULES['sfrecord']

# Read in media module configuration to a global constant.
MEDIA_MODULES = YAML::load_file(File.join(__dir__, '../media_modules.yml'))

# Expand Paths relative to project root
MEDIA_MODULES.map do |k, v|
  v["path"] = File.expand_path(v["path"], Rails.root)
end
