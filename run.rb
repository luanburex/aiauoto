#coding:utf-8
#require "./cep/case/catalogMgr"
require 'find'
load "./lib/ailog.rb"
load "./lib/aiproject.rb"


Find.find("./aiga/case") do |filename|
	load filename if filename =~ /\.rb$/
end


p = AIAuto::AIProject.new(
	:task_id=> 100, 
	:task_name=>"一般测试", 
	:plan_id=>200, 
	:ora_db_url=>"//10.1.195.100:1521/ats.database", 
	:ora_db_username=>"pageframe", 
	:ora_db_password=>"pageframe") 
$b ||= AIAuto::Browser.new :chrome
p.browser = $b

# data = {}
# data[:script_id] = 124
# data[:script_name] = "工程管理_删除工程"
# data[:script_module] = "系统管理"
# data[:data_id] =  100
# data[:data_name] = "测试数据"
# data[:data_desc] = "测试所使用的数据"
# data["工程名称"] = "test工程"
# data["脚本类型"] = "Silktest自动化测试"
# p.run_case_test_method ProjectMgr, :testDelProject, data

for index in (1..2)
	data = {}
	data[:script_id] = 123
	data[:script_name] = "工程管理_新增工程"
	data[:script_module] = "系统管理"
	data[:data_id] = index
	data[:data_name] = "测试数据#{index}"
	data[:data_desc] = "测试所使用的数据"
	data["工程名称"] = "test工程#{index}"
	data["脚本类型"] = "Silktest自动化测试"

	p.run_case_test_method ProjectMgr, :testAddProject, data

	data = {}
	data[:script_id] = 124
	data[:script_name] = "工程管理_查找工程"
	data[:script_module] = "系统管理"
	data[:data_id] = index + 100
	data[:data_name] = "测试数据#{index}"
	data[:data_desc] = "测试所使用的数据"
	data["工程名称"] = "test工程#{index}"
	data["脚本类型"] = "Silktest自动化测试"
	p.run_case_test_method ProjectMgr, :testFindProject, data


	data = {}
	data[:script_id] = 124
	data[:script_name] = "工程管理_删除工程"
	data[:script_module] = "系统管理"
	data[:data_id] = index + 100
	data[:data_name] = "测试数据#{index}"
	data[:data_desc] = "测试所使用的数据"
	data["工程名称"] = "test工程#{index}"
	data["脚本类型"] = "Silktest自动化测试"
	p.run_case_test_method ProjectMgr, :testDelProject, data
end




#p.run_case_test_method ProjectMgr, :testAddProject, data
#p.run_case_test_method ProjectMgr, :testFindProject, data
#p.run_case_test_method ProjectMgr, :testDelProject, data



p.end


#$b.element(:xpath=>'//a/span[text()="自动化测试管理"]').click

