#coding:utf-8
require "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../cep"


class RuleDebug < CepCase

	def initialize browser = nil
		super(browser)
		@browser.read_gui("#{File.expand_path(File.join(File.dirname(__FILE__)))}/../gui/RuleDebug.gui")
	end
	
	def testDebug
		menu "事件规则", "规则调试"
		
		@browser.fetch_gui_wait_display("规则调试页面.查询.查询按钮")
		@browser.fetch_element_from_gui("规则调试页面.查询.规则名称").set "sdfdsfd"
		@browser.fetch_element_from_gui("规则调试页面.查询.查询按钮").click

		sleep(0.5)
		@browser.fetch_gui_wait_display("规则调试页面.表格第一项规则调试")
		@browser.fetch_element_from_gui("规则调试页面.表格第一项规则调试").click

		sleep(0.5)
		@browser.fetch_gui_wait_display("规则调试页面.调试窗口.第一页下一步")
		@browser.fetch_element_from_gui("规则调试页面.调试窗口.第一页下一步").click
		sleep(0.5)
		@browser.fetch_element_from_gui("规则调试页面.调试窗口.第二页下一步").click
		sleep(0.5)
		@browser.iframe(:xpath=>'//iframe[contains(@name, "ruleDebug")]') do
			@browser.element(:xpath=>'//input[@value="stringATTR"]').click
		end
		@browser.fetch_element_from_gui("规则调试页面.调试窗口.第三页下一步").click
		sleep(0.5)

		@browser.element(:xpath=>'//span[text()="stringATTR"]/parent::*/input').set "1000"

		@browser.fetch_element_from_gui("规则调试页面.调试窗口.提交").click

		@browser.fetch_gui_wait_display("规则调试页面.调试窗口.结果表格")
		result = @browser.fetch_element_from_gui("规则调试页面.调试窗口.结果表格")
		@logger.assert_true_log result =~ /stringATTR/, "结果存在"
		@browser.fetch_gui_wait_display("规则调试页面.调试窗口.关闭").click
	end
end