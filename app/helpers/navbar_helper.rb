module NavbarHelper
  def navbar_notes_class
    classes = []
    classes << "active" if current_page?("/")
    classes.join(" ")
  end

  def navbar_images_class
    classes = []
    classes << "active" if current_page?("/images")
    classes.join(" ")
  end

   def navbar_attachments_class
    classes = []
    classes << "active" if current_page?("/attachments")
    classes.join(" ")
   end

   def navbar_wiki_class
    classes = []
    classes << "active" if current_page?("/wiki")
    classes.join(" ")
   end

   def navbar_bookmarks_class
    classes = []
    classes << "active" if current_page?("/bookmarks")
    classes.join(" ")
   end

   def navbar_email_class
    classes = []
    classes << "active" if current_page?("/email")
    classes.join(" ")
   end
end
