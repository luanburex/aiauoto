#coding: utf-8
require 'logger'

module AIAuto
	module Result
		LOGGER = Logger.new(STDOUT)

		class << self
			def log(msg)
				LOGGER.info(msg)
			end

			def error(msg)
				LOGGER.error(msg)
			end

			def log_step(step_id, step_name, msg)
				LOGGER.info("[STEP](%s, %s):%s" % [step_id, step_name, msg])
			end

			def log_case(case_id, case_name, msg)
				LOGGER.info("[CASE](%s, %s):%s" % [case_id, case_name, msg])
			end
		end
	end
end