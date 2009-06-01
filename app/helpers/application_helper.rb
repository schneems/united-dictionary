# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def get_site_name
    the_request = request.host
    #the_request = "www.slangasaur.us"
    #the_request = "www.uniteddictionary.com"
    #request_with_subdomain = "www.en.uniteddictionary.com"
    #local_request = "dict.local"
    domain_array = the_request.scan(/([^.||^\d||^\:]+)/)
    for entry in domain_array
      entry = entry.to_s
      @site_name = entry if entry != "www" && entry.size != 2 && entry != "com" && entry != "local" 
    end        
    @site_name = "SlangSlang" if @site_name == "slangslang"
    @site_name = "Slangasaurus" if @site_name == "slangasaur"
    @site_name = "United <br /> Dictionary" if @site_name == "uniteddictionary" || @site_name == "dict" ||@site_name == nil
    @site_name = "United <br /> Dictionary" if @site_name == "uniteddictionary" || @site_name == "dict" ||@site_name == nil
    %(#{@site_name})
  end
  
  def inline_get_site_name
    the_request = request.host
    domain_array = the_request.scan(/([^.||^\d||^\:]+)/)
    for entry in domain_array
      entry = entry.to_s
      @inline_site_name = entry if entry != "www" && entry.size != 2 && entry != "com" && entry != "local" 
    end    
        
    @inline_site_name = "SlangSlang" if @inline_site_name == "slangslang"
    @inline_site_name = "Slangasaurus" if @inline_site_name == "slangasaur"
    @inline_site_name = "United Dictionary" if @inline_site_name == "uniteddictionary" || @inline_site_name == "dict" ||@inline_site_name == nil
    %(#{@inline_site_name})
  
  end 
   
   
  
  
  def page_title 
    title = @page_title ? " #{@page_title} |" : '' 
    %(<title>#{title} #{t 'meta.title'}</title>) 
  end #def 
  
  def meta(name, content)     
    %(<meta name="#{name}" content="#{content} />") 
  end #def 
  
  def meta_description 
    if @page_word
    "#{t 'meta.description'}  #{@page_word} #{t 'in'}  #{@page_language}" 
    else 
      "#{t 'meta.altdescription'}"
    end #if @book
  end #def 
  
  
  def meta_keywords 
    if @page_word 
      [@page_word, 
      @page_language, 
      "#{t "meta.keywords"}"
      ].compact.join(', ')
    else 
      "#{t "meta.altkeywords"}"
    end # if @book
  end # def 
  
  
end
