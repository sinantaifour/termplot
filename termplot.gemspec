require_relative 'lib/termplot/version'

DIR = File.expand_path(File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name        = 'termplot'
  s.version     = Termplot::VERSION
  s.date        = '2011-12-18'
  s.authors     = ['Sinan Taifour']
  s.email       = 'sinan@taifour.com'
  s.summary     = "Make plots in the terminal."
  s.description = "Make plots in the terminal."
  s.files       = Dir[DIR + '/lib/**/*.rb']
  s.license     = 'MIT'

  s.add_dependency 'ruby-terminfo', '~> 0.1'

  s.add_development_dependency 'rake', '~> 12.0'
end
