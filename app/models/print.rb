class Print
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :edition

  state_machine :state, initial: :initial do
    before_transition :initial => :printing, do: :queue_print
    after_transition  :printing => :printed, do: :broadcast_print_complete

    event :print_start do
      transition :initial => :printing
    end

    event :print_complete do
      transition :printing => :printed
    end

    event :sign do
      transition :printed => :signed
    end

    event :publish do
      transition :signed => :published
    end

    event :reset do
      transition any => :initial
    end
  end

  def name
    "#{edition.name.underscore.gsub(/[^a-z\s]/, '').gsub(' ', '_')}_#{created_at.localtime.strftime('%Y%m%d%H%M%S')}"
  end

  def queue_print
    EditionsPrintWorker.perform_async(id.to_s)
  end

  def broadcast_print_complete
    message = {:channel => "/editions/#{id.to_s}", :data => "print_complete", :ext => {:auth_token => FAYE_TOKEN}}
    uri = URI.parse(FAYE_URL)
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  def print_complete?
    !["initial", "printing"].include?(state)
  end

  def edition_share_path
    "#{Rails.root}/share/compiled_editions/#{edition.id.to_s}"
  end

  # Share path on disk where the print is stored
  def share_path
    "#{edition_share_path}/#{id.to_s}"
  end

  def zip_path
    "#{share_path}/#{name}.zip"
  end

  # Zips the output
  def zip!
    system "cd #{share_path}; zip -r #{name}.zip ."
  end

end
