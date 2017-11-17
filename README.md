# waroforbs
Browser MMORTS written in Ruby, CoffeeScript inspired by warchaos.ru game

## Directory structure. hier

app - ruby files for backend application.

coffee - .coffee script files.

config - configuration files.

config/locales - i18n files

data - game data dumps. Map cells, units, players.

img - images.

log - application and web server logs.

scss - .scss files.

test - unit test and chunks of code.

tmp - for pids.

views - web templates.


## Installation


Clone project

```
git clone https://github.com/shazgorn/waroforbs.git waroforbs
cd waroforbs/
```

Install ruby and ImageMagick via your favourite package manager for example:

```
zypper install ruby ImageMagick
```

Install bundler - gem manager

```gem install bundler```

Install required gems via bundler

```
bundler install --with=test
```

Copy default configs

```
cp config/app.default.yml config/app.yml
cp config/thin.example.yml config/thin.yml
cp config/ws_thin.example.yml config/ws_thin.yml
rake init
```
You can edit some settings there or leave it be, ip for example

Run websockets server as `rake front_start`. Webserver will be started as daemon.

Run websockets server as `rake ws_start` if map was generated in previous run

Go to http://0.0.0.0:9292/
