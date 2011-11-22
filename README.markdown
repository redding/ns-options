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

### Custom Type Classes

TODO

### Ruby Classes As A Type Class

TODO


## License

Copyright (c) 2011 Collin Redding and Team Insight

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