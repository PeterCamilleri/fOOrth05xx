require 'rake/testtask'
require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  #rdoc.main = "fOOrth_helper.rb"
  rdoc.rdoc_files = ["lib/fOOrth/fOOrth_class.rb",
                     "tests/fOOrth_class_test.rb",
                     "lib/fOOrth/fOOrth_object.rb",
                     "lib/fOOrth/fOOrth_virtual_machine.rb",
                     "lib/fOOrth/fOOrth_context.rb",
                     "tests/fOOrth_context_test.rb",
                     "lib/fOOrth/fOOrth_sym_entry.rb",
                     "tests/fOOrth_sym_entry_test.rb",
                     "lib/fOOrth/fOOrth_sym_map.rb",
                     "tests/fOOrth_sym_map_test.rb",
                     "lib/fOOrth/fOOrth_sym_hierarchy.rb",
                     "tests/fOOrth_sym_hierarchy_test.rb",
                     "lib/fOOrth/fOOrth_string_source.rb",
                     "tests/fOOrth_string_source_test.rb",
                     "lib/fOOrth/fOOrth_file_source.rb",
                     "tests/fOOrth_file_source_test.rb",
                     "lib/fOOrth/fOOrth_read_point.rb",
                     "lib/fOOrth/fOOrth_helper.rb",
                     "tests/fOOrth_helper_test.rb"]
end

Rake::TestTask.new do |t|
  t.test_files = ["tests/fOOrth_class_test.rb",
                  "tests/fOOrth_context_test.rb",
                  "tests/fOOrth_sym_entry_test.rb", 
                  "tests/fOOrth_sym_map_test.rb", 
                  "tests/fOOrth_sym_hierarchy_test.rb",
                  "tests/fOOrth_string_source_test.rb",
                  "tests/fOOrth_file_source_test.rb",
                  "tests/fOOrth_helper_test.rb"]
  t.verbose = false
end
