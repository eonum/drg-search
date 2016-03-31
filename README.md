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
``sudo apt-get install postgresql postgresql-contrib libpq-dev``

For setting up roles see sections "Using PostgreSQL Roles and Databases" and "Create a New Role" in https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-14-04

## Testing

* Uses ``RSpec`` instead of ``Test``.
* ``FactoryGirl`` to create test fixtures and ``DatabaseCleaner`` to reset the database 
  after each test are provided by the Gemfile.
