require_relative 'lib/termlot/version'

DIR = File.expand_path(File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name        = 'termlot'
  s.version     = Termlot::VERSION
  s.date        = '2011-12-18'
  s.authors     = ['Sinan Taifour']
  s.email       = 'sinan@taifour.com'
  s.summary     = "Make plots in the terminal."
  s.description = "Make plots in the terminal."
  s.files       = Dir[DIR + '/lib/**/*.rb']
  s.license     = 'MIT'
end
