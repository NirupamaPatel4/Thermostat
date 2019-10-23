# README

​A basic web API​​ for storing readings from IoT thermostats and reporting a simple statistics on them.

* Ruby version - 2.4.3

* System dependencies - Using Mysql, Redis as Cache-store, Sidekiq for background jobs, Rspec for Unit-Testing.

######(edit database credentials in config/database.yml before this step)
How to run the application and tests

* move to the directory and run `sh setup.sh`.
* this will install all the dependencies, run migrations, start the server and sidekiq, and run tests as well.

Your application is running on `http://localhost:9000`

## API endpoints

#### POST Reading
    POST http://{url}/api/readings
    
#### GET Reading
    POST http://{url}/api/readings/{reading_id}

#### GET Stats
    GET http://{url}/api/thermostats/{thermostat_id}/stats
    
    
(This is one un-authenticated end point built to save manual db look ups for getting any info about a particular thermostat.)
#### GET Thermostat
    GET http://{url}/api/thermostats/{thermostat_id}