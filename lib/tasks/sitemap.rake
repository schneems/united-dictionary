require 'google_sitemap'

namespace :google_sitemap do
  desc "Generate a Google sitemap from the models"
  task(:generate => :environment) do
    # Generate sitemaps for each of the models listed in the array
    sources = %w( Phrase )
    sitemap = GoogleSitemapGenerator.new('http://www.uniteddictionary.com', sources)
    sitemap.generate
  end
end