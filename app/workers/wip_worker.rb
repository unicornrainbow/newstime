class WIPWorker
  include Sidekiq::Worker

  def perform(edition_id)
    edition = Edition.find(edition_id)

    screenname = edition.user ? edition.user.screenname : 'nobody'
    disk_path = "#{Rails.root}/share/#{screenname}/#{edition.id.to_s}"
    system "mkdir -p #{disk_path}"

    case `uname`.strip
    when 'Darwin' # OSX
      system "cd #{disk_path}; webkit2png -z 2.0 -C -s 1 --filename=wip --clipwidth=2880 --clipheight=1800 http://localhost:3000/editions/#{edition.id.to_s}/preview/main.html; mv wip-clipped.png wip.png"
      system "cd #{disk_path}; convert wip.png -resize 1024x1024 wip.png"
    when 'Linux'  # Ubuntu
      system "cd #{disk_path}; webkit2png -x 1400 900 -g 1400 900 --aspect-ratio=crop -o wip.png http://www.newstime.love/editions/#{edition.id.to_s}/preview/main.html"
      system "cd #{disk_path}; convert wip.png -resize 1024x1024 wip.png"
    end
  end

end
