#coding:utf-8
require "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../aiga"


class ScriptMgr < AIGACase

	def initialize browser = nil
		super(browser)
		@browser.read_gui("#{File.expand_path(File.join(File.dirname(__FILE__)))}/../gui/ScriptMgr.gui")
	end

	def testAddScript data
		menu "自动化测试管理", "脚本管理"
		@logger.step_log "打开菜单", "正确打开菜单", 0

		@browser.fetch_gui_wait_display("脚本管理页面.脚本查询页面.新增按钮")
		@browser.fetch_element_from_gui("脚本管理页面.脚本查询页面.新增按钮").click
		@logger.step_log "点击新增按钮", "点击新增按钮", 0

		sleep(1)
		@browser.fetch_gui_wait_display("脚本管理页面.脚本表单.脚本名称")
		@browser.fetch_gui_wait_display("脚本管理页面.脚本表单.脚本名称").set data["脚本名称"]
		@browser.fetch_element_from_gui("脚本管理页面.脚本表单.包含库").set data["包含库"]
		@browser.fetch_element_from_gui("脚本管理页面.脚本表单.脚本标签").set data["脚本标签"]
		@browser.fetch_element_from_gui("脚本管理页面.脚本表单.所属工程").select data["所属工程"]
		@browser.fetch_element_from_gui("脚本管理页面.脚本表单.业务模块").set data["业务模块"]
		@browser.fetch_element_from_gui("脚本管理页面.脚本表单.脚本描述").set data["脚本描述"]
		@browser.fetch_element_from_gui("脚本管理页面.脚本表单.自动化脚本").set data["自动化脚本"]
		@logger.step_log "输入脚本基本信息", "输入脚本基本信息", 0


		data["参数列表"].split("|").each do |d|
			@browser.fetch_element_from_gui("脚本管理页面.脚本表单.新增参数按钮").click
			sleep 0.5
			@browser.element(:xpath => '(//table[@id="test_table"]//a[text()="编辑"])[last()]').click
			p = d.split(",")
			@browser.element(:xpath => '(//table[@id="test_table"]//tbody/tr)[last()]/td[2]/input').set p[0]
			@browser.element(:xpath => '(//table[@id="test_table"]//tbody/tr)[last()]/td[3]/input').set p[1]
			@browser.element(:xpath => '(//table[@id="test_table"]//tbody/tr)[last()]/td[4]/input').set p[2]
			@browser.element(:xpath => '(//table[@id="test_table"]//tbody/tr)[last()]/td[5]/input').set p[3]
			@browser.element(:xpath => '(//table[@id="test_table"]//a[text()="保存"])[last()]').click
			sleep 0.5
		end
		@browser.fetch_element_from_gui("脚本管理页面.脚本表单.保存按钮").click
		@logger.step_log "添加参数", "将相关参数添加进去", 0

		msg = @browser.element(:xpath=>'//div[@id="simplemodal-data"]').text
		@logger.log msg
		if not msg =~ /成功/
			@browser.element(:xpath=>'//div[@id="simplemodal-data"]//div[text()="确认"]').click
			@logger.step_log "弹出错误", "错误信息:#{msg}", 1
		else
			@browser.element(:xpath=>'//div[@id="simplemodal-data"]//div[text()="确认"]').click
			@logger.step_log "保存", "点击保存按钮", 0
		end
	

	end

	def testAddData data
		menu "自动化测试管理", "脚本管理"
		@logger.step_log "打开菜单", "正确打开菜单", 0

		@browser.fetch_gui_wait_display("脚本管理页面.脚本查询页面.查询_脚本名称")
		@browser.fetch_element_from_gui("脚本管理页面.脚本查询页面.查询_脚本名称").set data["脚本名称"]
		@browser.fetch_element_from_gui("脚本管理页面.脚本查询页面.查询按钮").click
		@logger.step_log "查询脚本", "查询需要增加数据的脚本", 0

		sleep 1
		@browser.element(:xpath=>'//table[@id="test_table"]//a[text()="录入数据"]').click
		sleep 0.5
		@logger.step_log "点击录入数据", "点击录入数据打开录入页面", 0

		@browser.fetch_gui_wait_display("脚本管理页面.数据录入页面.脚本名称")
		data["数据"].split("|").each do |d|
			@browser.fetch_element_from_gui("脚本管理页面.数据录入页面.新增数据按钮").click
			sleep 0.5
			@browser.element(:xpath => '(//table[@id="test_table"]//a[text()="编辑"])[last()]').click
			p = d.split(",")
			index = 4
			p.each do |v|
				@browser.element(:xpath => '(//table[@id="test_table"]//tbody/tr)[last()]/td[' + index.to_s + ']/input').set v
				index += 1
			end
			@browser.element(:xpath => '(//table[@id="test_table"]//a[text()="保存"])[last()]').click
			sleep 0.5
			@browser.element(:xpath=>'//div[@id="simplemodal-data"]//div[text()="确认"]').click
			sleep 1

		end

	end
end
