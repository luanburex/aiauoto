module AIAuto
	class AIProject

		attr_accessor :browser

		def initialize task_name, task_id = nil
			@task_id = task_id
			@task_name = task_name
			@logger = nil
		end

		def end
			@logger.project_log_end
		end

		def run_case_test_method case_class, method_filter = nil, data = nil
			if method_filter.nil?
				method_reg = /^test/
			elsif method_filter.kind_of? Symbol
				method_reg = Regexp.new("^#{method_filter}$")
			elsif method_filter.kind_of? Regexp
				method_reg = method_filter
			else
				method_reg = Regexp.new(method_filter)
			end

			caseObj = case_class.new @browser
			init_logger if @logger.nil?
			caseObj.logger = @logger
			caseObj.methods.grep(method_reg).each do |method_name|
				begin

					if(data.nil?)
						@logger.case_log_start case_class, method_name
						caseObj.scence_recover if caseObj.respond_to? :scence_recover
						caseObj.__send__(method_name.to_sym)
						@logger.case_log_end
					else
						if data.kind_of? Hash
							@logger.case_log_start case_class, method_name
							caseObj.scence_recover if caseObj.respond_to? :scence_recover
							caseObj.__send__(method_name.to_sym, data)
							@logger.case_log_end
						elsif data.kind_of? Array
							data.each do |d|
								@logger.case_log_start case_class, method_name, d
								caseObj.scence_recover if caseObj.respond_to? :scence_recover
								caseObj.__send__(method_name.to_sym, d)
								@logger.case_log_end
							end
						end
					end
					

				rescue Exception => e
					@logger.case_log_end false, e.message, e 
				end
			end


		end

		private
		def init_logger
			raise "browser object is nil" if @browser.nil?
			@logger = AILog.new @browser
			@logger.project_log_start  @task_name, @task_id
		end

	end
end
