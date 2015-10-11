require "printing_methods"
@testing_from_console=true

def run_tests(*extra_action_)
	load "test_data.rb"
	return "Abort testing: Your Rails environment is running in production mode!" if Rails.env.production?

	@testing_from_console=true
	@console_tester||=ConsoleTester.new()
	extra_action_.each { |i_| @console_tester.send(*i_) }
	@console_tester.load_and_run_tests(@tests_list)
	@console_tester.finish_string
	@console_tester.reload_objects=false
end

class ConsoleTester

	attr_accessor :reload_objects
	require "test_helper"

	def initialize(log_sql_=:log_sql)

		@testing_from_console=true
		@logger||=ActiveRecord::Base.logger
		@old_objects||=Object.constants
		@with_sql_log=log_sql_
		@new_constants=[]
	end

	def reload
		@reload_objects=true
	end

	def log
		ActiveRecord::Base.logger=@logger
		self
	end

	def no_log
		ActiveRecord::Base.logger=nil
		self
	end

	def load_and_run_tests(type_, base_=[])
		type_.map do |k_, v_|
			if v_.kind_of?(Hash)
				base_.push(k_.to_s)
				load(k_, base_)
			else
				require_files(base_, k_, v_)
			end
		end
	end

	def finish_string
		line_width=IO.console.winsize[1]-3
		conclusion_array="TESTS COMPLETED"
		side_hash_count = 5
		space_count     =(line_width - conclusion_array.length - side_hash_count*2)/2 
		puts "\e[33m\""+("#"*line_width) + '"'
		puts "\e[33m\""            +
				 ("#"*side_hash_count) +
				 (" "*space_count)     +
				 conclusion_array      + " "+
				 (" "*space_count)     +
				 ("#"*side_hash_count) + '"'
		"#"*line_width
	end

private


	def require_files(base_=[], type_, names_)
		Array(names_).each do |i_|

			_name=i_.to_s
			_test_path   = [Rails.root,"test", *base_, type_.to_s]
			_test_name   = _name + "_test"
			_new_constant= _test_name.camelize.to_sym

			wipe_new_object(_new_constant)
			wipe_new_object(_name.camelize.constantize)          if @reload_objects


			load_file("test"    , _test_name, _test_path)
			load_file(type_.to_s, _name                 )        if @reload_objects

			@new_constants.push(_new_constant)

			#run test and wipe constant
			run_test(_new_constant, :model)      if _test_path.include?("models")
			run_test(_new_constant, :controller) if _test_path.include?("controllers")

			wipe_new_object(_new_constant)

		end
	end


	def load_file(type_, name_, path_=[])
			_loaded = load File.join(*[*path_, name_+".rb"].reject {|s_| s_.nil?})
			lput "====>#{type_.to_s}: " + name_ + ".rb was loaded" if _loaded
	end

	def run_test(obj_, type_)
		_obj=obj_.to_s
		return lput "Test class: #{_obj} not present" if !Object.constants.include?(obj_)

		run_model_test_class(_obj)      if type_==:model
		run_controller_test_class(_obj) if type_==:controller
	end

	def run_model_test_class(_obj)
		_tn=_obj.constantize.new(_obj)
		_tests=_tn.methods.grep /test_/

		ActiveRecord::Base.transaction do
			fput(*running_message(_obj, "setup")) {_tn.setup}
			_tests.map do |i_| 
				fput(*running_message(_obj ,i_.to_s)) {_tn.send(i_)}
			end
			fail
		end

	rescue RuntimeError
	end

	def run_controller_test_class(_obj)
		_tn=_obj.constantize.new(_obj)
		_tests=_tn.methods.grep /test_/

			_tests.map do |i_| 
				_tn.before_setup
				begin
					ActiveRecord::Base.transaction do
						fput(*running_message(_obj, "setup")) {_tn.setup}
						fput(*running_message(_obj ,i_.to_s)) {_tn.send(i_)}
						fail
					end
				rescue RuntimeError
				end
				_tn.before_teardown
		end
	end


	def running_message(obj_, val_)
		["running #{obj_}: #{val_} test", "running #{obj_}: #{val_} test Completed"]
	end

	def wipe_new_object(obj_)
		obj_ = obj_.name.to_sym if obj_.kind_of?(Class)
		if Object.constants.include?(obj_)
			Object.send(:remove_const, obj_)
			@new_constants=@new_constants-[obj_]
		end
	end

	def new_test_objects
		(@new_constants).flatten.uniq.select {|i_| i_.to_s.include?("Test")}
	end

end