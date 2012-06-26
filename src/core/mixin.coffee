# The `Mixin` function takes an object and decorates it with
# the mixins functionalities.
#
#     Serializable = Mixin
#       toSource: -> # ...
#       fromSource: (string) -> # ...
#
#     class Dummy
#       @include Serializable
Mixin = (mixin) ->
  # Keep a reference to the original mixin `included` hook.
  # The mixin `included` hook is called whenever the mixin
  # is used to decorate a class.
  #
  #     Serializable = Mixin
  #       included: (ctor) ->
  #         # Do something with ctor
  included = mixin.included

  # The mixin `included` hook is redefine to handle the insertion
  # of the mixin in the `__mixins__` array of the decorated constructor.
  mixin.included = (base) ->
    # The original mixin `included` hook is triggered.
    included? base

    # Register this mixin in the `__mixins__` array of the decorated
    # class.
    base.__mixins__ ?= []
    base.__mixins__.push mixin unless mixin in base.__mixins__

  # Features added to the mixin by the `Mixin` function are excluded
  # of the decoration process of the `Module.include` method.
  mixin.excluded = ["isMixinOf", "__definition__"]

  ##### Mixin.isMixinOf

  # Returns `true` if the passed-in object's constructor have been
  # decorated with the current mixin.
  #
  #     Serializable = Mixin
  #       toSource: -> # ...
  #       fromSource: (string) -> # ...
  #
  #     class Dummy
  #       @include Serializable
  #
  #     dummy = new Dummy
  #     Serializable.isMixinOf dummy # true
  mixin.isMixinOf = (object) ->
    mixin in object.constructor.__mixins__ if object.constructor.__mixins__?

  mixin

module.exports = Mixin
