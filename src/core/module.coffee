#@toc

# Modules allow polymorphism through mixins.
#
# A Mixin is an object whose properties will
# be used to decorate a class prototype.
#
#     Serializable =
#       toSource: -> # ...
#       fromSource: (string) -> # ...
#
#     Cloneable =
#       clone: -> # ...
#

## Module

# The `Module` class is a base class that you can extend
# to create classes with polymorphism ability.
class Module
  #### Class Members

  ##### Module.include

  # Call the static `@include` method in your class body
  # to specify the mixins that the class will implement.
  #
  #     class MyModule extends Module
  #       @include Serializable, Cloneable, Suspendable
  #
  #       # rest of the class definition...
  #
  @include: (mixins...) ->

    # Calling `super` inside a mixin method that overides
    # a inherited method will fail. To resolve it, a `@super`
    # method is provided on instances. And to avoid issues
    # when accessing the constructor of the overridden method
    # in a subclass, the constructor of a mixin method (the class
    # the method was originally mixed in) is registered in a hash
    # stored on the prototype.
    #
    # A copy the hash is made each time the `mixins` method is called.
    # It prevents the hash of a parent class to be affected by changes
    # made in child class.
    @__superOf__ = @__superOf__.concat()

    __excluded__ = ["constructorHook", "included", "excluded"]
    for mixin in mixins
      excluded = if mixin.excluded?
        __excluded__.concat mixin.excluded
      else
        __excluded__.concat()

      # Each member of each mixin is added to the current class
      # prototype, unless the member is part of the excluded array.
      for key, value of mixin when key not in excluded
        @::[key] = value

        # The current class is registered as constructor for
        # for the mixed method.
        @__superOf__[key] = @__super__ if typeof value is 'function'

      # Mixins can provide a function called `constructorHook`.
      # That function will be stored in a specific prototype
      # property and then triggered at the end of the `Module`
      # constructor.
      if mixin.constructorHook?
        hook = mixin.constructorHook
        @__hooks__ = @__hooks__.concat hook

    # The mixin is notified of its inclusion at the end of the process.
    mixin.included? this
    this

  ##### Module.\_\_hooks\_\_

  # Stores the mixins constructor hooks.
  @__hooks__: []

  ##### Module.\_\_superOf\_\_

  # Stores the respective super objects of mixed methods.
  @__superOf__: {}

  #### Instance Members

  ##### Module::preventConstructorHooksInModule

  # When `preventConstructorHooksInModule` is `true`, the `Module`
  # constructor will not triggers the constructor hooks, allowing
  # a subclass to handle the hooks in its own constructor.
  #
  # Subclasses that prevent the `Module` constructor to trigger
  # the hooks should provide the same kind of guards in their
  # constructor to allow their subclasses to do so.
  preventConstructorHooksInModule: false

  ##### Module::constructor

  # The `Module` constructor behavior is to automatically
  # triggers the constructor hooks.
  constructor: ->
    @triggerConstructorHooks() unless @preventConstructorHooksInModule

  ##### Module::triggerConstructorHooks

  # Loop through all the constructor hooks and call
  # them with the current object as context.
  triggerConstructorHooks: ->
    hook.call this for hook in @constructor.__hooks__

  ##### Module::super

  # Use `@super "methodName"` in a mixin's function to call the
  # super function of the specified method.
  super: (method, args...) ->
    @constructor.__superOf__[method]?[method]?.apply this, args

module.exports = Module
