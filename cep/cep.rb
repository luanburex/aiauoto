#coding:utf-8
require "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../lib/aibrowser.rb"

module AIAuto
	class Browser
		def cep_select(element_name, select_text)
			fetch_element_from_gui(element_name).click
			@driver.find_elements(:xpath=>'//div[@class="panel combo-p"]/div/div').each do |e|
				puts "click:#{e.text} equal #{select_text} , result: #{select_text == e.text}"
				if e.text == select_text
					e.click

				end
			end
		end

		def cep_alert
			alerts = @driver.find_elements(:xpath=>'//div[contains(@class, "aui_outer")]')
			raise "No Alert Window apppeared." if(alerts.size <= 0)
			error_alerts = @driver.find_elements(:xpath=>'//div[contains(@class, "aui_outer")]//div[contains(@style, "error.png")]')
			raise "Error Alert in window. information:#{@driver.find_element(:xpath=>'//div[contains(@class, "aui_outer")]//div[contains(@class, "ui_content")]').text}" if error_alerts.size > 0
			message = @driver.find_element(:xpath=>'//div[contains(@class, "aui_outer")]//div[contains(@class, "ui_content")]').text
			@driver.find_element(:xpath=>'//button[contains(@class, "aui_state_highlight") and text()="确定"]').click
			return message
		end
	end
end

class CepCase < AIAuto::TestCase

	def initialize browser = nil
		super(browser)
		init_parameter
		init_cep_gui
	end

	def init_parameter
		@username = "aicep"
		@password = "123"
		@login_url = "http://10.1.195.100:8081/aicep-web/"
	end

	def init_cep_gui
		@browser.read_gui_string '''
Page	登录页面
	用户名称输入框	//input[@placeholder="请输入账号"]
	密码输入框	//input[@placeholder="请输入密码"]
	登录按钮	//a[text()="登录"]
Page	主页面
	事件注册菜单	//div/span[text()="事件注册"]
	事件目录管理菜单	//a[text()="事件目录管理"]
		'''
	end

	def login username, password
		@browser.goto @login_url

		@browser.fetch_element_from_gui("登录页面.用户名称输入框").set username
		@browser.fetch_element_from_gui("登录页面.密码输入框").set password
		@browser.fetch_element_from_gui("登录页面.登录按钮").click
	end
	
	def menu first, second, third = nil

		first_xpath = '//div/span[text()="' + first + '"]'
		second_xpath = '//a[text()="' + second + '"]'
		@browser.wait_until(:message=>"等待一级窗口出现") {@browser.element(:xpath => first_xpath)}
		#@browser.element(:xpath => first_xpath).click
		@browser.driver.action.move_to(@browser.element(:xpath=>first_xpath)).perform
		begin
			@browser.element(:xpath => second_xpath).click
		rescue
			#@browser.element(:xpath => first_xpath).click
			@browser.driver.action.move_to(@browser.element(:xpath=>first_xpath)).perform
			@browser.element(:xpath => second_xpath).click
		end
	end

	def scence_recover
		@logger.log "[Recover]Start"

		begin
			@browser.title
		rescue
			@logger.log "[Recover]Reopen the browser..."
			@browser = AIAuto::TestCase.new(AIAuto::Browser.new :chrome)
			init_cep_gui
		end
		
		@logger.log "[Recover]Open Url..."
		@browser.goto "http://10.1.195.100:8081/aicep-web/page/MainHome"
		login_username = @browser.find_element_from_gui("登录页面.用户名称输入框")
		if not login_username.nil?
			@logger.log "[Recover]Login at Login Page..."
			login @username, @password
		end

		@logger.log "[Recover]End"
	end

	
end