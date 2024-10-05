source 'https://rubygems.org'

ruby '3.3.4'

gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.1.4'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'

gem 'devise'
gem 'devise-i18n'
gem 'haml-rails'
gem 'rails-i18n'
gem 'simple_form'
gem 'image_processing', '~> 1.2'
gem 'business_time'
gem 'discard'
gem 'stripe'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'letter_opener_web'
end

group :development do
  gem 'web-console'
  gem 'sgcop', github: 'SonicGarden/sgcop'
end

group :test do
  gem 'capybara'
  gem 'email_spec'
  gem 'selenium-webdriver'
  gem 'database_cleaner' # NOTE: 特定のテストでエラーが出てしまうため追加
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end
