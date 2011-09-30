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
  include NsOptions::HasOptions
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

Because the `root` option specified `Pathname` as it's type, the option will always return an instance of `Pathname`. Since the `stage` option did not specify a type, it defaulted to a `String`. You can define you're own type classes as well and use them:

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

This allows you to add extended functionality to your options. The only condition is that the `initialize` accepts a single argument. This argument is always the value that was used with the writer. For the above, the `Stage` class received `"development"` and `"test"` in it's initialize method.

### Namespaces

Namespaces allow you to organize and share options. With the previously mentioned `App` module and it's options you could create a namespace for another library:

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

App.server # => NoMethodError
```

Since the data namespace was created from the `App` settings (which is also a namespace) it can access it's parent's options:

```ruby
Data.config.stage # => "test", or whatever App.settings.stage would return
```

Namespaces and their ability to read their parent's options is internally used by Namespace Options. When you add options to a class like so:

```ruby
class User
  include NsOptions::HasOptions
  options(:preferences) do
    option :home_page
  end

end
```

A namespace will be created for the `User` class itself. Which can have options added and even set. Once a user instance is created, it will create a child namespace from the classes. Thus, it will be able to access and use any options on the class:

```ruby
user = User.new
user.preferences.home_page = "/home"
```

### Dynamically Defined Options

Not all options have to be defined formally. Though defining an option through the `option` method allows the most functionality and allows for quickly seeing what can be used, Namespace Options allows you to write options that have not been defined:

```ruby
App.settings.logger = Logger.new(App.settings.root.join("log", "test.log"))

App.settings.logger.info("Hello World")
```

Writing to a namespace with a previously undefined option will create a new option. The type class will be pulled from whatever object you write with. In the above case, the option defined would have it's type class set to `Logger` and would try to convert any new values to an instance of `Logger`.

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