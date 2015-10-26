#coding:utf-8

module AIAuto

	class StartTimeNotSetException < StandardError; end
	class CaseNotSetException < StandardError; end
	class CaseAssertException < StandardError; end

	class AILog

		attr_reader :now_run_id
		attr_reader :now_run_name
		attr_reader :now_case_id
		attr_reader :now_case_name

		def initialize	path = nil, browser = nil
			@browser = browser
			if not path.nil?
				if(not Dir.exists? path)
					Dir.mkdir(path)
				end
				@screen_pic_path = path + "/screenshot"
				if(not Dir.exists? @screen_pic_path)
					Dir.mkdir(@screen_pic_path)
				end
				@logger_file = Logger.new(path + "/result.log")
				@logger_file.level = Logger::INFO
				@logger_file.datetime_format = "%Y-%m-%d %H:%M:%S"
			end
			@logger = Logger.new(STDOUT)
			@logger.level = Logger::INFO
			@logger.datetime_format = "%Y-%m-%d %H:%M:%S"
		end

				
		def log msg
			@logger.info msg
			@logger_file.info(msg) if not @logger_file.nil?
		end

		def warn msg, screen_pic = nil
			if screen_pic.nil?
				@logger.warn(msg)
				@logger_file.warn(msg) if not @logger_file.nil?
			else
				@logger.warn("#{msg}(!Screenshot:#{screen_pic})")
				@logger_file.warn("#{msg}(!Screenshot:#{screen_pic})") if not @logger_file.nil?
			end
		end

		def error error, msg=nil
			
			if error.nil?
				@logger.error("error: null, message: #{msg}")
			end
			if not @browser.nil?


				time = Time.gm(2005, 12, 31, 13, 22, 33)
				date_and_time = '%d_%Y_%H_%M_%S'
				time.strftime(date_and_time) 
				screen_pic = @screen_pic_path + "/screenshot_#{time.strftime(date_and_time)}_#{rand(1000)}.png"
				@browser.driver.save_screenshot screen_pic
			end

			log_str = "message: #{msg.nil? ? "null":msg}"
			log_str += "\n\terror: #{error.message}" if not error.nil?	
			log_str += "\n\tscreenshot: #{screen_pic}" if not screen_pic.nil?
			log_str += "\n\tbacktrace: #{error.backtrace.join("\n")}" if not error.backtrace.nil?
			

			@logger.error(log_str)
			@logger_file.error(log_str)
		end

		def project_log_start run_id, run_name
			@now_run_id = run_id
			@now_run_name = run_name
			@project_start_time = Time.now
			msg = "[Project]start project: #{run_name} and ID: #{run_id}"
			@logger.info msg
			@logger_file.info(msg) if not @logger_file.nil?
		end

		def project_log_end run_id, run_name
			@now_run_id = nil
			@now_run_name = nil
			raise StartTimeNotSetException.new("case_log_start has been executed, start_time is nil") if @project_start_time.nil?
			project_end_time = Time.now
			eclapse = project_end_time - @project_start_time
			msg = "[Project]end project: #{run_name} and ID: #{run_id}, eclapse: #{eclapse}"
			@logger.info msg
			@logger_file.info(msg) if not @logger_file.nil?
			@project_start_time = nil
		end


		def case_log_start case_id, case_name
			@now_case_id = case_id
			@now_case_name = case_name
			@start_time = Time.now
			@now_step_start_time = nil
			msg = "[Case]Start: ID: #{case_id}, name: #{case_name}"
			@logger.info msg
			@logger_file.info(msg) if not @logger_file.nil?
		end

		def case_log_end case_id, case_name, result, message

			raise StartTimeNotSetException.new("case_log_start has been executed, start_time is nil") if @start_time.nil?
			@now_case_id = nil
			@now_case_name = nil
			end_time = Time.now
			eclapse = end_time - @start_time
			msg = "[Case]End: ID: #{case_id}, name: #{case_name}, eclapse: #{eclapse}, result: #{result}, message: #{message}"

			@logger.info msg
			@logger_file.info(msg) if not @logger_file.nil?
			@start_time = nil
		end

		def case_assert message, conditions
			puts conditions
			if conditions
				@logger.info "[Case] assert pass: #{message}"
			else
				@logger.error "[Case] assert fail: #{message}"
				raise CaseAssertException.new "assert fail: #{message}"
			end
		end

		def step_log step_name, step_desc, result
			raise StartTimeNotSetException.new("case_log_start and now_step_start_time has both been executed, start_time is nil") if @start_time.nil? and @now_step_start_time.nil?
			raise StartTimeNotSetException.new("case_log_start has been executed, start_time is nil") if @start_time.nil?
			@now_step_start_time ||= @start_time
			eclapse = Time.now - @now_step_start_time
			@now_step_start_time = Time.now
			msg = "[Step]#{step_name}:#{step_desc}, result: #{result}, #{eclapse}s"
			@logger.info msg
			@logger_file.info(msg) if not @logger_file.nil?
		end

		
	end
end