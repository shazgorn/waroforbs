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
bundler install
```

Copy default configs

```
cp config/app.default.yml config/app.yml
cp config/thin.example.yml config/thin.yml
```
You can edit some settings there or leave it be, ip for example

/Install coffeescrtipt

```
npm install -g coffee-script
```

Run `coffee -cm -o js/ coffee/*.coffee` to build or `sh coffee.sh` to build and watch coffeescript files.

Run `scss scss/style.scss:css/style.css` to build or `sh scss.sh` to build and watch scss files.

Run websockets server as `rake front_start`. Webserver will be started as daemon.

Run websockets server as `rake ws_start` if map was generated in previous run

Go to http://0.0.0.0:9292/
