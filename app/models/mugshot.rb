class Mugshot < ActiveRecord::Base
  belongs_to :phrase
  belongs_to :user
  belongs_to :definition
  has_many :comments
  ## :storage => :file_system, 
  ## :storage => :s3, 
  
  has_attachment :content_type => :image, 
                 :storage => :file_system,
                 :max_size => 500.kilobytes,
                 :resize_to => '320x200>',
                 :thumbnails => { :thumb => '100x100>' }

  validates_as_attachment

  def user_log(id, login, user)
    if login
      @mugshot = Mugshot.find(id)
      if @mugshot.user_id == nil
        @mugshot.update_attributes(:user_id => user.id)
      end
    end
    @mugshot
  end



end
