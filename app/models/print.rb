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

end
