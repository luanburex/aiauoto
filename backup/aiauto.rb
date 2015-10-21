#coding : utf-8
require 'selenium-webdriver'

module AIAuto


	class Browser
		
		WAIT_DEFAULT_TIMEOUT  = 10
      	WAIT_DEFAULT_INTERVAL = 0.5
		
		attr_reader :driver
	
		def initialize(browser, *args)

			#Selenium::WebDriver::Timeouts.implicit_wait = 7
			#Selenium::WebDriver::Timeouts.page_load = 10
			#Selenium::WebDriver::Timeouts.script_timeout = -1

			@driver = Selenium::WebDriver.for browser.to_sym, *args
			@driver.manage.timeouts.implicit_wait = 3
			@driver.manage.timeouts.page_load = 10
			@driver.manage.timeouts.script_timeout = 60
		end

		def goto uri
			@driver.navigate.to uri
			uri
		end

		def element(*args)
			if(args.size == 1)
				return element_no_name(args[0])
			elsif(args.size == 2)
				return element_by_name(args[0], args[1])
			end
			raise ArgumentError, "element should contain 1 or 2 parameter"
		end

		def element_no_name(selector)
			@driver.find_element(selector)
		end
		def element_by_name(name, selector)
			ele = element_no_name(selector)
			ele.name = name if ele.respond_to? :name
			ele
		end

		#private
		def element_find(*args)
			ele = nil
			begin
				ele = element(*args)
				return ele
			rescue
				return nil
			end
		end

		def element_exists?(*args)
			!element_find.nil?
		end

		def element_displayed?(*args)
			if(!element_find(*args).nil?)
				ele = element(*args)
				return ele.displayed?
			else
				return false
			end
		end

		def wait_until(args={}, &blk)
			@timeout = args.fetch(:timeout, WAIT_DEFAULT_TIMEOUT)
			@interval = args.fetch(:interval, WAIT_DEFAULT_INTERVAL)
			@message = args.fetch(:message, "Timeout Error")
			wait = Selenium::WebDriver::Wait.new(:timeout => 10, :interval=> 0.5)
			wait.until(&blk)
		end

		def iframe_switch_to(selector)
			iframe = @driver.find_element(selector)
			@driver.switch_to.frame(iframe)
		end

		def iframe_default_content
			@driver.switch_to.default_content
		end

		def iframe(selector, &blk)
			@driver.switch_to.default_content
			iframe = @driver.find_element(selector)
			@driver.switch_to.frame(iframe)
			blk.call
		rescue
			@driver.switch_to.default_content	
		end


		def load_gui(gui_str)
			@guis ||= {}
			@guis.clear
			gui_str.each_line do |line|
				line = line.strip
				next if line.size <= 0
				unless line =~ /.*\t.*/
					raise "gui line: #{line} format error"
				end
				name = line[0, line.index("\t")]
				xpath = line[line.index("\t") + 1, line.size - 1]
				
				if @guis.key? name
					raise "gui has the same name element."
				end
				@guis[name] = xpath
			end
		end

		def load_gui_file(filename)
			file=File.open(filename,"r:utf-8")
		    @guis ||= {}
			@guis.clear
			file.each  do |line|
				line = line.strip
				next if line.size <= 0
				unless line =~ /.*\t.*/
					raise "gui line: #{line} format error"
				end
				name = line[0, line.index("\t")]
				xpath = line[line.index("\t") + 1, line.size - 1]
				
				if @guis.key? name
					raise "gui has the same name element."
				end
				@guis[name] = xpath
			end
		    file.close
		end

		def fetch_element_from_gui(name)
			element(name, :xpath=>@guis[name])
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


module AICep
	module BaiduSearch
		class <<self
			def start_step
				b = Browser.new :chrome
				b.goto "http://www.baidu.com"
				b.find_element(:id, "kw").send_keys "ok"
			end

		end

	end
end
