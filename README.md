# PearlAPI
The Pearl API. Handles server side logic and communication with the Pearl Client.


## For Developers:
* Before you begin, make sure you have [Ruby 2.2+](https://www.ruby-lang.org/en/documentation/installation/) and 
[Rails 4.2+](http://rubyonrails.org/download/) installed.
* Sign up for a [SendGrid account](https://sendgrid.com/) (emails to users are sent using SendGrid servers). Alternatively, you can [configure the API to use a different smtp server of your choice](#configure-smtp-server). 
* Sign up for a [TrueVault account](https://www.truevault.com/) (TrueVault serves as a HIPAA compliant database for Pearl). Afterwards, sign in and:
    1. Create a TrueVault "admin" user.
    2. Create at least one TrueVault vault. I recommend a different vault for testing, development and production environments.
    3. Take note of the following keys. You will need them to configure the API to work with TrueVault.
        * `Account ID` - Found in the `Account` tab.
        * `API Key` - Go to the `Users` tab, and click on the admin user to view the API key.
        * `Vault ID(s)` - Found in the `Vaults` tab.


### Setup
1. Clone this repository.
2. CD into the Pearl API root directory.
3. Install the dependencies:
```bash
bundle install
```
4. Create the database tables:
```bash
rake db:migrate
```
5. In the `config` directory, create an `application.yml` file. 
*  **NOTE**: Do **NOT** commit this file - it is meant to contain private information for your eyes only! It *should* be ignored by default with the bundled `figaro gem`.
    
##### Example `application.yml` file:
```ruby
# config/application.yml 

# Setting environment varibles for communicating with TrueVault:
TV_ACCOUNT_ID: YOUR_TRUEVAULT_ACCOUNT_ID_HERE
TV_ADMIN_API_KEY: YOUR_TRUEVAULT_ADMIN_API_KEY_HERE

# Setting environment varibles for sending emails with SendGrid:
SENDGRID_USERNAME: YOUR_SENDGRID_USERNAME_HERE
SENDGRID_PASSWORD: YOUR_SENDGRID_PASSWORD_HERE

# Secret key for devise
DEVISE_SECRET_KEY: YOUR_DEVISE_SECRET_KEY_HERE

# Production database password
PEARLAPI_DATABASE_PASSWORD: YOUR_PEARLAPI_DATABASE_PASSWORD_HERE

# Development environment-specific variables
development:
    TV_VAULT_ID: YOUR_DEVELOPMENT_TRUEVAULT_VAULT_ID_HERE
    SECRET_KEY_BASE: YOUR_DEVELOPMENT_SECRET_KEY_BASE_HERE

# Test environment-specific variables
test: 
    TV_VAULT_ID: YOUR_TEST_TRUEVAULT_VAULT_ID_HERE
    SECRET_KEY_BASE: YOUR_TEST_SECRET_KEY_BASE_HERE
          
# Production environment-specific variables          
production: 
    TV_VAULT_ID: YOUR_PRODUCTION_TRUEVAULT_TEST_VAULT_ID_HERE
    SECRET_KEY_BASE: YOUR_PRODUCTION_SECRET_KEY_BASE_HERE
```
6. Thats it! If you want to test out the API:
```bash
rails server
```

### Configure SMTP server
1. In the `application.yml` file, replace
```ruby
# config/application.yml
...
# Setting environment varibles for sending emails with SendGrid:
SENDGRID_USERNAME: YOUR_SENDGRID_USERNAME_HERE
SENDGRID_PASSWORD: YOUR_SENDGRID_PASSWORD_HERE
...
```
with:
```ruby
# config/application.yml
...
# Setting environment varibles for sending emails:
CUSTOM_SMTP_SERVER_USERNAME: YOUR_USERNAME_HERE
CUSTOM_SMTP_SERVER_PASSWORD: YOUR_PASSWORD_HERE
...
```

2. Update the `environment.rb` file. It should look something like the following, but may change depending on the SMTP server you choose to use.
```ruby
# config/environment.rb
...
# Configure mailer
ActionMailer::Base.smtp_settings = {
  :user_name => ENV["CUSTOM_SMTP_SERVER_USERNAME"],
  :password => ENV["CUSTOM_SMTP_SERVER_PASSWORD"],
  :domain => 'heroku.com',
  :address => YOUR_SMTP_ADDRESS_HERE,
  :port => YOUR_SMTP_PORT_HERE,
  :authentication => :plain,
  :enable_starttls_auto => true
}
...
```

### Deploy
[Step-by-step instructions for deploying on Heroku](https://devcenter.heroku.com/articles/getting-started-with-ruby#introduction).

