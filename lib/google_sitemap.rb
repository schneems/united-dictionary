require 'net/http'
require 'uri'
require  'zlib'

# A class specific to the application which generates a google sitemap from the contents of the database.
# Author: Alastair Brunton
# Modified: Harry Love 2008-06-09
class GoogleSitemapGenerator
 
  def initialize(base_url, sources)
    @base_url = base_url
    @sources = sources
  end
 
  # 1. Iterate through each model's #get_paths method
  # 2. Create sitemap file for each model
  # 3. Create sitemap index file
  # 4. Ping Google
  def generate
    path_ar = []
    sitemaps = []    
    @sources.each do |source|
      # initialize the class and call the get_paths method on it.
      # path_ar = eval("phrase.get_paths")
      
      
      path_size = eval("#{source}.count")
      
      
     # path_ar = eval("#{source}.get_paths")
      ## path_ar is an array of every path in the website
      
      @number_of_xml_files = path_size/50000
      
      ## this is what makes multiple xml files
      
      0.upto(@number_of_xml_files) do |count|
        path_ar = eval("#{source}.get_paths(50000, count*50000, #{path_size})")
        individual_path = path_ar
        xml = generate_sitemap(individual_path)
        save_file(source+count.to_s, xml)
        @new_sources = []
        @new_sources << source+count.to_s     
      end
      
    end
      index = generate_sitemap_index(@sources)
      save_file('index', index)
      update_google
  end
  
  
  
 
  # Create a sitemap document for a model
  def generate_sitemap(path_ar)
    
    xml_str = ""
    xml = Builder::XmlMarkup.new(:target => xml_str)
    xml.instruct!
    
    
    xml.urlset(:xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9') {
      
      path_ar.each do |path|
        xml.url {
      	  xml.loc(@base_url + path[:url])
      	  xml.lastmod(path[:last_mod])
      	  xml.changefreq('weekly')
        }
      end
    }
    
    
    
    xml_str
  end
  
  
  
  ## not this one
  # Create a sitemap index document
  def generate_sitemap_index(sitemaps)
    xml_str = ""
    xml = Builder::XmlMarkup.new(:target => xml_str)
    xml.instruct!
    xml.sitemapindex(:xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9') {

      ## this is what adds the new xml files to the index
      0.upto(@number_of_xml_files) do |count|   
        site = sitemaps.to_s+count.to_s    
        
        
        xml.sitemap {
      	  xml.loc(@base_url + "/sitemaps/sitemap_#{site}.xml.gz")
      	  xml.lastmod(Time.now.strftime('%Y-%m-%d'))
   	                }
   	
   	
   	
      end
    }
    xml_str
  end
  ## not this one
  # Save the xml file (gzipped) to disk
  def save_file(source, xml)
    File.open(RAILS_ROOT + "/public/sitemaps/sitemap_#{source}.xml.gz", 'w+') do |f|
      gz = Zlib::GzipWriter.new(f)
      gz.write xml
      gz.close
    end
  end
  ## not this one
 
  # Notify Google of the new sitemap index file
  def update_google
    sitemap_uri = @base_url + '/sitemaps/sitemap_index.xml.gz'
    escaped_sitemap_uri = URI.escape(sitemap_uri)
    Net::HTTP.get('www.google.com', '/webmasters/tools/ping?sitemap=' + escaped_sitemap_uri)
  end
end