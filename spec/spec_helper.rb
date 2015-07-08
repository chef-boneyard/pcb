require 'chefspec'
require 'chef-dk/generator'

ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.color = true
  config.formatter = 'doc'
end
