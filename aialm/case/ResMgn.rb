#coding:utf-8
require "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../aialm"

class ResMgn < CepCase

	def initialize browser = nil
		super(browser)
		@browser.read_gui("#{File.expand_path(File.join(File.dirname(__FILE__)))}/../gui/ResMgn.gui")
	end


	def testAdd
		menu "资源管理", "机器管理"
		@browser.fetch_gui_wait_display("机器管理页面.主页面.新增按钮")
		@browser.fetch_element_from_gui("机器管理页面.主页面.新增按钮").click

		@browser.fetch_element_from_gui("机器管理页面.主页面.机器名称").set "TestMgr"
		@browser.fetch_element_from_gui("机器管理页面.主页面.Mac地址").set "xxxx"
		@browser.fetch_element_from_gui("机器管理页面.主页面.IP地址").set "127.0.0.1"
		@browser.fetch_element_from_gui("机器管理页面.主页面.操作系统输入框").click
		@browser.fetch_element_from_gui("机器管理页面.主页面.操作系统选择框").select "Linux"
		@browser.fetch_element_from_gui("机器管理页面.主页面.探测账号").set "root"
		@browser.fetch_element_from_gui("机器管理页面.主页面.探测密码").set "123abc"

		@browser.fetch_element_from_gui("机器管理页面.主页面.资源类型输入框").click
		@browser.fetch_element_from_gui("机器管理页面.主页面.资源类型下拉框").select "PC SERVER"

		@browser.fetch_element_from_gui("机器管理页面.主页面.机器描述").set "测试"


		@browser.fetch_element_from_gui("机器管理页面.主页面.保存机器").click

		@browser.fetch_gui_wait_display("机器管理页面.主页面.保存成功窗口")
		result_content = @browser.fetch_element_from_gui("机器管理页面.主页面.保存成功窗口信息").text
		if not "保存成功!" == result_content
			raise "保存报错，报错信息如下:" + result_content
		end

		@browser.fetch_element_from_gui("机器管理页面.主页面.保存成功确定按钮").click

	end

	def testSearch
		menu "资源管理", "机器管理"
		@browser.fetch_gui_wait_display("机器管理页面.主页面.查询机器")
		@browser.fetch_element_from_gui("机器管理页面.主页面.机器名称搜索").set "TestMgr"
		@browser.fetch_element_from_gui("机器管理页面.主页面.查询机器").click

		raise "没有查询结果" if not @browser.fetch_element_from_gui("机器管理页面.主页面.查询结果表").text =~ /TestMgr/
	end

	def testDel
		menu "资源管理", "机器管理"
		@browser.fetch_gui_wait_display("机器管理页面.主页面.查询机器")
		@browser.fetch_element_from_gui("机器管理页面.主页面.机器名称搜索").set "TestMgr"
		@browser.fetch_element_from_gui("机器管理页面.主页面.查询机器").click

		raise "没有删除的数据" if not @browser.fetch_element_from_gui("机器管理页面.主页面.查询结果表").text =~ /TestMgr/
		@browser.driver.action.double_click(@browser.fetch_element_from_gui("机器管理页面.主页面.查询结果表第一行第一列")).perform
		@browser.fetch_element_from_gui("机器管理页面.主页面.删除机器").click

		a = @browser.fetch_alert
		puts a.text
		a.accept


		@browser.fetch_gui_wait_display("机器管理页面.主页面.保存成功窗口")
		result_content = @browser.fetch_element_from_gui("机器管理页面.主页面.保存成功窗口信息").text
		if not "删除成功!" == result_content
			raise "删除报错，报错信息如下:" + result_content
		end

		@browser.fetch_element_from_gui("机器管理页面.主页面.保存成功确定按钮").click

	end
end