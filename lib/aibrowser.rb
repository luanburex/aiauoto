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



		def switch_window(xpath)
			@main_window = @driver.window_handle if @main_window.nil?
			find_window(xpath)
			yield
			if(@driver.window_handle != @main_window)
				@driver.switch_to.window(@main_window)
				@main_window = nil
			end
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

			def select(selected_text)
				tag_name = self.tag_name
				if not tag_name.downcase == "select"
					raise "This Element's tagName is not SELECTOR. You can't use this method"
				end
				options = self.find_elements(:tag_name=>"option")
				index = 0
				options.each do |o|
					if selected_text.kind_of? String and o.text == selected_text
						o.click
					elsif selected_text.kind_of? Regexp and o.text =~ selected_text
						o.click
					elsif selected_text.kind_of? Fixnum and index == selected_text
						o.click
					end
					index += 1
				end

			end

			
		end
	end
end