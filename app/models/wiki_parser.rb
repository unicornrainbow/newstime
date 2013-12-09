class WikiParser < WikiCloth::Parser

  url_for do |page|
    "/wiki/#{page}"
  end

end
