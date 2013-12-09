module NavbarHelper
  def navbar_notes_class
    active_path '/(notes.*)?$'
  end

  def navbar_images_class
    active_path '/images'
  end

   def navbar_attachments_class
    active_path '/attachments'
   end

   def navbar_wiki_class
    active_path '/wiki'
   end

   def navbar_bookmarks_class
    active_path '/bookmarks'
   end

   def navbar_email_class
    active_path '/email'
   end
end
