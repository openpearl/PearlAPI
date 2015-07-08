# PearlAPI
The Pearl API. Handles server side logic and communication with TrueVault.

Setup:
1. In the root directory of the API, run "bundle install" to install the gem dependencies

2. In app/config directory, create two files: secretes.yml and application.yml.
    NOTE: Do NOT commit these files. Only you should have access to these files and their contents. 
    These files are meant to contain private information for your eyes only!

    app/config/secrets.yml should contain: 
        development:
          secret_key_base: PUT_YOUR_SECRET_KEY_HERE

        test:
          secret_key_base: PUT_YOUR_SECRET_KEY_HERE

        # Do not keep production secrets in the repository,
        # instead read values from the environment.
        production:
          secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

    app/config/application.yml should contain:
        TV_ACCOUNT_ID: PUT_YOUR_TRUEVAULT_ACCOUNT_ID_HERE

        TV_ADMIN_API_KEY: PUT_YOUR_TRUEVAULT_ADMIN_API_KEY_HERE

        development:
          TV_VAULT_ID: PUT_YOUR_TRUEVAULT_DEVELOPMENT_VAULT_ID_HERE

        test: 
          TV_VAULT_ID: PUT_YOUR_TRUEVAULT_TEST_VAULT_ID_HERE
          
        production: 
          TV_VAULT_ID: PUT_YOUR_TRUEVAULT_PRODUCTION_VAULT_ID_HERE

3. In the root directory of the API, run "rake db:create" to initialize the postgresql databases
4. Run "rake db:migrate" to create the tables for the models