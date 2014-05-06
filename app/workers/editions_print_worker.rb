# Prints/Compiles and edition
class EditionsPrintWorker
  include Sidekiq::Worker

  def perform(print_id)
    # TODO: This should be move to a service class
    logger.info "Print #{print_id} Beginning"
    print = Print.find(print_id)
    edition = print.edition
    compiler = EditionCompiler.new(edition)
    compiler.compile!

    # TODO: Need convention for where to print is to be stored on disk.

    # Trigger print complete event on the edition.
    print.print_complete

    logger.info "Print #{print_id} Complete"
  end
end
