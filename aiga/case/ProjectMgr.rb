#coding:utf-8
require "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../aiga"


class ProjectMgr < AIGACase

	def initialize browser = nil
		super(browser)
		@browser.read_gui("#{File.expand_path(File.join(File.dirname(__FILE__)))}/../gui/ProjectMgr.gui")
	end

	def testAddProject data
		
		
		
		menu "自动化测试管理", "工程管理"
		@logger.step_log "打开菜单", "正确打开菜单", 0
		@browser.fetch_gui_wait_display("工程管理页面.工程新增页面.新增按钮")
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.新增按钮").click
		@browser.fetch_gui_wait_display("工程管理页面.工程新增页面.工程名称")
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.工程名称").set data["工程名称"]
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.脚本类型").select data["脚本类型"]
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.保存信息按钮").click
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.弹出窗口确认").click
		@logger.step_log "添加工程", "根据传入数据添加一个工程", 0
		
	end

	def testFindProject data

		menu "自动化测试管理", "工程管理"
		@logger.step_log "打开菜单", "正确打开菜单", 0
		@browser.fetch_gui_wait_display("工程管理页面.工程新增页面.查询按钮")
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.查询工程名称").set data["工程名称"]
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.查询脚本类型").select data["脚本类型"]
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.查询按钮").click
		@logger.step_log "执行查找操作", "输入查询条件，并进行查询。", 0
		sleep(0.5)
		t = @browser.fetch_element_from_gui("工程管理页面.工程新增页面.查询结果表").text
		@logger.log t
		@logger.step_log "是否可以查询到预测结果", "对比表格内容是否包含工程名称", t =~ Regexp.new(data["工程名称"]) ? 0 : 1
		
	end

	def testDelProject data


		menu "自动化测试管理", "工程管理"
		@logger.step_log "打开菜单", "正确打开菜单", 0
		@browser.fetch_gui_wait_display("工程管理页面.工程新增页面.查询按钮")
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.查询工程名称").set data["工程名称"]
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.查询脚本类型").select data["脚本类型"]
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.查询按钮").click
		@logger.step_log "查询需要删除的工程", "根据工程名称脚本类型查询需要删除的工程", 0
		sleep 0.5


		@browser.wait_until(:message=>"查询结果出现") {@browser.element(:xpath=>'//table[@id ="test_table"]')}
		@browser.element(:xpath=>'//table[@id ="test_table"]//td[contains(text(), "test工程")]/parent::*//input').click
		@browser.fetch_element_from_gui("工程管理页面.工程新增页面.删除按钮").click
		sleep 0.5
		@browser.element(:xpath=>'//div[@id="simplemodal-data"]//div[@id="ok"]').click
		sleep 0.5
		@browser.element(:xpath=>'//div[@id="simplemodal-data"]//div[text()="确认"]').click
		@logger.step_log "删除工程", "选择符合第一个条件的工程删除", 0
	end
	
end