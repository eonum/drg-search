# DRG search
"DRG-Fallzahlsuche" on behalf of the Swiss Federal Office of Public Health FOPH 

## Configuration

* Ruby: 2.2.3, as specified by the .ruby-version file in the root folder.
* Rails: 4.2.4
* Database: PostgreSQL

To prevent sensitive data to show up in the repository, put such data into the
``.env`` file. Then they are available, for example in ``database.yml``, as

``<%= ENV['SOME_PASSWORD'] =>``

## Installation
### Generate secrets.yml
You have to generate the file config/secrets.yml in order to have a functional and secure application. Do never include this file in version control.

Sample file with secret tokens generated using `rake secret`. Do not use this sample in a production environment without modifying the secret tokens!

```
# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure the secrets in this file are kept private
# if you're sharing your code publicly.

development:
  secret_key_base: f902ac257bb4afbdfb8494fca003bf0e9e057ac9d3225ee3a8e872da0e37af6ce0c0223b39457bca103afd80f6cbd4614bba8ef391d2ae3b563f04f08ec2f939

test:
  secret_key_base: 0464ddd3e633bd6f54b2449683cfde15c25e2889b8198fb44c611990ace1f59a088677aa381e4a0af4b9d5b9036cd8acdf5a09dd420943248a9a59045d1503bc

production:
  secret_key_base: 89b3fc5ad414d94c445f3f533a2dcb6ae90813de4937d603381c34aef9e70d551fc0b7625d566ffd7d0352fd4250e900d0c6c4a9c28af4afe5c6d472779f9969
```
### Setup PostgreSQL on Ubuntu 14.04 for production
This section describes the setup for PostgreSQL for Ruby on Rails on a Ubuntu 14.04 machine. The Rails application and the database are assumed to be running on the same machine. For development environments it may be sufficient to use your user account as the PostgreSQL role.

Install PostgreSQL server and client if not already installed:

``sudo apt-get install postgresql postgresql-contrib libpq-dev``

#### Manage roles
Login into the PostgreSQL console using the default admin role postgres
 
``sudo -u postgres psql postgres``

Set the password and then exit the console with \q

``\password postgres``

Create new user drgsearch. You will be promted for a password.

``sudo -u postgres createuser -A -P drgsearch``

Configure your .env file with the created user and password:

```
# development:
DRGSEARCH_DEVELOPMENT_USER=drgsearch
DRGSEARCH_DEVELOPMENT_PASSWORD=your_secret_password
# test:
DRGSEARCH_TEST_USER=drgsearch
DRGSEARCH_TEST_PASSWORD=your_secret_password
# production:
DRGSEARCH_PRODUCTION_USER=drgsearch
DRGSEARCH_PRODUCTION_PASSWORD=your_secret_password
```
Check the PostgreSQL config file (Adapt version and path if different)

``sudo vim /etc/postgresql/9.3/main/pg_hba.conf``

Add the following line if not already present:

``local   all             drgsearch                                md5``

Restart the server

``sudo service postgresql restart``

Test with database creation

```
rake db:create
rake db:migrate
```

and if you want to create a production database:

```
RAILS_ENV=production rake db:create
RAILS_ENV=production rake db:migrate
```


Further information can be found here: https://help.ubuntu.com/community/PostgreSQL

### Seed DRG catalogues and import data
The following rake tasks handle the import of data and DRG catalogues. Use `rake db:reseed['directory']` if you have a fresh database (create by `rake db:create`) or a database that has been emptied by `rake db:truncate`. `rake db:reseed[directory]` calls `rake db:seed_drg_version[directory]` and `rake db:seed_numcase_data[directory]` for all systems and years.

```
rake db:reseed['directory']                # Empties all tables and executes all tasks to setup the database
rake db:seed_drg_version['directory']      # Seed a DRG system
rake db:seed_numcase_data['directory']     # Seed all data in a certain directory
rake db:truncate                           # Truncate all tables (empties all tables except schema_migrations and resets pk sequence)
```

### Update and Import Swiss Styleguide (https://github.com/swiss/styleguide)
Update the git submodule which references the swiss styleguide using:

``rake swiss_styleguide:update_submodule`` 

This will check out the submodule if this isn't done already. Then it will pull the newest commit on the master branch of the submodule and finally update .gitmodules if necessary.

Import the state which is represented  in the styleguide submodule with: 

``rake swiss_styleguide:import``

This will copy the files from ./styleguide/build to the appropriate locations in ./vendor/assets and ./public.

These both steps can also be executed at once by entering: 

``rake swiss_styleguide:update_and_import``

### Install ElasticSearch and index the database

General installation guide:
https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html

Installation instructions using apt on Ubuntu:
https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html

```
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
sudo apt-get update && sudo apt-get install elasticsearch
sudo /bin/systemctl enable elasticsearch.service
sudo service elasticsearch status
```

### Add new data (year)
1. Add new numcase data directory to data repo
2. Seed new catalogue
```
rake db:seed_drg_version['directory'] 
```
3. Update catalogues (add year to system.json in  and manually to database)
4. Seed numcase data
```
rake db:seed_numcase_data['directory'] 
```
5. Update reseed task (db:reseed['directory']) to include new years
