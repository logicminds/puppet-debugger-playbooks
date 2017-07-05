source "https://rubygems.org"

# Specify your gem's dependencies in puppet-debugger-playbooks.gemspec
gemspec

group :dev, :test do
  gem 'puppet-debugger'
  gem 'pry'
  gem 'CFPropertyList'
  gem 'rake'
  gem 'rspec', '>= 3.6'
  # loads itself so you don't have to update RUBYLIB path
  gem 'puppet-debugger-playbooks', path: './'
end
