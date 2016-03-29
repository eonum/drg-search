# drg-search
"DRG-Fallzahlsuche" on behalf of the Swiss Federal Office of Public Health FOPH 

## Configuration

* Ruby: 2.2.1, as specified by the .ruby-version file in the root folder.
* Rails: 4.2.4
* Database: PostgreSQL

To prevent sensitive data to show up in the repository, put such data into the
``.env`` file. Then they are available, for example in ``database.yml``, as

``<%= ENV['SOME_PASSWORD'] =>``

A .env file is currently under version control, but it contains only development/test
information, serving as an example.

### Required packages for development on Ubuntu
``sudo apt-get install postgresql postgresql-contrib libpq-dev``

## Testing

* Uses ``RSpec`` instead of ``Test``.
* ``FactoryGirl`` to create test fixtures and ``DatabaseCleaner`` to reset the database 
  after each test are provided by the Gemfile.
