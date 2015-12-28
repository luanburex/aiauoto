#coding:utf-8

module AIAuto

	class StartTimeNotSetException < StandardError; end
	class CaseNotSetException < StandardError; end
	class CaseAssertException < StandardError; end

	RESULT_LOG_PATH = "result"
	RESULT_SCREENSHOT_PATH_NAME = "screenshot"
	WEBDRIVER_TYPE = 3



	class AIProjectRecorder

		RESULT_STAT = {:PASS=>0, :FAIL=>1, :TIMEOUT=>2, :NOTCOMPLETE=>3}

		attr_accessor :project
		attr_accessor :now_case_log

		def initialize
			@project = {}
		end

		def project_start args

			#common
			if args.nil? or not (args.kind_of? Hash)
				args = {}
			end


			task_id = args[:task_id].nil? ? 0 : args[:task_id]
			task_name = args[:task_name].nil? ? "task_project" : args[:task_name]
			plan_id = args[:plan_id].nil? ? 0 : args[:plan_id]
			agent_id = args[:agent_id].nil? ? 0 : args[:agent_id]
			agent_name = args[:agent_name].nil? ? "localhost" : args[:agent_name]
			group_no = args[:group_no].nil? ? 0 : args[:group_no]
			group_name = args[:group_name].nil? ? "(localhost)" : args[:group_name]

			@project[:run_id] = task_id
			@project[:task_name] = task_name
			@project[:plan_id] = plan_id
			@project[:state] = "START"
			@project[:agent_id] = agent_id
			@project[:agent_name] = agent_name
			@project[:run_start_time] = Time.now
			@project[:run_end_time] = Time.now
			@project[:group_no] = group_no
			@project[:group_name] = group_name
			@project[:case_logs] = []

			#oracle db log
			@ora_db_conn = nil
			if not (args[:ora_db_url].nil? or args[:ora_db_username].nil? or args[:ora_db_password].nil?)
				ora_db_project_start args[:ora_db_url], args[:ora_db_username], args[:ora_db_password], task_id, plan_id, agent_id, agent_name
			end

		end

		def project_end
			@project[:state] = "END"
			@project[:run_end_time] = Time.now

			#oracle db log
			ora_db_project_end
		end

		def case_log_start class_name, method_name, data = nil
			@now_case_log = {}
			@now_case_log[:script_class_name] = class_name.to_s
			@now_case_log[:script_method_name] = method_name.to_s
			@now_case_log[:run_id] = @project[:run_id]
			@now_case_log[:start_time] = Time.now
			@now_case_log[:data_value] = data

			@now_case_log[:step_logs] = []
			@now_case_log[:step_id] = 0
			@now_case_log[:step_timer] = Time.now
		end

		def case_log_end args

			if args.nil? or not (args.kind_of? Hash)
				args = {}
			end

			script_category = args[:script_category].nil? ? AIAuto::WEBDRIVER_TYPE : args[:script_category]
			script_id = args[:script_id].nil? ? 0 : args[:script_id]
			script_name = args[:script_name].nil? ? args[:method_name] : args[:script_name]
			script_module = args[:script_module].nil? ?args[:class_name] : args[:script_module]
			data_id = args[:data_id].nil? ? 0 : args[:data_id]
			data_name = args[:data_name].nil? ? "" : args[:data_name]
			data_desc = args[:data_desc].nil? ? "" : args[:data_desc]
			rst_log = args[:rst_log].nil? ? "" : args[:rst_log]
			key_time_comsuming = args[:key_time_comsuming].nil? ? 0 : args[:key_time_comsuming]
			result = args[:result].nil? ? AIAuto::AIProjectRecorder::RESULT_STAT[:PASS] : args[:result]

			@now_case_log[:script_category] = script_category
			@now_case_log[:script_id] = script_id
			@now_case_log[:script_name] = script_name
			@now_case_log[:script_module] = script_module
			@now_case_log[:data_id] = data_id
			@now_case_log[:data_name] = data_name
			@now_case_log[:data_desc] = data_desc
			@now_case_log[:data_attr] = ""
			@now_case_log[:result] = result
			@now_case_log[:end_time] = Time.now
			@now_case_log[:rst_log] = rst_log
			@now_case_log[:group_no] = @project[:group_no]
			@now_case_log[:group_name] = @project[:group_name]
			@now_case_log[:time_consuming] = @now_case_log[:end_time] - @now_case_log[:start_time]
			@now_case_log[:key_time_comsuming] = key_time_comsuming

			@now_case_log.delete(:step_id)
			@now_case_log.delete(:step_timer)

			@project[:case_logs] << @now_case_log
			
			#oracle db log
			ora_db_case_end script_id, script_category, script_name, script_module, data_id, data_name, data_desc, @now_case_log[:start_time], @now_case_log[:end_time], result, rst_log, @now_case_log[:end_time] - @now_case_log[:start_time], key_time_comsuming

			#end
			@now_case_log={}
		end

		def step_log step_name, step_desc, result, step_expect_result, attach_pic, rst_log
			step = {}

			step_expect_result = "" if step_expect_result.nil?
			attach_pic="" if attach_pic.nil?
			rst_log="" if rst_log.nil?
			@now_case_log[:step_id] += 1
			step[:step_id] = @now_case_log[:step_id]
			step[:step_name] = step_name
			step[:step_desc] = step_desc
			step[:step_expect_result] = step_expect_result
			step[:result] = result
			step[:start_time] = @now_case_log[:step_timer]
			@now_case_log[:step_timer] = Time.now
			step[:eclapse] = @now_case_log[:step_timer] - step[:start_time]
			step[:attach_pic] = attach_pic
			step[:rst_log] = rst_log

			@now_case_log[:step_logs] << step
		end

		def console_print



			#puts @project
			puts "=========================================="
			puts "Project: #{@project[:task_name]}"
			puts "=========================================="
			stat = {}
			stat[:sum] = 0
			stat[:success] = 0
			stat[:fail] = 0
			stat[:start_time] = @project[:run_start_time]
			stat[:eclapse] = @project[:run_end_time] - @project[:run_start_time]
			@project[:case_logs].each do |c|
				if c[:result] == RESULT_STAT[:PASS]
					stat[:success] += 1
				else
					stat[:fail] += 1
				end
				stat[:sum] += 1
				puts "#{c[:script_module].nil? ? "":"#{c[:script_module]}\t"}#{c[:script_name].nil? ? "":"#{c[:script_name]}\t"}#{c[:script_class_name]}.#{c[:script_method_name]}\t#{getResultDisplay c[:result]}\tUse: #{c[:time_consuming]}s"
			end
			puts "=========================================="
			puts "#{stat[:eclapse]}s eclapse, start at #{stat[:start_time]}"
			puts "#{stat[:sum]} tests total, #{stat[:success]} passed, #{stat[:fail]} failed."
			puts "#{stat[:success]*100.0 / stat[:sum]} % tests passed."
			puts "=========================================="



		end

		def getResultDisplay value
			RESULT_STAT.find{|k, v| v == value}[0].to_s
		end

		private

		def ora_db_project_start db_url, db_username, db_passord, task_id, plan_id, agent_id, agent_name

			require "oci8"
			@ora_db_conn = OCI8.new(db_username, db_passord, db_url)
			@ora_db_conn.autocommit = true
			@ora_task_id = task_id
			if task_id.nil? or task_id == 0
				@ora_db_conn.exec("select alm_run$seq.nextval from dual") do |r|
					@ora_task_id = r[0]
				end
				cursor = @ora_db_conn.parse('''insert into alm_run (RUN_ID, PLAN_ID, STATE, AGENT_IP, AGENT_ID, RUN_START_TIME, RUN_END_TIME, DEL_MARK, AGENT_TYPE)
											values (:task_id, :plan_id, 0, :agent_name, :agent_id, sysdate, sysdate, 0, null)''')
			else
				@ora_db_conn.exec("select count(*) from alm_run where run_id = #{task_id}") do |r|
					if (r[0] == 0)
						cursor = @ora_db_conn.parse('''insert into alm_run (RUN_ID, PLAN_ID, STATE, AGENT_IP, AGENT_ID, RUN_START_TIME, RUN_END_TIME, DEL_MARK, AGENT_TYPE)
											values (:task_id, :plan_id, 0, :agent_name, :agent_id, sysdate, sysdate, 0, null)''')
					else
						cursor = @ora_db_conn.parse('''update alm_run set plan_id = :plan_id, state = 0, AGENT_IP = :agent_name, agent_id = :agent_id, RUN_START_TIME=:run_start_time
											where RUN_ID=:task_id''')
					end
				end

			end

					
			begin
				cursor.bind_param(:task_id, @ora_task_id)
				cursor.bind_param(:plan_id, plan_id)
				cursor.bind_param(:agent_id, agent_id)
				cursor.bind_param(:agent_name, agent_name)
				cursor.bind_param(:run_start_time, @project[:run_start_time])

				cursor.exec()
			ensure
				cursor.close
			end

			return @ora_task_id
		end
		def ora_db_project_end
			if not @ora_db_conn.nil?
				cursor = @ora_db_conn.parse("update alm_run set state = 10, run_end_time = :run_end_time where run_id = :task_id")
				begin
					cursor.bind_param(:task_id, @ora_task_id)
					cursor.bind_param(:run_end_time, @project[:run_end_time])

					cursor.exec()
				ensure
					cursor.close
				end
				@ora_db_conn.logoff
				@ora_task_id = nil
			end
		end
		def ora_db_case_end script_id, script_category, script_name, script_module, data_id, data_name, data_desc, start_time, end_time, result, rst_log, time_consuming, key_time_comsuming
			if not @ora_db_conn.nil?

				ora_case_log_id = 0
				@ora_db_conn.exec("select alm_case_log$seq.nextval from dual") do |r|
					ora_case_log_id = r[0]
				end
				
				cursor = @ora_db_conn.parse('''
					insert into alm_case_log (CASE_LOG_ID, RUN_ID, CASE_ID, CASE_NAME, CASE_MODULE, DATA_ID, DATA_VALUE, DATA_DESC, START_TIME, END_TIME, RESULT, DATA_ATTR, CASE_RST_LOG, PARENT_ID, TIME_CONSUMING, CASE_CATEGORY, GROUP_NO, GROUP_NAME, KEY_TIME_CONSUMING, CREATE_TIME)
					values (:case_log_id, :task_id, :script_id, :script_name, :script_module, :data_id, :data_name, :data_desc, :start_time, :end_time, :result, null, :rst_log, \'0\', :time_consuming,  :script_category, :group_no, :group_name, :key_time_comsuming, sysdate)
					''')			
				begin
					cursor.bind_param(:case_log_id, ora_case_log_id)
					cursor.bind_param(:task_id, @ora_task_id)
					cursor.bind_param(:script_id, script_id)
					cursor.bind_param(:script_name, script_name)
					cursor.bind_param(:script_module, script_module)
					cursor.bind_param(:script_category, script_category)
					cursor.bind_param(:data_id, data_id)
					cursor.bind_param(:data_name, data_name)
					cursor.bind_param(:data_desc, data_desc)
					cursor.bind_param(:start_time, start_time)
					cursor.bind_param(:end_time, end_time)
					cursor.bind_param(:result, result)
					cursor.bind_param(:rst_log, rst_log)
					cursor.bind_param(:time_consuming, time_consuming)
					cursor.bind_param(:key_time_comsuming, key_time_comsuming)
					cursor.bind_param(:group_no, "111")
					cursor.bind_param(:group_name, "")
					cursor.exec()
				ensure
					cursor.close
				end


				@now_case_log[:step_logs].each do |s|
					cursor = @ora_db_conn.parse('''
insert into alm_step_log (STEP_LOG_ID, CASE_LOG_ID, STEP_ID, STEP_NAME, STEP_DESC, STEP_EXPECT_RESULT, START_TIME, ECLAPSE, RESULT, ATTACH_PIC, STEP_RST_LOG, IF_PROBEPOINT, PROBEPOINT_DESC)
values (alm_step_log$seq.nextval, :case_log_id, :step_id, :step_name, :step_desc, :step_expect_result, :start_time, :eclapse, :result, :attach_pic, :rst_log, 0, null)
''')
					begin
						cursor.bind_param(:case_log_id, ora_case_log_id)
						cursor.bind_param(:step_id, s[:step_id])
						cursor.bind_param(:step_name, s[:step_name])
						cursor.bind_param(:step_desc, s[:step_desc])
						cursor.bind_param(:step_expect_result, s[:step_expect_result])
						cursor.bind_param(:start_time, s[:start_time])
						cursor.bind_param(:eclapse, s[:eclapse])
						cursor.bind_param(:result, s[:result])
						cursor.bind_param(:attach_pic, s[:attach_pic])
						cursor.bind_param(:rst_log, s[:rst_log])

						cursor.exec()
					ensure
						cursor.close
					end

				end

			end
		end

	

	end

	class AILog



		attr_accessor :now_case_log
		
		def initialize browser = nil
			@browser = browser

			#init logger
			log_file_path = prepare_path()
			@logger_file = Logger.new(log_file_path)
			@logger_file.level = Logger::INFO
			@logger_file.datetime_format = "%Y-%m-%d %H:%M:%S"
			@logger = Logger.new(STDOUT)
			@logger.level = Logger::INFO
			@logger.datetime_format = "%Y-%m-%d %H:%M:%S"
			#init project recorder&case recorder
			@project_recorder = AIProjectRecorder.new
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

		def project_log_start args = nil
			log("[Project]start project")
			@project_recorder.project_start args
		end

		def project_log_end
			@project_recorder.project_end
			@project_recorder.console_print
		end

		def case_log_start class_name, method_name, data = nil
			log("[Case](#{class_name}_#{method_name}): Start At #{Time.now}")
			@project_recorder.case_log_start class_name, method_name, data
			@now_case_log = {}
			@now_case_log[:class_name] = class_name
			@now_case_log[:method_name] = method_name
			@now_case_log[:data] = data	
		end



		def case_log_end result = nil, message = nil
			log("[Case]End At #{Time.now}")
			if result.nil?
				result = @now_case_log[:result]
			end
			if result.nil?
				result = AIAuto::AIProjectRecorder::RESULT_STAT[:PASS]
			end
			@now_case_log[:result] = result
			@now_case_log[:rst_log] = "" if @now_case_log[:rst_log].nil?
			@now_case_log[:rst_log] += message if not message.nil?
			@project_recorder.case_log_end  @now_case_log
			@now_case_log = {}
		end

		def step_log step_name, step_desc, result, rst_log = nil, attach_pic = nil, step_expect_result = nil
			log "[Step]#{step_name}:#{step_desc}, Result: #{@project_recorder.getResultDisplay result}"
			if result != AIAuto::AIProjectRecorder::RESULT_STAT[:PASS]
				@now_case_log[:result] = AIAuto::AIProjectRecorder::RESULT_STAT[:FAIL]
			end
			@project_recorder.step_log step_name, step_desc, result, step_expect_result, attach_pic, rst_log
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