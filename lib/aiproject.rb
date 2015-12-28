module AIAuto
	class AIProject

		attr_accessor :browser

		def initialize args = nil
			@logger = nil
			@init_args = args
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
			init_logger @init_args if @logger.nil?
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
							begin
								caseObj.__send__(method_name.to_sym, data)
							ensure
								data.each do |k, v|
									if k.class == Symbol
										@logger.now_case_log[k] = data[k]
									end
								end
							end
							@logger.case_log_end
						elsif data.kind_of? Array
							data.each do |d|
								@logger.case_log_start case_class, method_name, d
								caseObj.scence_recover if caseObj.respond_to? :scence_recover
								begin
									caseObj.__send__(method_name.to_sym, d)
								ensure
									data.each do |k, v|
										if k.class == Symbol
											@logger.now_case_log[k] = data[k]
										end
									end
								end
								@logger.case_log_end
							end
						end
					end
					

				rescue Exception => e
					@logger.error e
					@logger.case_log_end AIAuto::AIProjectRecorder::RESULT_STAT[:FAIL], e.message
				end
			end


		end

		private
		def init_logger init_log_args
			raise "browser object is nil" if @browser.nil?
			@logger = AILog.new @browser
			@logger.project_log_start init_log_args
		end



	end
end
