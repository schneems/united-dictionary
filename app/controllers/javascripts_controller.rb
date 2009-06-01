class JavascriptsController < ApplicationController
  def dynamic_states
    @states = State.find(:all)
  end

  # application_helper.rb
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end
end
  
