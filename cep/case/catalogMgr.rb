#coding:utf-8
require "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../cep"


class CatalogMgr < CepCase

	def initialize browser = nil
		super(browser)
		@browser.read_gui("#{File.expand_path(File.join(File.dirname(__FILE__)))}/../gui/catalogMgr.gui")
	end
	


	def test_new_dir

		case_id = 1
		case_name = "新增目录案例"

		dir_name = "a"
		dir_code = "123"
		dir_category = "模板目录"
		dir_parent_dir = "a"


		@logger.case_log_start case_id, case_name
		
		#login "aicep", "123"
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
		@browser.cep_alert()

		@logger.case_log_end case_id, case_name, 0, "新增目录成功"
	end


	def test_search
		case_id = 2
		case_name = "搜索目录"

		dir_code = "123"

		menu "事件注册", "事件目录管理"
		@logger.case_log_start case_id, case_name
		@browser.fetch_element_from_gui("事件管理页面.查询.目录编码").set dir_code
		@browser.fetch_element_from_gui("事件管理页面.查询.查询按钮").click
		sleep(2)
		@logger.case_assert "判断是否存在查询结果", @browser.elements(:xpath=>'//table[@class="ui-table"]//td[text()="' + dir_code + '"]').size > 0
		@logger.case_log_end case_id, case_name, 0, "搜索目录成功"
	end

	def test_delete_dir
		case_id = 3
		case_name = "搜索目录"

		dir_code = "123"


		menu "事件注册", "事件目录管理"
		@logger.case_log_start case_id, case_name
		@browser.fetch_element_from_gui("事件管理页面.查询.目录编码").set dir_code
		@browser.fetch_element_from_gui("事件管理页面.查询.查询按钮").click

		sleep(1)
		@browser.fetch_element_from_gui("事件管理页面.表格全选").click
		@browser.fetch_element_from_gui("事件管理页面.删除按钮").click

		@logger.case_log_end case_id, case_name, 0, "删除目录成功"
		@browser.cep_alert()
		sleep(1)
		@browser.cep_alert()

	end

end