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

``rake db:create``

and if you want to create a production database:

``RAILS_ENV=production rake db:create``


Further information can be found here: https://help.ubuntu.com/community/PostgreSQL

#### Update and Import Swiss Styleguide (https://github.com/swiss/styleguide)
Update the git submodule which references the swiss styleguide using:

``rake swiss_styleguide:update_submodule`` 

Import the state which is represented  in the styleguide submodule with: 

``rake swiss_styleguide:import``

These both steps can also be executed at once by entering: 

``rake swiss_styleguide:update_and_import`` 

## Testing

* Uses ``RSpec`` instead of ``Test``.
* ``FactoryGirl`` to create test fixtures and ``DatabaseCleaner`` to reset the database 
  after each test are provided by the Gemfile.
