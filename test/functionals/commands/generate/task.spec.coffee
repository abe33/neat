require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

testSimpleGenerator 'task', 'src/tasks', '.cake.coffee'
