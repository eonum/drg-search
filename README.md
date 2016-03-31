# DRG search
"DRG-Fallzahlsuche" on behalf of the Swiss Federal Office of Public Health FOPH 

## Configuration

* Ruby: 2.2.3, as specified by the .ruby-version file in the root folder.
* Rails: 4.2.4
* Database: PostgreSQL

To prevent sensitive data to show up in the repository, put such data into the
``.env`` file. Then they are available, for example in ``database.yml``, as

``<%= ENV['SOME_PASSWORD'] =>``

### Setup PostgreSQL on Ubuntu 14.04 for production
This section describes the setup for PostgreSQL for Ruby on Rails on a Ubuntu 14.04 machine. The Rails application and the database are assumed to be running on the same machine.

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

Further information can be found here: https://help.ubuntu.com/community/PostgreSQL

## Testing

* Uses ``RSpec`` instead of ``Test``.
* ``FactoryGirl`` to create test fixtures and ``DatabaseCleaner`` to reset the database 
  after each test are provided by the Gemfile.
