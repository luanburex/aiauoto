#coding:utf-8
require "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../cep"


class CatalogMgr < CepCase

	def initialize browser = nil
		super(browser)
		@browser.read_gui("#{File.expand_path(File.join(File.dirname(__FILE__)))}/../gui/CatalogMgr.gui")
	end
	


	def testNewDir data = {}

		dir_name = "a"
		dir_code = "123"
		dir_category = "模板目录"
		dir_parent_dir = "crm系统"

		
		menu "事件注册", "事件目录管理"

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
		msg = @browser.cep_alert()
		@logger.assert_true_log msg =~ /保存成功/, "判断是否最终保存成功"

	end


	def testSearch data = {}

		dir_code = "123"

		menu "事件注册", "事件目录管理"
		
		@browser.fetch_element_from_gui("事件管理页面.查询.目录编码").set dir_code
		@browser.fetch_element_from_gui("事件管理页面.查询.查询按钮").click
		sleep(2)
		@logger.assert_true_log @browser.elements(:xpath=>'//table[@class="ui-table"]//td[text()="' + dir_code + '"]').size > 0, "判断是否存在查询结果"
		
	end

	def testDeleteDir data = {}

		dir_code = "123"

		menu "事件注册", "事件目录管理"
		@browser.fetch_element_from_gui("事件管理页面.查询.目录编码").set dir_code
		@browser.fetch_element_from_gui("事件管理页面.查询.查询按钮").click

		sleep(1)
		@browser.fetch_element_from_gui("事件管理页面.表格全选").click
		@browser.fetch_element_from_gui("事件管理页面.删除按钮").click

		@browser.cep_alert()
		sleep(1)
		msg = @browser.cep_alert()

		@logger.assert_true_log msg =~ /删除成功/, "判断是否最终删除成功"

	end

end