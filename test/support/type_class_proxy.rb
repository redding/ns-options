require 'ns-options'

class DefaultTypeClass < Struct.new(:value); end

class TypeClassProxy
  include NsOptions::Proxy

  option_type_class DefaultTypeClass

  opt :value1             # test that DefaultTypeClass is used

  ns :more do
    opt :more1            # that it is used recursively
  end

  ns :strings do
    opt_type_class String
    opt :string1          # that it can be over written
  end

  ns :objs, Object do
    type_class Object
    opt :obj1             # and that it can be reset to the default
  end

end

class InheritedTypeClassProxy < TypeClassProxy; end
class DoubleInheritedTypeClassProxy < InheritedTypeClassProxy; end
