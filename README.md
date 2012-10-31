# NsOptions

NsOptions provides an API for defining, organizing and using options.  Use namespaces to organize options.  Read and write option values using accessors.

## Usage

```ruby
require 'ns-options'

module App
  include NsOptions

  options(:settings) do
    option :root, Pathname
    option :stage
  end
end

App.settings.root = "/a/path/to/the/root"
App.settings.root.join("log", "test.log") #=> "/a/path/to/the/root/log/test.log" (a Pathname instance)

App.settings.stage = "development"
App.settings.stage #=> "development"
```

The code above defines a `settings` reader on `App`. The options can be read and written to using their accessors

### Namespaces

```ruby
options(:settings) do

  namespace :grouped_stuff do
    option :something
    option :something_else
  end

end
```

Namespaces allow you to organize your options.  You access the namespace and its options through their accessors.

```ruby
App.settings.grouped_stuff.something = 1
App.settings.grouped_stuff.something # => 1
```

### Less Verbose Definitions

As an alternative to the above definition syntax, you can use an alternate less-verbose syntax:

* `opts` for `options`
* `opt` for `option`
* `ns`  for `namespace`

```ruby
require 'ns-options'

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

### Dynamically Defined Options

Not all options have to be defined formally ahead of time.  You can write any option value you like at any time.

```ruby
App.settings.a_value #=> NoMethodError: undefined method `a_value'...
App.settings.a_value = 1
App.settings.a_value #=> 1
```

### Mass Assigning Options

Sometimes, it's convenient to be able to set many options at once. This can be done by calling the `apply` method and giving it a hash of option names with values.  You can even give it keys that aren't pre-defined options - new options will be created for them

```ruby
App.settings.apply({
  :root      => "/path/to/project",
  :stage     => "development"
  :new_value => 1
})

App.settings.root      #=> "/path/to/project"
App.settings.stage     #=> "development"
App.settings.new_value #=> 1
```

To get a hash of values for a namespace, just call its `to_hash` method.

## Class Behavior

Using `NsOptions` on a `Class` uses namespaces to create separate sets of options for every instance of your class. This different instances to have different options values but share the same definition.

To illustrate:

```ruby
class User
  include NsOptions
  options(:preferences) do
    option :home_page
  end

end

User.preferences # => NsOptions::Namespace instance
```

A `preferences` namespace is created for the `User` class.  For each instiance of `User` created, `NsOptions` will setup an identical _copy_ of their class's namespace.  However, each instance sets and maintains unique option values.

```ruby
user1 = User.new
user1.preferences.home_page = "/home"

user2 = User.new
user2.preferences.home_page = "/not_home"

user.preferences.home_page == user2.preferences.home_page #=> false
```

## Options

### Type Classes

Options can be defined with a given "type class".  If none is specified, `Object` is used.

```ruby
options :settings do
  option :opt1
  option :opt2, MyCustomTypeClass
end
```

Understanding what NsOptions will do with your type class is important.  First, option values will be cast to your type class.  If you write a value that is not of a matching type, NsOptions will try to _coerce_ the value.

```ruby
# no type coercion is done here, the value is of the right type
settings.opt2 = MyCustomTypeClass.new(123)

class BetterCustomTypeClass < MyCustomTypeClass; end

# again, no type coercion is done, as BetterCustomTypeClass is a kind of MyCustomTypeClass
settings.opt2 = BetterCustomTypeClass.new(456)

# here, type coercion is performed
# this is the equivalent of doing: `settings.opt2 = MyCustomTypeClass.new(789)`
settings.opt2 = 789

# nil is never coerced, if you set a value to nil, it's just nil
App.setting.stage = nil
```

For type coercion to work, your type class's initializer must work given only a single argument.

### Ruby Classes As A Type Class

NsOptions will allow you to use many of Ruby's standard objects as type classes and still handle coercing values appropriately.

```ruby
module Example
  include NsOptions

  options :stuff do
    option :string,  String
    option :integer, Integer
    option :float,   Float
    option :symbol,  Symbol
    option :hash,    Hash
    option :array,   Array
  end
end

Example.stuff.string  = 1
Example.stuff.string  #=> "1", the same as doing String(1)
Example.stuff.integer = 5.0
Example.stuff.integer # => 5, this time it's Integer(5.0)
Example.stuff.float   = "5.0"
Example.stuff.float   #=> 5.0, same as Float("5.0")

Example.stuff.symbol = "awesome"
Example.stuff.symbol #=> :awesome
Example.stuff.hash   = { :a => 'b' }
Example.stuff.hash   # => returns the same hash
Example.stuff.array  = [ 1, 2, 3 ]
Example.stuff.array  # => returns the same array
```

### Rules

An option can be defined with certain rules that extend the behavior of the option.

#### Default Value

```ruby
settings do
  option :opt1, :default => "development"
end
settings.opt1 #=> 'development'
```

A default value runs through the same logic as if you set the value manually, so it will be coerced if necessary.

#### Required

```ruby
settings do
  option :opt1, :required => true
end

settings.required_set? #=> false
settings.root = "/path/to/somewhere"
settings.required_set? #=> true
```

To check if an option is set it will simply check if the value is not `nil`. If you are using a custom type class though, you can define an `is_set?` method and this will be used to check if an option is set.

The built in `required_set?` method checks to see if all the options for the namespace that have been marked `:required => true` are set.  It will recursively check any sub-namespaces.

#### Args

Another rule that you can specify is args.

```ruby
class MyCustomTypeClass
  def initialize(value, arg1, arg2); end
end

settings do
  option :opt1, MyCustomTypeClass, :args => lambda{ ["arg 1's value", "arg 2's value"] }
end

# equivalent to: `settings.opt1 = MyCustomTypeClass.new("a value", "arg 1's value", "arg 2's value")
settings.opt1 = 'a value'
```

This allows you to pass additional arguments when coercing option values.  The first argument will always be the value to coerce. Any additional arguments will be appended on after the value when calling the initializer.


### Lazily eval'd options

Sometimes, you may want to set an option to a value that shouldn't be evaluated until the option is read.  If you set an option equal to a `Proc`, the value of the option will be whatever the return value of the Proc is at the time the option is read.

Here are some examples:

```ruby
# dynamic value
options(:dynamic) do
  option :rand, :default => Proc.new { rand(1000) }
end

dynamic.rand #=> 347
dynamic.rand #=> 529


# self referential value
options(:selfref) do
  option :something, :default => "123"
  option :else, :default => Proc.new { self.something }
end

selfref.something #=> "123"
selfref.else #=> "123"
selfref.something = 456
selfref.else #=> 456
```

If you really want your option to read and write Procs and not do this lazy eval behavior, just define the option with a `Proc` type class.

```ruby
options(:explicit) do
  option :a_proc, Proc, :default => Proc.new { rand(1000) }
end

explicit.a_proc #=> <the proc obj>
```

## NsOptions::Proxy

Mix in NsOptions::Proxy to any module/class to make it proxy a namespace.  This essentially turns your receiver into a namespace - you can interact with it just as if it were a namespace object.  For example:

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

While your `Something` behaves like a namespace, you can still define methods and add to it just as you would normally in Ruby:

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

### Proxy initialization

Mixing in Proxy will add a default initializer for you as well.  This initializer allows you to call `new` on your proxy, passing it a hash of key-values.  These key values will be applied to the proxy using the `Namespace#apply` logic.  This allows you to use Proxy objects as option types and maintain the option type-casting and defaulting behavior.

```ruby
module Things
  include NsOptions::Proxy

  option :one
  option :two
end

# proxy defines a `new` method that takes a hash arg and
# applies it to the proxy
t = Thing.new(:one => 1, :two => 2, :three => 3)

# the values have been applied
t.to_hash  # => {:one => 1, :two => 2, :three => 3}
```

## Installation

Add this line to your application's Gemfile:

    gem 'ns-options'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ns-options

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
