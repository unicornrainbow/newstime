require 'stringio'

module StoryHelper

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
