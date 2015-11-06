#coding:utf-8

module AIAuto

	class StartTimeNotSetException < StandardError; end
	class CaseNotSetException < StandardError; end
	class CaseAssertException < StandardError; end

	RESULT_LOG_PATH = "result"
	RESULT_SCREENSHOT_PATH_NAME = "screenshot"

	class AILog

		

		attr_reader :now_run_id
		attr_reader :now_run_name
		attr_reader :now_case_id
		attr_reader :now_case_name

		def initialize browser = nil
			@browser = browser
			log_file_path = prepare_path()
			@logger_file = Logger.new(log_file_path)
			@logger_file.level = Logger::INFO
			@logger_file.datetime_format = "%Y-%m-%d %H:%M:%S"
			@logger = Logger.new(STDOUT)
			@logger.level = Logger::INFO
			@logger.datetime_format = "%Y-%m-%d %H:%M:%S"
		end



				
		def log msg
			write_log :info, msg
		end

		def warn msg, if_screenshot = false
			msg += "(!Screenshot:#{screenshot_png()})" if if_screenshot
			write_log :warn, msg
		end

		def error error, msg=nil
			if error.nil?
				@logger.error("error: null, message: #{msg}")
				return
			end
			screen_pic = screenshot_png()
			log_str = "#{msg.nil? ? "null":msg}"
			log_str += "\n\terror: #{error.message}" if not error.nil?	
			log_str += "\n\tscreenshot: #{screen_pic}" if not screen_pic.nil?
			log_str += "\n\tbacktrace: #{error.backtrace.join("\n")}" if not error.backtrace.nil?
			write_log :error, log_str
			
		end

		def project_log_start task_name, task_id = nil
			@now_task_id = task_id
			@now_task_name = task_name
			@project_start_time = Time.now
			@project_case_result = []
			@project_run_stat = {:task_name => task_name, :task_id => task_id, :start_time => @project_start_time}
			@project_run_stat[:case_num] = @project_run_stat[:success_case_num] = @project_run_stat[:fail_case_num] = 0
			msg = "[Project]start project: #{@now_task_name}, Time: #{@project_start_time}" 
			log(msg)
		end

		def project_log_end
			raise StartTimeNotSetException.new("case_log_start has been executed, start_time is nil") if @project_start_time.nil?
			
			# log [Project]end
			@project_end_time = Time.now
			@eclapse = @project_end_time - @project_start_time
			msg = "[Project]end project: #{@now_task_name}, eclapse: #{@eclapse}, start_time:#{@project_start_time}, end_time:#{@project_end_time}"
			log msg

			# log details
			puts "-------------------------------------------------"
			@project_case_result.each do |p| 
				puts "#{p[:class_name]}.#{p[:method_name]}\t#{p[:result]?"Pass":"Fail"}\tuse #{p[:eclapse]}s"
			end

			# log statics
			@project_run_stat[:end_time] = Time.now
			@project_run_stat[:eclapse] = @project_run_stat[:end_time] - @project_run_stat[:start_time]
			puts "=============================================="
			puts "run project #{@project_run_stat[:task_name]}"
			puts "#{@project_run_stat[:eclapse]}s eclapse, started at #{@project_run_stat[:start_time]}"
			puts "#{@project_run_stat[:case_num]} tests total, #{@project_run_stat[:success_case_num]} passed, #{@project_run_stat[:fail_case_num]} failed."
			puts "=============================================="

			@now_task_id = nil
			@now_task_name = nil
			@project_start_time = nil
			@project_end_time = nil
			@project_case_result = []
			@project_run_stat = {}
		end

		def case_log_start class_name, method_name, data = nil
			@now_case = {:class_name => class_name, :method_name => method_name, :data => data}
			@now_case[:start_time] = Time.now
			@now_case[:status] = "Start"
			msg = "[Case](#{@now_case[:class_name]}_#{@now_case[:method_name]}): Start At #{@now_case[:start_time]}"
			log msg
		end


		def case_log_end result = true, message = nil, error = nil
			@now_case[:end_time] = Time.now
			@now_case[:eclapse] = @now_case[:end_time] - @now_case[:start_time]

			if @now_case[:result].nil?
				@now_case[:result] = result
				@now_case[:rst_log] = message
			end


			msg = "[Case](#{@now_case[:class_name]}_#{@now_case[:method_name]}): End At #{@now_case[:end_time]}, Result: #{@now_case[:result]}"
			if result
				log msg
			else
				if error.nil?
					error = StandardError.new(@now_case[:rst_log])
				end
				error error, msg
			end

			@project_run_stat[:case_num] += 1
			if result
				@project_run_stat[:success_case_num] += 1
			else
				@project_run_stat[:fail_case_num] += 1
			end
			@project_case_result << @now_case
			@now_case = nil
		end

=begin

		def case_log_start script_id, script_name, data_id, data_name, data = nil


			@now_case = {:script_id => script_id, :script_name => script_name, :data_id => data_id, :data_name => data_name}
			@now_case[:start_time] = Time.now
			@now_case[:status] = "Start"
			msg = "[Case]Start: name: #{@now_case[:script_name]}, data: #{@now_case[:data_name]}, id: #{@now_case[:script_id]}/#{@now_case[:data_id]}, start_time: #{@now_case[:start_time]}"
			if not data.nil?
				msg += ", data: #{data}"
			end
			log msg
		end

		def case_log_end result = true, message = nil, error = nil
			@now_case[:end_time] = Time.now
			@now_case[:eclapse] = @now_case[:end_time] - @now_case[:start_time]
			@now_case[:result] = result
			@now_case[:rst_log] = message
			msg = "[Case]End: name: #{@now_case[:script_name]}, data: #{@now_case[:data_name]}, end_time: #{@now_case[:end_time]}, eclapse: #{@now_case[:eclapse]}"
			if result
				log msg
			else
				error error, "[Case]name: #{@now_case[:script_name]}, data: #{@now_case[:data_name]}, Error: #{message}"
			end
			@project_case_result << @now_case
			@now_case = nil

		end
=end

		def step_log step_name, step_desc, result = true
			if @now_step_start_time.nil?
				@now_step_start_time = @now_case[:start_time]
			end
			eclapse = Time.now - @now_step_start_time
			msg = "[Step]#{step_name}:#{step_desc}, result: #{result}, #{eclapse}s"
			if result
				log msg
			else
				warn msg, false
				if not @now_case.nil?
					@now_case[:result] = false
					if @now_case[:rst_log].nil?
						@now_case[:rst_log] = "Step Error: #{msg}"
					else
						@now_case[:rst_log] += "\Step Error: #{msg}"
					end
				end
			end

		end

		def assert_true_log condition, message
			if condition
				log "[Assert][Pass]#{message}"
			else
				warn "[Assert][Fail]#{message}", false
				if not @now_case.nil?
					@now_case[:result] = false
					if @now_case[:rst_log].nil?
						@now_case[:rst_log] = "Assert Error: #{message}"
					else
						@now_case[:rst_log] += "\nAssert Error: #{message}"
					end
				end
			end
		end


		private
		def write_log method, msg
			@logger.__send__ method, msg
			@logger_file.__send__ method, msg if not @logger_file.nil?
		end

		def screenshot_png
			if not @browser.nil?
				screen_pic = @screen_pic_path + "/screenshot_#{Time.now.strftime('%m_%d_%H_%M_%S')}_#{rand(1000)}.png"
				@browser.driver.save_screenshot screen_pic
				return screen_pic
			else
				raise "Can't find browser object for screenshot"
			end
		end


		def recursive_delete(dir)
			files = []
		  	Dir.foreach(dir) do |fname|
		    	next if fname == '.' || fname == '..'
		    	path = dir + '/' + fname
		    	if File.directory?(path)
		      		#puts "dir #{path}"
		      		recursive_delete(path)
		    	else
		      		#puts "file #{path}"
		      		files << path
		    	end
		  	end
		  	files.each do |path|
		    #puts "delete file #{path}"
		    	File.delete(path)
		  	end
		  	#puts "delete dir #{dir}"
		  	Dir.rmdir(dir)
		end
		def prepare_path
			@log_path = AIAuto::RESULT_LOG_PATH
			@screen_pic_path = @log_path + File::Separator + RESULT_SCREENSHOT_PATH_NAME
			if(Dir.exists? @log_path)
				#recursive_delete(@log_path)
			end
			Dir.mkdir(@log_path) if not Dir.exists? @log_path
			Dir.mkdir(@screen_pic_path) if not Dir.exists? @screen_pic_path

			return @log_path + File::Separator + "result.log"

		end

		
	end
end