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

```
user1>> hubot octo status acme
hubot>> Retrieving status for you now...
        @user1 Top 5 matches for acme
                               Latest           DI                    TI                   PR            
         Provider.Acme.Endpoint  1.1.3.59 (ok)   1.1.3.59 (success)   1.1.3.55 (success)   1.1.3.55 (success)
         
                           Latest     Corporate         DI          DI-TI          TI          PR      
         Facme.Endpoint  0.0.6 (ok)   unknown (unknown)   unknown (unknown)   unknown (unknown)   0.0.6 (success)   0.0.6 (success) 
         
                               Latest           DI              TI               PR          Corporate       DI-TI      
         Member.Endpoint  1.2.0.95 (ok)   1.2.0.95 (success)   1.2.0.94-a (success)   1.2.0.94-a (success)   unknown (unknown)   unknown (unknown) 
         
                              Latest       Corporate          DI           DI-TI            TI               PR         
         Common.Security  1.0.2-rc1 (ok)   unknown (unknown)   1.0.2-rc1 (success)   unknown (unknown)   1.0.2-rc64 (success)   1.0.2-rc64 (success) 
         
                         Latest        DI                      TI            PR        Corporate    
         ms2.Endpoint  0.1.0 (ok)   0.1.0 (success)   unknown (unknown)   unknown (unknown)   unknown (unknown) 
```

## Configuration

### HUBOT_OCTO_ENDPOINT

This environment variable is the base url of your octopus installation. For example, `http://octopus.whereeveritcouldbe`

### HUBOT_OCTO_APIKEY

The octopus api key needed to call the octopus API

## NPM Module

https://www.npmjs.com/package/hubot-octopus-deploy
