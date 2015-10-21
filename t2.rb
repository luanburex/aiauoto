#coding:utf-8
require "./cep_lib"

$b ||= AIAuto::Browser.new :chrome
b = $b


b.read_gui("./cep.gui")
b.goto "http://10.1.195.100:8081/aicep-web/"

b.fetch_element_from_gui("登录页面.用户名称输入框").set "aicep"
b.fetch_element_from_gui("登录页面.密码输入框").set "123"
b.fetch_element_from_gui("登录页面.登录按钮").click

b.wait_until {b.fetch_element_from_gui("主页面.事件注册菜单")}
b.fetch_element_from_gui("主页面.事件注册菜单").click
b.fetch_element_from_gui("主页面.事件目录管理菜单").click

b.wait_until {b.fetch_element_from_gui("事件管理页面.新增按钮")}
b.fetch_element_from_gui("事件管理页面.新增按钮").click

b.wait_until {b.element(:name=>"Openpage/catalogAddNew")}
b.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_目录名称").set "测试"
b.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_目录编号").set "1111111111111111"


b.cep_select("事件管理页面.新增弹出窗口.目录新增_目录类别选择", "模板目录")
b.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_父目录").click
b.iframe({:xpath=>'//iframe[contains(@src, "parentCatalogChoose")]'}) do
	b.element(:xpath=>'//span[text()="日志"]').click
end

b.fetch_element_from_gui("事件管理页面.父目录选择窗口.确认按钮").click


b.wait_until() {b.find_element_from_gui("事件管理页面.父目录选择窗口").nil?}
b.wait_until() {!b.find_element_from_gui("事件管理页面.新增弹出窗口").nil? and b.find_element_from_gui("事件管理页面.新增弹出窗口").displayed? }
b.fetch_element_from_gui("事件管理页面.新增弹出窗口.目录新增_提交").click
b.cep_alert()