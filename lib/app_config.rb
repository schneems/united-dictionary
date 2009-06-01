## ch, du, en, fr, ge, gr, it, ja, ko, po, ru, sp
LANGUAGE_ARRAY =  [
                    ["#{I18n.t 'languages.chinese'.to_sym}", "Chinese"],
                    ["#{I18n.t 'languages.dutch'.to_sym}", "Dutch"],
                    ["#{I18n.t 'languages.english'.to_sym}","English"],
                    ["#{I18n.t 'languages.french'.to_sym}", "French"],
                    ["#{I18n.t 'languages.german'.to_sym}", "German"],
                    ["#{I18n.t 'languages.greek'.to_sym}", "Greek"],
                    ["#{I18n.t 'languages.italian'.to_sym}", "Italian"],
                    ["#{I18n.t 'languages.japanese'.to_sym}", "Japanese"],
                    ["#{I18n.t 'languages.korean'.to_sym}", "Korean"],
                    ["#{I18n.t 'languages.portuguese'.to_sym}", "Portuguese"],
                    ["#{I18n.t 'languages.russian'.to_sym}", "Russian"],
                    ["#{I18n.t 'languages.spanish'.to_sym}", "Spanish"],
                  ]

      									
class AppConfig  
  def self.load
    config_file = File.join(RAILS_ROOT, "config", "application.yml")

    if File.exists?(config_file)
      config = YAML.load(File.read(config_file))[RAILS_ENV]

      config.keys.each do |key|
        cattr_accessor key
        send("#{key}=", config[key])
      end
    end
  end
end
