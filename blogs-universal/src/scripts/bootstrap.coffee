root = exports ? this

path = require('path')
fs   = require('fs')
process = require('process')

######################
# Script Configuration
######################

# config['database_scripts'] = {"comments": "comments.db", "path": "path.db"}
config = {}
config['source'] = process.cwd()
config['database'] = path.join(config['source'], "contents/database")
config['database_scripts'] = {"path": "path.db"}
config['database_output'] = path.join(config['database'], "bin")

root.config = config
