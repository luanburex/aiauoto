#coding:utf-8
require "./cep_lib"

class CepCase < AIAuto::TestCase

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

	
end

class EventDirMgr < CepCase

	def initialize browser = nil
		super(browser)
		@browser.read_gui("./cep.gui")
	end
	

	def add_new_dir dir_name, dir_code, dir_category, dir_parent_dir
		
		@browser.fetch_gui_wait_display("事件管理页面.新增按钮")
		@browser.fetch_element_from_gui("事件管理页面.新增按钮").click

		@browser.fetch_gui_wait_display("事件管理页面.新增弹出窗口")
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_目录名称").set dir_name
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_目录编号").set dir_code


		@browser.cep_select("事件管理页面.新增弹出窗口.目录新增_目录类别选择", dir_category)
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_父目录").click
		@browser.iframe({:xpath=>'//iframe[contains(@src, "parentCatalogChoose")]'}) do
			@browser.element(:xpath=>'//span[text()="' + dir_parent_dir + '"]').click
		end

		@browser.fetch_element_from_gui("事件管理页面.父目录选择窗口.确认按钮").click


		@browser.wait_until() {@browser.find_element_from_gui("事件管理页面.父目录选择窗口").nil?}	
		@browser.fetch_gui_wait_display("事件管理页面.新增弹出窗口")
		
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_提交").click
		@browser.cep_alert()
	end

	def search dir_code
		
		@browser.fetch_element_from_gui("事件管理页面.查询.目录编码").set dir_code
		@browser.fetch_element_from_gui("事件管理页面.查询.查询按钮").click
		sleep(2)
		@logger.log @browser.element(:xpath=>'//table[@class="ui-table"]//td[text()="' + dir_code + '"]').displayed?
	end

	def run data={}
		login data[:username], data[:password]
		menu "事件注册", "事件目录管理"
		#add_new_dir data[:dir_name], data[:dir_code], data[:dir_type], data[:parent_dir]
		search data[:dir_code]
	end

	def test_search

		@logger.case_log_start 1, "search"
		login "aicep", "123"
		menu "事件注册", "事件目录管理"
		search "LOG"
		#raise StandardError.new "aa"
		@logger.case_log_end 1, "search", 0, "yes......."
	end

end






=begin
datas = [
	{:username=>"aicep", :password=>"123", :dir_name => "test", :dir_code=>"aaksjdkgj", :dir_type=>"模板目录", :parent_dir=>"日志"},
	{:username=>"aicep", :password=>"123", :dir_name => "test", :dir_code=>"aaksjdkgj", :dir_type=>"模板目录", :parent_dir=>"日志"}
]

$b ||= AIAuto::Browser.new :chrome
p = AIAuto::AIProject.new
p.browser = $b
p.run_case EventDirMgr, datas
=end

$b ||= AIAuto::Browser.new :chrome
p = AIAuto::AIProject.new
p.browser = $b
p.run_case_test_method EventDirMgr