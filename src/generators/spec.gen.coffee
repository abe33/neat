fs = require 'fs'

{describe, usages} = require '../utils/commands'
{namedEntity} = require '../utils/generators'

usages 'neat generate spec [name]',
describe 'Generates a [name] spec in the specs directory',
spec = namedEntity __filename, 'test/spec', 'spec.coffee'

module.exports = {spec}
