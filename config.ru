require File.expand_path('../config/bootstrap', __FILE__)

require 'papertrail_services'

run PapertrailServices::App.new
