swipes-web
==========

### Steps to create a build
*Don't type the `$`, playa', it's just a little extra bling* :moneybag:

1. `$ cd app-directory` Make sure you're in the right directory, dummy. :dancer: 
2. `$ git pull` Always pull latest version first
3. `$ npm install` Installs dependencies used by grunt to run its tasks and make the build
4. `$ cd app; bower install` Installs [client-side dependencies](https://pbs.twimg.com/media/BcEPdbqCIAAd3b9.png) like jQuery and Backbone.js
5. `$ grunt build` Spits out a build to the public folder

### Create a build on Ubuntu
# It's go without saying - node and npm are required. There is a lot of ways to install that so I'm no going to write a guide about it.

1. `sudo apt-get install ruby-full` You have to install ruby
2. `sudo gem isntall compass`
3. `sudo npm install -g grunt-cli`
4. `sudo npm install -g bower`
5. `cd swipes-webapp`
6. `sudo npm install`
7. `cd app`
8. `sudo bower install --allow-root`
9. `cd ..`
10. `sudo grunt server`


![Grunt is throwing a Party](https://pbs.twimg.com/media/BcEPdbqCIAAd3b9.png)
