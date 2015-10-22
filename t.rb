#coding:utf-8
require "./cep_lib"

class TestCase

	attr_accessor :browser

	def initialize browser = nil
		@browser = browser
		@browser ||= AIAuto::Browser.new :chrome
		
	end
end

class CepCase < TestCase

	def initialize browser = nil
		super(browser)
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
		@browser.goto "http://10.1.195.100:8081/aicep-web/"

		@browser.fetch_element_from_gui("登录页面.用户名称输入框").set username
		@browser.fetch_element_from_gui("登录页面.密码输入框").set password
		@browser.fetch_element_from_gui("登录页面.登录按钮").click
	end
	
	def menu first, second, third = nil

		first_xpath = '//div/span[text()="' + first + '"]'
		second_xpath = '//a[text()="' + second + '"]'
		@browser.wait_until(:message=>"等待一级窗口出现") {@browser.element(:xpath => first_xpath)}
		@browser.element(:xpath => first_xpath).click
		begin
			@browser.element(:xpath => second_xpath).click
		rescue
			@browser.element(:xpath => first_xpath).click
			@browser.element(:xpath => second_xpath).click
		end
	end

	
end

class EventDirMgr < CepCase

	def initialize browser = nil
		super(browser)
		@browser.read_gui("./cep.gui")
	end
	

	def add_new_dir dir_name, dir_code, dir_category, dir_parent_dir
		@browser.wait_until {@browser.fetch_element_from_gui("事件管理页面.新增按钮")}
		@browser.fetch_element_from_gui("事件管理页面.新增按钮").click

		@browser.wait_until {@browser.element(:name=>"Openpage/catalogAddNew")}
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_目录名称").set dir_name
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_目录编号").set dir_code


		@browser.cep_select("事件管理页面.新增弹出窗口.目录新增_目录类别选择", dir_category)
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_父目录").click
		@browser.iframe({:xpath=>'//iframe[contains(@src, "parentCatalogChoose")]'}) do
			@browser.element(:xpath=>'//span[text()="' + dir_parent_dir + '"]').click
		end

		@browser.fetch_element_from_gui("事件管理页面.父目录选择窗口.确认按钮").click


		@browser.wait_until() {@browser.find_element_from_gui("事件管理页面.父目录选择窗口").nil?}
		@browser.wait_until() {!@browser.find_element_from_gui("事件管理页面.新增弹出窗口").nil? and @browser.find_element_from_gui("事件管理页面.新增弹出窗口").displayed? }
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_提交").click
		@browser.cep_alert()
	end

	def main data={}
		login data[:username], data[:password]
		menu "事件注册", "事件目录管理"
		add_new_dir data[:dir_name], data[:dir_code], data[:dir_type], data[:parent_dir]
	end

end

datas = [
	{:username=>"aicep", :password=>"123", :dir_name => "test", :dir_code=>"aaksjdkgj", :dir_type=>"模板目录", :parent_dir=>"日志"},
	{:username=>"aicep", :password=>"123", :dir_name => "test", :dir_code=>"aaksjdkgj", :dir_type=>"模板目录", :parent_dir=>"日志"}
]





module AIAuto
	class AIProject


		def run_case case_class, datas
			@browser ||= AIAuto::Browser.new :chrome
			datas.each do |data|
				begin
					caseObj = case_class.new @browser
					caseObj.__send__(:main, data)
				rescue Exception => e
					puts e.message  
  					puts e.backtrace.inspect
				end
			end
			@browser.quit
		end

	end
end

p = AIAuto::AIProject.new
p.run_case EventDirMgr, datas