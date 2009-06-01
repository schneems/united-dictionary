class Comment < ActiveRecord::Base
 belongs_to :phrase
 belongs_to :mugshot
end
