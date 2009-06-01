# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format 
# (all these examples are active by default):

## rails 2.1.0 Inflector.inflections do |inflect|
## rails 2.2.2 
ActiveSupport::Inflector.inflections do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
   inflect.irregular 'slang', 'slang'
#   inflect.uncountable %w( fish sheep )
 end
