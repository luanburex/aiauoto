module AIAuto
	class AIProject

		attr_accessor :browser
		attr_reader :result_stat

		def initialize
			@result_stat = []
		end


		def fetch_browser
			@browser ||= AIAuto::Browser.new :chrome
		end

		def error_log error
			puts error.message  
  			puts error.backtrace.inspect
		end

		def run_case case_class, datas
			fetch_browser
			datas.each do |data|
				begin
					caseObj = case_class.new @browser
					caseObj.__send__(:run, data)
				rescue Exception => e
					error_log e
				end
			end
			#@browser.quit
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

			fetch_browser
			caseObj = case_class.new @browser


			caseObj.methods.grep(method_reg).each do |method_name|
				result = {:case_class=>case_class, :case_method_name=>method_name, :status=> "Start"}
				begin
					caseObj.scence_recover if caseObj.respond_to? :scence_recover
					caseObj.logger.log "Run: #{method_name}"
					if(data.nil?)
						caseObj.__send__(method_name.to_sym)
					else
						caseObj.__send__(method_name.to_sym, data)
					end
					result[:case_id] = caseObj.logger.now_case_id
					result[:case_name] = caseObj.logger.now_case_name
					result[:status] = "Success"

				rescue Exception => e
					result[:case_id] = caseObj.logger.now_case_id
					result[:case_name] = caseObj.logger.now_case_name
					result[:status] = "Error"
					result[:message] = e.message
					caseObj.logger.error e
					logger = caseObj.logger
					if !logger.now_case_id.nil? and !logger.now_case_name.nil?
						logger.case_log_end logger.now_case_id, logger.now_case_name, 1, e.message
					end

				end


				@result_stat << result
			end


		end

	end
end
