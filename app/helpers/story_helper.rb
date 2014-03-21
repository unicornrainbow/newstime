require 'crawdad'
require 'crawdad/ffi'
require 'crawdad/ffi/tokens'
require 'crawdad/native'
require 'crawdad/html_tokenizer'
require 'stringio'
require "net/http"
require "uri"

module StoryHelper

  # Returns the current story fragment index for a given story name and verion
  # key. The version key can be used to have different tracks for the same story
  # in same document if needed.
  def story_fragment_index(story_name, version)
    @story_fragment_indexes ||= {}

    story_fragment_key = "#{story_name}-#{version}"
    index = @story_fragment_indexes[story_fragment_key]
    index = index ? index + 1 : 0
    @story_fragment_indexes[story_fragment_key] = index
  end

  def fetch_story_fragment(story_name, fragment_index, last_mod_time)
    fragment = $dalli.get "story_fragments/#{story_name}/#{fragment_index}"

    Rails.logger.info fragment && last_mod_time == fragment[:last_mod_time]
    Rails.logger.info last_mod_time
    #Rails.logger.info fragment[:last_mod_time]

    unless fragment && last_mod_time == fragment[:last_mod_time]
      Rails.logger.info "Typesetting Story: #{story_name}, Fragment Index: #{fragment_index}"
      fragment = {
        last_mod_time: last_mod_time,
        payload: yield
      }
      $dalli.set "story_fragments/#{story_name}/#{fragment_index}", fragment
    end

    fragment[:payload]
  end

end
