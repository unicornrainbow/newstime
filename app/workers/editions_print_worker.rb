# Prints/Compiles and edition
class EditionsPrintWorker
  include Sidekiq::Worker

  def perform(edition_id)
    logger.info "Edition Compile Beginning"
    edition = Edition.find(edition_id)
    EditionCompiler.new(edition).compile!
    logger.info "Edition Compile Complete"
  end
end
