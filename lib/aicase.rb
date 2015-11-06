module AIAuto
	class TestCase

		attr_accessor :browser
		attr_accessor :logger

		def initialize browser = nil, logger = nil
			@browser = browser
			@browser ||= AIAuto::Browser.new
			if not logger.nil?
				@logger = logger
			end
		end
	end
end