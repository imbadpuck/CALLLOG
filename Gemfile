source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.1.4'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

#8/11/2017
gem "bootstrap-sass", "~> 3.3.7"
gem "bootstrap-social-rails", "~> 4.12.0"
gem "bulk_insert"
gem "config"
gem "devise", "~> 4.2"
gem "faker", github: "stympy/faker"
gem "font-awesome-rails"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "jwt", "1.5.6"
gem "will_paginate"
gem "awesome_nested_set"
gem "mysql2", "~> 0.3.20"
#========>

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
