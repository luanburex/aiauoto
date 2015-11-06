#coding:utf-8
#require "./cep/case/catalogMgr"
require 'find'



Find.find("./cep/case") do |filename|
	load filename if filename =~ /\.rb$/
end


p = AIAuto::AIProject.new "测试工程"
$b ||= AIAuto::Browser.new :chrome
p.browser = $b


p.run_case_test_method CatalogMgr
p.run_case_test_method RuleDebug
p.end


# $b.iframe(:xpath=> '//iframe[contains(@name, "ruleDebug")]') do
# 	$b.element(:xpath=>'//input[@value="下一步»"]').click
# end

#$b.element(:xpath => '//div[@id="dataTable"]/table/tbody//td//a')

