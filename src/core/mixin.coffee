Mixin = (mixin) ->
  included = mixin.included

  mixin.included = (base) ->
    included? base

    base.__mixins__ ?= []
    base.__mixins__.push mixin unless mixin in base.__mixins__

  mixin.excluded = ["isMixinOf", "__definition__"]
  mixin.isMixinOf = (object) ->
    mixin in object.constructor.__mixins__ if object.constructor.__mixins__?

  mixin

module.exports = Mixin
