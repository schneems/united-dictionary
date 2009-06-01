module PhraseHelper
  
  def add_definition_link(meaning) 
      link_to_function meaning do |page| 
        page.insert_html :bottom, :definitions, :partial => 'forms/definition', :object => Definition.new 
    end 
  end
end
