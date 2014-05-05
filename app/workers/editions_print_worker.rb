# Prints/Compiles and edition
class EditionsPrintWorker
  include Sidekiq::Worker

  def perform(edition_id)
    # TODO: This should be move to a service class
    logger.info "Edition Compile Beginning"
    edition = Edition.find(edition_id)
    EditionCompiler.new(edition).compile!

    # Create a new print object
    edition.prints.create

    # Trigger print complete event on the edition.
    edition.print_complete

    logger.info "Edition Compile Complete"
  end
end
