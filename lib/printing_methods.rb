module PrintingMethods

	# define common functions for the whole application
	def lput(*args_)
		line_length=IO::console.winsize[1]-1
		#_output= args_.blank? ? args_ : ["NOTHING TO PRINT"]

		puts green_string("—"*line_length)
		puts yellow_string("=========>") + cyan_string(self.class.to_s)
		puts yellow_string("=========>") + cyan_string(caller[0])
		puts *args_
		puts red_string("—"*line_length)
	end

	def fput(arg0_=nil, arg1_=nil, ret=nil)
		line_length=IO::console.winsize[1]-1
		puts green_string("—"*line_length)
		puts yellow_string("=========>") + cyan_string(self.class.to_s)
		puts yellow_string("=========>") + cyan_string(caller[0])
		puts red_string("====>") + green_string(arg0_.to_s) if arg0_

		ret ||= yield if block_given?

		puts red_string("====>") + green_string(arg1_.to_s) if arg1_
		puts red_string("—"*line_length)
		return ret   if ret
	end

	def green_string(str)
		"\e[32m"+ str +"\e[0m"
	end

	def yellow_string(str)
		"\e[33m"+ str +"\e[0m"
	end

	def cyan_string(str)
		"\e[36m"+ str +"\e[0m"
	end

	def red_string(str)
		"\e[32m"+ str +"\e[0m"
	end

end
