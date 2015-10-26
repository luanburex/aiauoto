#coding:utf-8
#require "./cep/case/catalogMgr"
require 'find'



Find.find("./cep/case") do |filename|
	load filename if filename =~ /\.rb$/
end


p = AIAuto::AIProject.new

$b ||= AIAuto::Browser.new :chrome
p.browser = $b

#p.run_case_test_method CatalogMgr, "test_delete_dir"
#p.run_case_test_method CatalogMgr, :test_delete_dir
p.run_case_test_method CatalogMgr, :test_search
puts p.result_stat.join("\n")