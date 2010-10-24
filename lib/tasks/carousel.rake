namespace :carousel do
  desc 'Run carousels'
  task :run => :environment do
    next unless Time.worktime?(Time.now)
    
    @carousels = Carousel.active.to_run
    @carousels.each do |carousel| 
      carousel.run
      puts "Run Carousel '#{carousel.name}', next run at #{carousel.next_run.to_s(:db)}"
    end
  end
end