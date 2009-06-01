# Rails plugin that makes text areas automagically resize/grow.
# Copyright (C) 2007  John R. Wulff <johnw@orcasnet.com>
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

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
    
    module FormTagHelper
      def text_area_tag_with_auto_resize(name, content = nil, options = {})
        auto_resize_options = {}
        auto_resize_options[:rows] = 1
        auto_resize_options[:onKeyPress] = "if (this.scrollHeight > this.clientHeight && !window.opera)\nthis.rows += 1;"
        auto_resize_options.merge!(options)
        text_area_tag_without_auto_resize name, content, auto_resize_options
      end
      alias_method_chain :text_area_tag, :auto_resize
    end
  end
end