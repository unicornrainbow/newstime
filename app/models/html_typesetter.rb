# Calls typesetting service to typeset html
class HtmlTypesetter
  LINEBREAK_SERVICE_URL = URI.parse(ENV['LINEBREAK_SERVICE_URL'])

  def initialize(html, options={})
    @html = html
    @options = options
  end

  def typeset
  end
end
