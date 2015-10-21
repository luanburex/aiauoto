#coding:utf-8
$LOAD_PATH.unshift  File.expand_path(File.join(File.dirname(__FILE__)))
require 'selenium-webdriver'
require 'aigui'


module AIAuto

	class Browser

		WAIT_DEFAULT_TIMEOUT  = 10
      	WAIT_DEFAULT_INTERVAL = 0.5
		
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

		def read_gui filename
			@guis = AIAuto::GUI.read_gui_file(filename)
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

		def iframe(selector, &blk)
			@driver.switch_to.default_content
			iframe = @driver.find_element(selector)
			@driver.switch_to.frame(iframe)
			blk.call
		rescue
			@driver.switch_to.default_content	
		end

		def fetch_element_from_gui(name)
			@driver.switch_to.default_content
			target = @guis[name]
			raise "Can't find GUI, name: #{name}" if target.nil?
			retrun element(name, :xpath=>target.xpath) if target.parent == nil
			path = []
			t_parent = target.parent
			while (!t_parent.nil?) do
				path.unshift(t_parent)
				t_parent = t_parent.parent
			end
			path.each do |p|
				if "iframe" == p.type.downcase
					@driver.switch_to.frame(@driver.find_element(:xpath => p.xpath))
				end
			end

			return element(name, :xpath=>target.xpath)

		end

		def find_element_from_gui(name)
			begin
				return fetch_element_from_gui(name)
			rescue
				return nil
			end
		end

		def wait_until(args={}, &blk)
			@timeout = args.fetch(:timeout, WAIT_DEFAULT_TIMEOUT)
			@interval = args.fetch(:interval, WAIT_DEFAULT_INTERVAL)
			@message = args.fetch(:message, "Timeout Error")
			wait = Selenium::WebDriver::Wait.new(:timeout => 10, :interval=> 0.5)
			wait.until(&blk)
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