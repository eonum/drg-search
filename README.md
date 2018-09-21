# DRG search
"DRG-Fallzahlsuche" on behalf of the Swiss Federal Office of Public Health FOPH 

## Configuration

* Ruby: 2.5.0, as specified by the .ruby-version file in the root folder.
* Rails: 5.2.1
* Database: PostgreSQL

## Installation
### Credentials
Rails 5.2 replaces secrets with encrypted credentials. The encrypted credentials are saved on config/credentials.yml.enc. 
Don't edit the file directly. To add or edit credentials, run

``EDITOR=vim bin/rails credentials:edit``

In this file you store all your private credentials. They are available, for example in ``database.yml``, as

 ``<%= Rails.application.credentials.postgres[:development][:drgsearch_development_user] %>``

The file already contains all necessary information to connect the app to the database in production. If you change
anything, make sure it still works!

Further information about credentials can be found here: https://www.engineyard.com/blog/rails-encrypted-credentials-on-rails-5.2

### Setup PostgreSQL on Ubuntu 16.04 for production and manage roles
This section describes the setup for PostgreSQL for Ruby on Rails on a Ubuntu 16.04 machine. 
The Rails application and the database are assumed to be running on the same machine. For development environments 
it may be sufficient to use your user account as the PostgreSQL role.

Install PostgreSQL server and client if not already installed:

``sudo apt-get install postgresql postgresql-contrib libpq-dev``

Login into the PostgreSQL console using the default admin role postgres
 
``sudo -u postgres psql postgres``

Set the password and then exit the console with \q

``\password postgres``

Create new user drgsearch. You will be promted for a password.

``sudo -u postgres createuser -A -P drgsearch``

Check the PostgreSQL config file (adapt version and path if different)

``sudo vim /etc/postgresql/9.5/main/pg_hba.conf``

Add the following line if not already present:

``local   all             drgsearch                                md5``

Restart the server

``sudo service postgresql restart``


### Database configuration
To be able to connect the app to the created postgres database, you need to configure the app.
Use the database.yml.example file to create your own database configuration file

``cp -i config/database.yml config/database.yml``

Replace the current configuration (username and password for development, test and production) with the username
and password of your postgres user. So you don't have to change the credentials.yml.enc file. Your database.yml should look like this

```
# development:
username: your_postgres_username
password: your_secret_postgres_password

# test:
username: your_postgres_username
password: your_secret_postgres_password

# production:
username: your_postgres_username
password: your_secret_postgres_password
```

Test with database creation

```
rails db:create
rails db:migrate
```

and if you want to create a production database:

```
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate
```

Further information can be found here: https://help.ubuntu.com/community/PostgreSQL

### Install ElasticSearch and index the database

Important: use elasticsearch 2.4.6, otherwise it may not work!

General installation guide:
https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html

Installation instructions using apt on Ubuntu:
https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html

```
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
sudo apt-get update && sudo apt-get install elasticsearch
# if you want to automatically start elasticsearch on system startup
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
# check with
sudo systemctl status elasticsearch.service
```

### Seed DRG catalogues and import data
The following rake tasks handle the import of data and DRG catalogues.
 Use `rake db:reseed['directory']` if you have a fresh database (created by `rake db:create`) or a database that has 
 been emptied by `rake db:truncate`. `rake db:reseed[directory]` calls `rake db:seed_drg_version[directory]` 
 and `rake db:seed_numcase_data[directory]` for all systems and years.

```
rails db:reseed['directory']                # Empties all tables and executes all tasks to setup the database
rails db:seed_drg_version['directory']      # Seed a DRG system
rails db:seed_numcase_data['directory']     # Seed all data in a certain directory
rails db:truncate                           # Truncate all tables (empties all tables except schema_migrations and resets pk sequence)
```

### Import and update Swiss Styleguide (https://github.com/swiss/styleguide)
Update the git submodule which references the swiss styleguide using:

``rails swiss_styleguide:update_submodule`` 

This will check out the submodule if this isn't done already. Then it will pull the newest commit on the master branch of 
the submodule and finally update .gitmodules if necessary.

Import the state which is represented in the styleguide submodule with: 

``rails swiss_styleguide:import``

This will copy the files from ./styleguide/build to the appropriate locations in ./vendor/assets and ./public.

These both steps can also be executed at once by entering: 

``rails swiss_styleguide:update_and_import``


### Seed new data (year)
1. Add new numcase data directory to data repo
2. Seed new catalogue
    ```
    rails db:seed_drg_version['directory'] 
    ```
3. Update catalogues (add year to system.json in the data repository in catalogues/VX.0/ and manually to the database if there is no complete reseed)
4. Seed numcase data
    ```
    rails db:seed_numcase_data['directory'] 
    ```
5. Update reseed task (db:reseed['directory']) to include new years

### Deployment
Before you deploy a new version of the app, do the following:
1. Create a production database (if it doesn't exist yet)
2. Import the data in your production database
    ```
    RAILS_ENV=production rails db:reseed['directory']
    ```
3. Reindex all elasticsearch models 

    ```
    RAILS_ENV=production rails c
    Adrg.reindex
    Drg.reindex
    Mdc.reindex
    Hospital.reindex
    
    ``` 

4. Precompile assets, clear tmp: 
    ```
    RAILS_ENV=production rails tmp:clear
    RAILS_ENV=production rails assets:clobber
    RAILS_ENV=production rails assets:precompile
    ```
5. Start server in production and check if everything works as expected
    ```
    RAILS_ENV=production rails s
    ```

On the server, you usually don't have to reindex the models.