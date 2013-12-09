module ApplicationHelper
  include NavbarHelper

  def parent_layout(layout)
    @view_flow.set(:layout,output_buffer)
    self.output_buffer = render(:file => "layouts/#{layout}")
  end

  # Returns true is the path matches the passed regular expression.
  def path_matches?(value)
    case value
    when String
      # Match leading / from the begin, otherwise do fuzzy match

      if value[0] == "/"
        value = /^#{value.to_s}/
      else
        value = /#{value.to_s}/
      end
    end
    request.fullpath.match(value)
  end

  # Return class "active" if path matches path passed.
  #
  # Helpful for generating bootstrap active classes for menu items.
  #
  # Example:
  #
  #     <li class="<%= active_path('/radio') %>"><a href="/radio">Radio</a></li>
  #
  def active_path(path)
    "active" if path_matches?(path)
  end

end
