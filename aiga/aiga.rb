#coding:utf-8
require "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../lib/aibrowser.rb"

module AIAuto
	class Browser
		
	end
end

class AIGACase < AIAuto::TestCase

	def initialize browser = nil
		super(browser)
		init_parameter
		init_cep_gui
	end

	def init_parameter
		@username = "aiga"
		@password = "aiga"
		@login_url = "http://10.1.195.100:8081/aiga/"
	end

	def init_cep_gui
		@browser.read_gui_string '''
Page	登录页面
	用户名称输入框	//input[@title="账号"]
	密码输入框	//input[@title="密码"]
	登录按钮	//input[@value="登 录"]
		'''
	end

	def login username, password
		@browser.goto @login_url

		@browser.fetch_element_from_gui("登录页面.用户名称输入框").set username
		@browser.fetch_element_from_gui("登录页面.密码输入框").set password
		@browser.fetch_element_from_gui("登录页面.登录按钮").click
	end
	
	def menu first, second, third = nil

		
		first_xpath = '//a/span[text()="' + first + '"]'
		second_xpath = '//li/a[text()="' + second + '"]'
		@browser.wait_until(:message=>"等待一级菜单出现") {@browser.element(:xpath => first_xpath)}
		@browser.driver.action.move_to(@browser.element(:xpath=>first_xpath)).perform
		@browser.element(:xpath => first_xpath).click
		sleep 0.5
		begin
			@browser.wait_until(:message=>"等待二级菜单出现") {@browser.element(:xpath => second_xpath)}
			@browser.element(:xpath => second_xpath).click
		rescue
			#@browser.element(:xpath => first_xpath).click
			@browser.driver.action.move_to(@browser.element(:xpath=>first_xpath)).perform
			@browser.element(:xpath => second_xpath).click
		end
		sleep 0.5
	end

	def scence_recover
		@logger.log "[Recover]Start"

		begin
			@browser.title
		rescue
			@logger.log "[Recover]Reopen the browser..."
			@browser = AIAuto::TestCase.new(AIAuto::Browser.new :chrome)

		end
		@logger.log "[Recover]maximize window..."
		@browser.driver.manage.window.maximize

		@logger.log "[Recover]Open Main Url..."
		@browser.goto "http://10.1.195.100:8081/aiga/page/HomePage"
		if @browser.title == "登录"
			@logger.log "[Recover]Login at Login Page..."
			login_username = @browser.find_element_from_gui("登录页面.用户名称输入框")
			if not login_username.nil?
				login @username, @password
			end
		end
		@logger.log "[Recover]End"
	end

	
end