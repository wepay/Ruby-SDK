source "https://rubygems.org"

gem 'rake'

group :test do
  gem 'rubyunit'
  gem "codeclimate-test-reporter", require: false
  gem 'coveralls', require: false
  gem 'scrutinizer-ocular', require: false
end

group :docs do
  gem 'yard', :git => 'https://github.com/trevorrowe/yard.git', branch: 'frameless'
  gem 'yard-sitemap', '~> 1.0'
  gem 'rdiscount'
end
