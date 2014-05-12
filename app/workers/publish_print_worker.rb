require 'fileutils'
require 'curb'
#
# Prints/Compiles and edition
class PublishPrintWorker
  include Sidekiq::Worker

  def perform(print_id)
    logger.info "Publish Print #{print_id} Beginning"
    print = Print.find(print_id)

    @publication = print.publication

    c = Curl::Easy.new("#{@publication.store_url}/editions")
    c.multipart_form_post = true

    # Need to upload zip and relevant attributes
    c.http_post(Curl::PostField.content('edition[name]',  print.name),
                Curl::PostField.content('edition[publish_date]', print.publish_date.to_s),
                Curl::PostField.content('edition[fmt_price]',    print.fmt_price),
                Curl::PostField.content('edition[volume_label]', print.volume_label),
                Curl::PostField.file('zip', print.zip_path))

    logger.info "Publish Print #{print_id} Complete"
  end
end
