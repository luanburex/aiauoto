#coding:utf-8
require "./lib/aiauto"


# $b ||= AIAuto::Browser.new :chrome
# b = $b
# b.load_gui_file(File.dirname(__FILE__) + "/cep.gui")


# b.iframe_default_content
# b.iframe_switch_to(:name=>"Openpage/catalogAddNew")
#b.element(:xpath=>'//input[@id="catalogType"]/parent::*/span//a').click

#b.element(:xpath=>"//div[@class=\"panel combo-p\"]//div[text()=\"\u6A21\u677F\u76EE\u5F55\"]")
#$b.driver.find_elements(:xpath=>'//div[@class="panel combo-p"]//div[@class="combobox-item combobox-item-selected"]')
#cep_select(b.element(:xpath=>'//input[@id="catalogType"]/parent::*/span//a'), "模板目录")

# b.element(:xpath=>'//input[@id="parentCatalogName"]/parent::*//a').click
#b.iframe_default_content
#b.iframe_switch_to({:xpath=>'//iframe[contains(@src, "parentCatalogChoose")]'})
#b.element(:xpath=>'//span[text()="日志"]').click
#b.element(:xpath=>'//a/span[text()="确认"]').click
#
#b.element(:xpath=>'//button[contains(@class, "aui_state_highlight") and text()="确定"]').click
#
def inner(*args)
	puts "inner=>"
	puts args
	puts args.class
	puts args.length
	puts "next=>"
	puts args[0].size
end

def test(*args)
	puts args
	puts args.class
	puts args.size
	inner *args
end

test("a", "b", :a=>"3", :b=>"3")