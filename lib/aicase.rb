module AIAuto
	class TestCase

		attr_accessor :browser
		attr_reader :logger

		def initialize browser = nil
			@browser = browser
			@browser ||= AIAuto::Browser.new
			@logger = AILog.new "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../result", @browser
		end
	end
end