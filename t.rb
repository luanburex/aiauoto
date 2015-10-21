#coding:utf-8
require "./cep_lib"

class EventDirMgr

	attr_accessor :browser

	def initialize browser = nil
		@browser = browser
		@browser ||= AIAuto::Browser.new :chrome
		@browser.read_gui("./cep.gui")
	end

	def login username, password
		@browser.goto "http://10.1.195.100:8081/aicep-web/"

		@browser.fetch_element_from_gui("登录页面.用户名称输入框").set username
		@browser.fetch_element_from_gui("登录页面.密码输入框").set password
		@browser.fetch_element_from_gui("登录页面.登录按钮").click
	end

	def menu first, second, third = nil
		@browser.wait_until {@browser.fetch_element_from_gui("主页面.事件注册菜单")}
		@browser.fetch_element_from_gui("主页面.事件注册菜单").click
		@browser.fetch_element_from_gui("主页面.事件目录管理菜单").click
	end

	def add_new_dir dir_name, dir_code, dir_category, dir_parent_dir
		@browser.wait_until {@browser.fetch_element_from_gui("事件管理页面.新增按钮")}
		@browser.fetch_element_from_gui("事件管理页面.新增按钮").click

		@browser.wait_until {@browser.element(:name=>"Openpage/catalogAddNew")}
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_目录名称").set "测试"
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_目录编号").set "1111111111111111"


		@browser.cep_select("事件管理页面.新增弹出窗口.目录新增_目录类别选择", "模板目录")
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_父目录").click
		@browser.iframe({:xpath=>'//iframe[contains(@src, "parentCatalogChoose")]'}) do
			@browser.element(:xpath=>'//span[text()="日志"]').click
		end

		@browser.fetch_element_from_gui("事件管理页面.父目录选择窗口.确认按钮").click


		@browser.wait_until() {@browser.find_element_from_gui("事件管理页面.父目录选择窗口").nil?}
		@browser.wait_until() {!@browser.find_element_from_gui("事件管理页面.新增弹出窗口").nil? and @browser.find_element_from_gui("事件管理页面.新增弹出窗口").displayed? }
		@browser.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_提交").click
		@browser.cep_alert()
	end

	def test_new_der
		login "aicep", "123"
		menu "事件注册", "事件目录管理"
		add_new_dir "new_test", "841019", "模板目录", "日志"

	end

	def main
		test_new_der
	end

end

class TestSuite

end

e = EventDirMgr.new
e.main