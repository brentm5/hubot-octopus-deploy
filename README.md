# hubot-octopus-deploy
Hubot commands for managing octopus deploy

See [`src/scripts/tasks.coffee`](src/scripts/tasks.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-octopus-deploy --save`

Then add **hubot-octopus-deploy** to your `external-scripts.json`:

```json
[
  "hubot-octopus-deploy"
]
```

## Sample Interaction

```
user1>> hubot octo active task
hubot>> 10 tasks are running
```
## Configuration

### HUBOT_OCTO_ENDPOINT

This environment variable is the base url of your octopus installation. For example, `http://octopus.whereeveritcouldbe`

### HUBOT_OCTO_APIKEY

The octopus api key needed to call the octopus API

## NPM Module

https://www.npmjs.com/package/hubot-octopus-deploy
