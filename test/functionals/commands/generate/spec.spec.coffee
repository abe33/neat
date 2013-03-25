require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

testSimpleGenerator 'spec:unit', 'test/units', '.spec.coffee'
testSimpleGenerator 'spec:functional', 'test/functionals', '.spec.coffee'
