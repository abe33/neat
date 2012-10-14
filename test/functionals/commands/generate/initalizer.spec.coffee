require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

testSimpleGenerator 'initializer', 'src/config/initializers', '.coffee'
