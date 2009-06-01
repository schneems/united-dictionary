module ActionView
  module Helpers
    module FormHelper
      def text_area_with_auto_resize(object_name, method, options = {})
        auto_resize_options = {}
        auto_resize_options[:rows] = 1
        auto_resize_options[:onKeyPress] = "if (this.scrollHeight > this.clientHeight && !window.opera)\nthis.rows += 1;"
        auto_resize_options.merge!(options)
        text_area_without_auto_resize object_name, method, auto_resize_options
      end
      alias_method_chain :text_area, :auto_resize
    end
  end
end