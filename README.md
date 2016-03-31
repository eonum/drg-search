# drg-search
"DRG-Fallzahlsuche" on behalf of the Swiss Federal Office of Public Health FOPH 

## Configuration

* Ruby: 2.2.3, as specified by the .ruby-version file in the root folder.
* Rails: 4.2.4
* Database: PostgreSQL

To prevent sensitive data to show up in the repository, put such data into the
``.env`` file. Then they are available, for example in ``database.yml``, as

``<%= ENV['SOME_PASSWORD'] =>``

### Setup PostgreSQL on Ubuntu 14.04
Install PostgreSQL server and client

``sudo apt-get install postgresql postgresql-contrib libpq-dev``

#### Manage roles
1. Login into the PostgreSQL console using the default admin role postresql
 
``sudo -u postgres psql postgres``

2. Set the password and then exit the console with \q

``\password postgres``

3. Create new user drgsearch. You will be promted for a password.

``sudo -u postgres createuser -A -P drgsearch``

4. Configure your .env file with the created user and password:

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


Further information can be found here: https://help.ubuntu.com/community/PostgreSQL

## Testing

* Uses ``RSpec`` instead of ``Test``.
* ``FactoryGirl`` to create test fixtures and ``DatabaseCleaner`` to reset the database 
  after each test are provided by the Gemfile.
