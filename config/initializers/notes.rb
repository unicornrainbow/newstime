# Load up the notes root
NOTES_ROOT = ENV['NOTES_ROOT']

# Create an application shared reference to notebox.
$notebox = Notebox::Box.new(NOTES_ROOT)
