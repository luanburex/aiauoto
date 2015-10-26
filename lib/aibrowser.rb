#coding:utf-8
$LOAD_PATH.unshift  File.expand_path(File.join(File.dirname(__FILE__)))
require 'logger'
require 'selenium-webdriver'
require 'ailog'
require 'aigui'
require 'aielement_container'
require 'aicase'
require 'aiproject'

module AIAuto

	class Browser

		include ElementContainer


		
		attr_reader :driver
	
		def initialize(browser, *args)

			@driver = Selenium::WebDriver.for browser.to_sym, *args
			@driver.manage.timeouts.implicit_wait = 3
			@driver.manage.timeouts.page_load = 10
			@driver.manage.timeouts.script_timeout = 60
			@guis = {}
		end

		def goto uri
			@driver.navigate.to uri
			uri
		end



		def respond_to?(*args)
      		@driver.respond_to?(*args)
   		end

		def method_missing(m, *args, &block)
        	unless @driver.respond_to? m
        		raise NoMethodError, "undefined method `#{m}' for #{@driver.inspect}:#{@driver.class}"
        	end
			@driver.__send__(m, *args, &block)
		end
	end
end


module Selenium
	module WebDriver
		class Element

			attr_accessor :name

			def set(content)
				self.clear
				self.send_keys content
			end
		end
	end
end