Gem::Specification.new do |spec|
  spec.name = 'szymanskis_mutex'
  spec.version = '0.1.1'
  spec.date = '2018-10-11'
  spec.summary = "Szymanski's Mutual Exclusion Algorithm."
  spec.description = 'Algorithm devised by Boleslaw Szymanski. This MutEx has '\
                  'linear wait and only 5 communication variables'
  spec.license = 'MIT'
  spec.authors = ['Emmanuel Byrd']
  spec.email = 'emmanuel_pajaro@hotmail.com'
  spec.homepage = 'https://github.com/EByrdS/szymanskis_mutex'
  spec.files = [
    'lib/szymanskis_mutex.rb'
  ]
  spec.require_paths = ['lib']
  spec.add_development_dependency 'rspec', '~> 3.8', '>= 3.8.0'
  spec.add_development_dependency 'rspec-core', '~> 3.8', '>= 3.8.0'
end
