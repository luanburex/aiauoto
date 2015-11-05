#coding:utf-8
require 'find'

Find.find("./case") do |filename|
	load filename if filename =~ /\.rb$/
end


p = AIAuto::AIProject.new

$b ||= AIAuto::Browser.new :ie
p.browser = $b

#p.run_case_test_method ResStore, :testSubmitApply
p.run_case_test_method ResMgn, :testDel
puts p.result_stat.join("\n")


# $b.iframe(:xpath=>'//iframe[@id="mainFrame"]') do
# 	$b.wait_until {
# 		$b.element(:xpath=>'//a/span/span[text()="确定"]').displayed?
# 	}
# 	puts $b.element(:xpath=>'//a/span/span[text()="确定"]').displayed?
# 	puts "====>"
# 	$b.element(:xpath=>'//a/span/span[text()="确定"]').click
# end

# $b.table_click_column_by_text($b.fetch_element_from_gui("选择人员窗口.人员列表"), "RENZQ")
