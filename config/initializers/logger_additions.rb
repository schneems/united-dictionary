logger = ActiveRecord::Base.logger
def logger.debug_variables(bind)
  not_needed_array = ['@_headers','@template','@_params','@assigns','@performed_redirect','@_request',
                      '@variables_added','@before_filter_chain_aborted','@_response','@url','@_session', 
                      '@action_name','@_flash','@_cookies','@performed_render','@request_origin']
  vars = eval('local_variables + instance_variables', bind)
  vars.each do |var|
    debug  "#{var} = #{eval(var, bind).inspect}" if !not_needed_array.include?(var.to_s)
  end
end
