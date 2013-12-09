module NavbarHelper
  def navbar_notes_class
    "active" if path_matches? '/(notes.*)?$'
  end

  def navbar_images_class
    "active" if path_matches? '/images'
  end

   def navbar_attachments_class
    "active" if path_matches? '/attachments'
   end

   def navbar_wiki_class
    "active" if path_matches? '/wiki'
   end

   def navbar_bookmarks_class
    "active" if path_matches? '/bookmarks'
   end

   def navbar_email_class
    "active" if path_matches? '/email'
   end
end
