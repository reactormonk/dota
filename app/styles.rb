require "styler"
Tilt::HamlTemplate.options[:default_attributes] = {form: {method: "post", :'accept-charset' => "UTF-8"}}

class CustomStyle
  include Styler::Style
  delegate_to_controller :user
end

%w(league_membership game player league).each {|file| require_relative("styles/" + file)}
