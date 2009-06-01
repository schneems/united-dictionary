module CustomValidations    
  

     def validates_not_spam(*attr_names)
          configuration = { :on => :save, :with => nil }
           configuration.update(attr_names.extract_options!)
           ##raise(ArgumentError, "A regular expression must be supplied as the :with option of the configuration hash") unless configuration[:with].is_a?(Regexp)
           validates_each(attr_names, configuration) do |record, attr_name, value|
             ## =~ returns a number if it finds a match otherwise it provides nil 
              if value.to_s =~ /(\[\/url\])/i
                # unless needs a false statment to activate
                  record.errors.add("Your sense of decency") 
             end
           end
         end
 
end  ## module

ActiveRecord::Base.extend(CustomValidations) 
