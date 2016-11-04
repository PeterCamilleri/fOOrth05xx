require_relative '../lib/fOOrth/fOOrth_class'
require          'minitest/autorun'

class ClassAndObjectTester < MiniTest::Unit::TestCase
  #Special initialize to track rake progress.
  def initialize(*all)
    $do_this_only_one_time = "" unless defined? $do_this_only_one_time
    
    if $do_this_only_one_time != __FILE__
      puts
      puts "Running test file: #{File.split(__FILE__)[1]}" 
      $do_this_only_one_time = __FILE__
    end
    
    super(*all)
  end

  #Create the initial conditions.
  def setup
    XfOOrth::XfOOrthClass._clear_all_classes
    XfOOrth::XfOOrthClass.initialize_classes
  end

  #Test initial conditions created when classes are first created.
  def test_initial_population_of_all_classes
    oc = XfOOrth::XfOOrthClass.object_class
    cc = XfOOrth::XfOOrthClass.class_class
    all = $all_classes
    
    assert_equal(oc, all['Object'])
    assert_equal(cc, all['Class'])
  end
  
  #Verify that class Object is a Class.
  def test_that_Object_is_a_class
    oc = XfOOrth::XfOOrthClass.object_class
    cc = XfOOrth::XfOOrthClass.class_class
    
    assert_equal(oc.fOOrth_class, cc)
  end
  
  #Verify that class Class is a Class.
  def test_that_Class_is_a_class
    cc = XfOOrth::XfOOrthClass.class_class
    
    assert_equal(cc.fOOrth_class, cc)
  end
  
  #Verify that the parent of Class is Object.
  def test_that_Object_is_the_parent_of_Class
    oc = XfOOrth::XfOOrthClass.object_class
    cc = XfOOrth::XfOOrthClass.class_class
    
    assert_equal(cc.fOOrth_parent, oc)
  end
  
  #Verify that the Object has no parent.
  def test_that_Object_has_no_parent
    oc = XfOOrth::XfOOrthClass.object_class
    
    assert_equal(oc.fOOrth_parent, nil)
  end
  
  #Verify class names.
  def test_that_classes_are_named
    oc = XfOOrth::XfOOrthClass.object_class
    cc = XfOOrth::XfOOrthClass.class_class
    
    assert_equal(oc.name, 'Object')
    assert_equal(cc.name, 'Class')
  end
  
  #Verify an instance of Object
  def test_an_instance_of_Object
    oc = XfOOrth::XfOOrthClass.object_class
    oi = oc.create_fOOrth_instance(nil)
    
    assert_equal(oi.fOOrth_class, oc)
    assert_equal(oi.fOOrth_class.name, 'Object')
    assert_equal(oi.name, "Object instance.")
  end
  
  #Verify a subclass of Object
  def test_that_a_subclass_is_created
    oc = XfOOrth::XfOOrthClass.object_class
    cc = XfOOrth::XfOOrthClass.class_class
    mc = oc.create_fOOrth_subclass(nil, 'MyClass')
    
    assert_equal(mc.fOOrth_class, cc)
    assert_equal(mc.name, 'MyClass')
    assert_equal(mc.fOOrth_parent, oc)
  end
  
  #Verify an instance of MyClass
  def test_an_instance_of_a_subclass
    oc = XfOOrth::XfOOrthClass.object_class
    mc = oc.create_fOOrth_subclass(nil, 'MyClass')
    im = mc.create_fOOrth_instance(nil)
    
    assert_equal(im.fOOrth_class, mc)
    assert_equal(im.fOOrth_class.name, 'MyClass')
    assert_equal(im.name, "MyClass instance.")
  end
  
  #Verify a method added to Object (part 1/2)
  def test_a_method_added_to_Object1
    oc = XfOOrth::XfOOrthClass.object_class
    oc.add_shared_method(:testing) {|vm| 123}
    oi = oc.create_fOOrth_instance(nil)
    
    refute(oi.respond_to?(:testing))
    assert_equal(123, oi.testing(nil))
    assert(oi.respond_to?(:testing))
  end

  #Verify a method added to Object (part 2/2)
  def test_a_method_added_to_Object2
    oc = XfOOrth::XfOOrthClass.object_class
    oi = oc.create_fOOrth_instance(nil)
    oc.add_shared_method(:testing) {|vm| 123}
    
    refute(oi.respond_to?(:testing))
    assert_equal(123, oi.testing(nil))
    assert(oi.respond_to?(:testing))
  end
  
  #Verify a method inherited by a subclass (part 1/3)
  def test_a_method_inherited_into_MyClass1
    oc = XfOOrth::XfOOrthClass.object_class
    oc.add_shared_method(:testing) {|vm| 123}
    mc = oc.create_fOOrth_subclass(nil, 'MyClass')
    im = mc.create_fOOrth_instance(nil)
    
    refute(im.respond_to?(:testing))
    assert_equal(123, im.testing(nil))
    assert(im.respond_to?(:testing))
  end
  
  #Verify a method inherited by a subclass (part 2/3)
  def test_a_method_inherited_into_MyClass2
    oc = XfOOrth::XfOOrthClass.object_class
    mc = oc.create_fOOrth_subclass(nil, 'MyClass')
    oc.add_shared_method(:testing) {|vm| 123}
    im = mc.create_fOOrth_instance(nil)
    
    refute(im.respond_to?(:testing))
    assert_equal(123, im.testing(nil))
    assert(im.respond_to?(:testing))
  end
  
  #Verify a method inherited by a subclass (part 3/3)
  def test_a_method_inherited_into_MyClass3
    oc = XfOOrth::XfOOrthClass.object_class
    mc = oc.create_fOOrth_subclass(nil, 'MyClass')
    im = mc.create_fOOrth_instance(nil)
    oc.add_shared_method(:testing) {|vm| 123}
    
    refute(im.respond_to?(:testing))
    assert_equal(123, im.testing(nil))
    assert(im.respond_to?(:testing))
  end
  
  #Verify a method added to Object and purged from MyClass
  def test_a_method_purged_from_MyClass
    oc = XfOOrth::XfOOrthClass.object_class
    mc = oc.create_fOOrth_subclass(nil, 'MyClass')
    oc.add_shared_method(:testing) {|vm| 123}
    im = mc.create_fOOrth_instance(nil)
    
    refute(im.respond_to?(:testing))
    assert_equal(123, im.testing(nil))
    assert(im.respond_to?(:testing))
    
    mc.purge_shared_method(:testing)
    
    refute(im.respond_to?(:testing))
  end
  
  #Verify method change propagation.
  def test_method_change_propagation
    oc = XfOOrth::XfOOrthClass.object_class
    mc = oc.create_fOOrth_subclass(nil, 'MyClass')
    oc.add_shared_method(:testing) {|vm| 123}
    im = mc.create_fOOrth_instance(nil)
    
    refute(im.respond_to?(:testing))
    assert_equal(123, im.testing(nil))
    assert(im.respond_to?(:testing))
    
    oc.add_shared_method(:testing) {|vm| 246}
    
    refute(im.respond_to?(:testing))
    assert_equal(246, im.testing(nil))
    assert(im.respond_to?(:testing))
  end
end