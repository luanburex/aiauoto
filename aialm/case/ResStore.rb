#coding:utf-8
require "#{File.expand_path(File.join(File.dirname(__FILE__)))}/../aialm"

class ResStore < CepCase

	def initialize browser = nil
		super(browser)
		@browser.read_gui("#{File.expand_path(File.join(File.dirname(__FILE__)))}/../gui/ResStore.gui")
	end

	def testSubmitApply
		menu "我的工作区", "资源申请"
		@browser.fetch_gui_wait_display("资源申请页面.资源申请单.类型")
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.类型").select "存储资源申请"	
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.开始时间").set "2015-10-01"
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.结束时间").set "2016-10-01"
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.申请类型").select "新增"
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.申请IP").set "10.248.12.150"
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.申请大小").set "16"
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.项目组").select "一级测试开发平台"
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.申请名称").set "测试申请"
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.申请描述").set "测试申请"
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.网管审批按钮").click
		

		@browser.fetch_gui_wait_display("选择人员窗口.人员选择树")
		@browser.tree_select("选择人员窗口.人员选择树", ["集成商", "亚信", "亚信4组（一级测试开发平台）"])
		@browser.table_click_column_by_text(@browser.fetch_element_from_gui("选择人员窗口.人员列表"), "RENZQ")
		@browser.fetch_element_from_gui("选择人员窗口.确定按钮").click


		@browser.fetch_gui_wait_display("资源申请页面.资源申请单.确定按钮")
		sleep(0.5)
		@browser.fetch_element_from_gui("资源申请页面.资源申请单.确定按钮").click

		if(not @browser.find_element_from_gui("资源申请页面.资源申请单.确定按钮").nil?)
			@browser.fetch_element_from_gui("资源申请页面.资源申请单.确定按钮").click
		end



	end
end