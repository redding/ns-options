# Namespace Options

Namespace Options provides a clean interface for defining, organizing and using options. Options are defined through a clean syntax that clearly shows what can be set and read. Options can be organized into namespaces as well. This allows multiple libraries to share common options but still have their own specific options separated. Reading and writing options is as simple as if they were accessors. Furthermore, you can provide your own _type_ class that allows you to provide extended functionality to a simple option.

## Installation

Add the following to your Gemfile and `bundle install`:

    gem 'ns-options'

## Usage

### Defining Options

The basic usage of Namespace Options is to be able to define options for a module or class:

```ruby
module App
  include NsOptions
  options(:settings) do
    option :root, Pathname
    option :stage
  end
end
```

The code above makes the `App` module now have options, accessible through the settings method. The options can be read and written to like a normal accessor:

```ruby
App.settings.root = "/a/path/to/the/root"
App.settings.root.join("log", "test.log") # => "/a/path/to/the/root/log/test.log" (a Pathname instance)

App.settings.stage = "development"
App.settings.stage # => "development"
```

Because the `root` option specified `Pathname` as it's type, the option will always return an instance of `Pathname`. Since the `stage` option did not specify a type, it defaulted to an `Object` which allows it to accept any value. You can define you're own type classes as well and use them:

```ruby
class Stage < String

  def initialize(value)
    super(value.to_s)
  end

  def development?
    self == "development"
  end

end


App.settings.define do
  option :stage, Stage
end

App.settings.stage = "development"
App.settings.stage.development? # => true
App.settings.stage = "test"
App.settings.stage.development? # => false
```

This allows you to add extended functionality to your options and is where a lot of nice usability can be added. Defining your own type classes is explained in more detail later.

### Namespaces

Namespaces allow you to organize your options. With the previously mentioned `App` module and it's options you could create a namespace for another library:

```ruby
module Data # data is a library for retrieving persisted data from some resource

  App.settings.namespace(:data) do
    option :server
  end

  def self.config
    App.settings.data
  end

end
```

Now I can set a server option for data that is separate from the main `App` settings:

```ruby
Data.config.server = "127.0.0.1:1234"

App.settings.server # => NoMethodError
App.settings.data.server # => 127.0.0.1:1234
```

### Less Verbose Definitions

As an alternative to the above definition syntax, you can use an alternate less-verbose syntax:
* `opts` for `options`
* `opt` for `option`
* `ns`  for `namespace`

```ruby
module App
  include NsOptions

  opts :settings do
    opt :root, Pathname
    opt :stage

    ns :other_stuff do
      opt :something
    end
  end
end
```

#### With Classes

Using `NsOptions` on a `Class` uses namespaces to create separate sets of options for every instance of your class created. This allows every instance to have different values for the set of options and not interfere with each other. For example with the following:

```ruby
class User
  include NsOptions
  options(:preferences) do
    option :home_page
  end

end
```

A namespace is created for the `User` class in the same way it works for modules:

```ruby
User.preferences # => NsOptions::Namespace instance
User.preferences.home_page = "/home" # you can set options at this level, though I'm not sure why you would
```

Additionally, `NsOptions` will setup instances of a class to have a _copy_ of their class's namespace.

```ruby
user = User.new
user.preferences.home_page = "/home" # makes a lot more sense to do this
user2 = User.new
user2.preferences.home_page = "/not_home"
user.preferences.home_page == user2.preferences.home_page # => false, they are completely separate
```

The instance level namespaces are deep copies of the class one. This means every option and sub-namespaces will be included. Only values are not copied.

```ruby
class User
  include NsOptions
  options(:preferences) do
    option :home_page
    namespace :view do
      option :background_color, ViewColor
    end
  end

end

User.preferences.home_page = "/home"
user = User.new
user.preferences.home_page # => nil, does not return '/home'
user.preferences.object_id != User.preferences.object_id # => true, they are different objects, just with the same definition
user.preferences.view.background_color = "green"
user.preferences.view.background_color # => returns an instance of ViewColor
```

### Dynamically Defined Options

Not all options have to be defined formally. Though defining an option through the `option` method allows the most functionality and allows for quickly seeing what can be used, Namespace Options allows you to write options that have not been defined:

```ruby
App.settings.logger = Logger.new(App.settings.root.join("log", "test.log"))

App.settings.logger.info("Hello World")
```

Writing to a namespace with a previously undefined option will create a new option. The type class will be defaulted to `Object` as if you didn't provide it. This will allow you to set any value for the option so you have no guarantee on what it's value is and how it can be used.

### Mass Assigning Options

Sometimes, it's convenient to be able to set many options at once. This can be done by calling the `apply` method and giving it a hash of option names with values:

```ruby
class Project
  include NsOptions
  options(:settings) do
    option :file_path
    option :home_page

    namespace(:movie_resolution) do
      option :height, Integer
      option :width, Integer
    end
  end
end

project = Project.new
project.settings.apply({
  :file_path => "/path/to/project",
  :movie_resolution => { :height => 800, :width => 600 }
})

project.settings.file_path                # => "/path/to/project"
project.settings.movie_resolution.height  # => 800
project.settings.movie_resolution.width   # => 600
```

As the example shows, if you have a namespace and have a matching hash, it will automatically apply those values to that namespace. Also, if you include keys that are not defined options for your namespace, new options will be created for the values:

```ruby
project = Project.new
project.settings.apply({ :stereoscopic => true, :not_a_namespace => { :yes => true } })

project.settings.stereoscopic     # => true
project.settings.not_a_namespace  # => { :yes => true }
```

The reverse is also supported, so if you want a `Hash` version of your namespace, just ask your options for it.

```ruby
# a continuation of the previous block of code...
project.settings.to_hash # => { :stereoscopic => true, :not_a_namespace => { :yes => true } }
project.settings.each do |name, value|
  # iterating over your options works as well
end
```

### Lazily eval'd options

Sometimes, you may want to set an option to a value that shouldn't (couldn't) be evaluated until the option is read.  If you set an option equal to a Proc, the value of the option will be whatever the return value of the Proc is at the time the option is read.  Here are some examples:

```ruby
# dynamic value
options(:dynamic) do
  option :rand, :default => Proc.new { rand(1000) }
end

dynamic.rand #=> 347
dynamic.rand #=> 529

# same goes for dynamically defined options
dynamic.not_originally_defined = Proc.new { rand(1000) }
dynamic.not_originally_defined #=> 110
dynamic.not_originally_defined #=> 931
```

```ruby
# self referential value
options(:selfref) do
  option :something, :default => "123"
  option :else, :default => Proc.new { self.something }
end

selfref.something #=> "123"
selfref.else #=> "123"
```

If you really want your option to read and write Procs and not do this lazy eval behavior, just define the option as a Proc option

```ruby
options(:explicit) do
  option :a_proc, Proc, :default => Proc.new { rand(1000) }
end

explicit.a_proc #=> <the proc obj>
```

### Custom Type Classes

As stated previously, type classes is where you can add a lot of functionality and usability to your options. To do this though, understanding what `NsOptions` will do with your type class is important. First, it's important to understand when `NsOptions` will try to _coerce_ a value. This is only done when a value is not a _kind of_ the option's type class or when the value is nil. For example:

```ruby
module App
  include NsOptions
  options :settings do
    option :stage, Stage
  end
end

App.settings.stage = Stage.new("development") # no type coercion is done here, the value is already a Stage

class BetterStage < Stage
  # do something better
end

App.settings.stage = BetterStage.new("test") # again, no type coercion is done, as BetterStage is a kind of Stage

App.setting.stage = nil # nil is never coerced, if you set a value to nil, it's just nil
```

Next, when `NsOptions` chooses to coerce a value with your class, it will always create a new instance of your type class and pass the value as the first argument. Your `initialize` method needs to be defined to handle this:

```ruby
class Root < Pathname
  def initialize(path, app_name)
    super("#{path}/#{app_name}")
  end
end
```

`Root`'s `initialize` method will not work for type coercion. The `app_name` argument will not be provided and Ruby will get angry. To solve this, make the `app_name` not required:

```ruby
class Root < Pathname
  def initialize(path, app_name = nil)
    app_name ||= App.settings.name # this might be one way to solve this
    super("#{path}/#{app_name}")
  end
end
```

With the revised `initialize` method, `NsOptions` will have no problems coercing values for the type class. In some cases the above solution may not work for you, but don't worry. See the _Option Rules_ section for another way to solve this, specifically about the args rule. For an example of a custom type class, the included `NsOptions::Boolean` can be looked at. This is a special case, but it works as a type class with `NsOptions`.

### Custom type class return values

It may be useful to use a custom type class as a silent value handler.  You don't necessarily care that this option is some handler class - you just want flexible ways to set its value and get a meaningful return value when you read it.

When reading option values, NsOptions will first check and see if the option value responds to the `returned_value` method.  If it does, NsOptions will return that value instead of the instance of the type class.  If not it will return the type class instance as normal.

The included `NsOptions::Boolean` handler class does just this to ensure it always returns either `true` or `false`.  Here is another example:

```ruby
class HostedAt
  # sanitized :hosted_at config
  #  remove any trailing '/'
  #  ensure single leading '/'

  def initialize(value)
    @hosted_at = value.sub(/\/+$/, '').sub(/^\/*/, '/')
  end

  def returned_value
    @hosted_at
  end
end

class Thing
  include NsOptions

  options :is do
    option :hosted_at, HostedAt
    option
  end
end

thing = Thing.new
thing.is.hosted_at  # => nil
thing.is.hosted_at = "path/to/resource/"
thing.is.hosted_at  # => "/path/to/resource"
```

### Ruby Classes As A Type Class

`NsOptions` will allow you to use many of Ruby's standard objects as type classes and still handle coercing values appropriately. Typically this is done with ruby's type casting:

```ruby
module Example
  include NsOptions
  options :stuff do
    option :string, String
    option :integer, Integer
    option :float, Float
    option :symbol, Symbol
    option :hash, Hash
    option :array, Array
  end
end

Example.stuff.string = 1
Example.stuff.string # => "1", the same as doing String(1)
Example.stuff.integer = 5.0
Example.stuff.integer # => 5, this time it's Integer(5.0)
Example.stuff.float = "5.0"
Example.stuff.float # => 5.0, same as Float("5.0")
```

`Symbol`, `Hash` and `Array` work, but ruby doesn't provide built in type casting for these.

```ruby
Example.stuff.symbol = "awesome"
Example.stuff.symbol # => :awesome, watch out, this will try calling to_sym on the passed value, so it can error
Example.stuff.hash = { :a => 'b' }
Example.stuff.hash # => returns the same hash, does Hash.new.merge(value)
Example.stuff.array = [ 1, 2, 3 ]
Example.stuff.array # => returns the same array, Array is the only one that works without anything special, Array.new(value)
```

### Option Rules

An option can be defined with certain rules (through a hash) that will extend the behavior of the option.

#### Default Value

The first rule is setting a default value.

```ruby
App.settings do
  option :stage, Stage, :default => "development"
end
App.settings.stage # => instead of nil this will be 'development'
```

A default value runs through the same logic as if you set the value manually, so it will be coerced if necessary.

#### Required

It's also possible to flag an option as _required_.

```ruby
App.settings do
  option :root, :required => true
end

App.settings.required_set? # => false, asking if the required options are set
App.settings.root = "/path/to/somewhere"
App.settings.required_set? # => true
```

To check if an option is set it will simply check if the value is not `nil`. If you are using a custom type class though, you can define an `is_set?` method and this will be used to check if an option is set.

The built in `required_set?` method checks to see if all the options for the namespace that have been marked `:required => true` are set.  It does not recursively check any child namespaces.

#### Args

Another rule that you can specify is args. This allows you to pass more arguments to a type class.

```ruby
class Root < Pathname
  def initialize(path, app_name = nil)
    app_name = app_name.respond_to?(:call) ? app_name.call : app_name
    super("#{path}/#{app_name}")
  end
end

App.settings do
  option :name
  option :root, Root, :args => lambda{ App.settings.name }
end

App.settings.name = "example"
App.settings.root = "/path/to"
App.settings.root # => /path/to/example, uses the args rule to build the path
```

With the args rule, you can have a type class accept more than one argument. The first argument will always be the value to coerce. Any more arguments will be appended on after the value.

## NsOptions::Proxy
Mix in NsOptions::Proxy to any module/class to make it proxy a namespace.  This essentially turns your class into a namespace itself.  You can interact with it just as if it were a namespace object.  For example:

```ruby
module Something
  include NsOptions::Proxy

  # define options directly
  option :foo
  option :bar, :default => "Bar"

  # define sub-namespaces
  namespace :more do
    option :another
  end

end

# handle those options
Something.bar #=> "Bar"
Something.to_hash  #=> {:foo => nil, :bar => "Bar"}
Something.each do |opt_name, opt_value|
  ...
end
```

What's great is that while your Something behaves like a namespace, you can still define methods and add to it just as you would normally in Ruby:

```ruby
module Something
  def self.awesome_bar
    "Awesome #{bar}"
  end
end

Something.awesome_bar  # => "Awesome Bar"
```

And remember, NsOptions is mixed in, so you can go ahead and create a root namespace as you normally would:

```ruby
module Something
  options(:else) do
    option :baz
  end
end
```

## License

Copyright (c) 2011-Present Collin Redding and Team Insight

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
