# waroforbs
Browser MMORTS written in Ruby, CoffeeScript

## Directory structure

app - ruby files for backend application.
coffee - .coffee script files.
config - configuration files.
data - game data dumps. Map cells, units, players.
fonts - web fonts.
img - images.
log - application, web server logs.
scss - .scss files.
test - unit test and chunks of code.
tmp - for pids.
views - web templates.

## Deploy

Install ruby, run bundler.
Copy config/app.default.yml to config/app.yml. Change required paths in that file.
Copy config/thin-example.yml to config/thin.yml. Change required paths in that file too.
Change ip addresses for remote setup or leave it be.
Run webserver as `sh front.sh start`. Webserver will be started as daemon.
Run backend as `sh rwl.sh gen` to generate map or `sh rwl.sh` if map were generated in previous run.
There is f.sh file for automating stopping-fetching-starting proccess.