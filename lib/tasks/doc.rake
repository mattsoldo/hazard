namespace :doc do
  desc 'Extract developer notes'
  task :dnote => :environment do
    `dnote app/**/* config/**/* db/**/* lib/**/*  public/javascripts/**/* public/stylesheets/**/* spec/**/* test/**/* --title "Statusroom notes" --html > doc/dnote.html`
  end
end