require 'settingslogic'

class Config < Settingslogic
  source File.expand_path('../../config/app.yml', __FILE__)
end
