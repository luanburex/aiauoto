#工具说明
该工具一个封装Selenium webdriver的自动化执行的框架。该工具提供如下新的功能：
* 使用GUI来保存对象
* 提供数据驱动方式执行脚本
* 规范脚本编写方式
* 拥有统一的脚本运行方式
* 提供报告输出
* 封装控件操作提升编写效率
* 提供比较完成的日志输出

##目录结构
+ lib 目录是工具库
+ result 目录为文件执行结果目录
+ aialm/cep 目录用于存放不同工程的脚本和GUI
	+ case 脚本文件
	+ gui GUI文件

##GUI

###GUI的理解
商业工具都在使用GUI来保存工具标识，而开源工具基本上都没有使用这样方式。而是使用类似描述变成的方式。那么GUI到底是好还是坏呢？

GUI的优点：
* 清晰易维护：控件的标识，一般都是难懂的字符串，而直接使用ID和name非常少见，对于中国用户来说，难懂的英文是一个阅读的障碍，而在调试和维护脚本中，如果没有注释，不用GUI的脚本是很难读懂的，而使用GUI可以避免这个情况
* 有层次：GUI可以提供清晰的层次结构，在不使用GUI的页面，那么层次结构是非常难定义的，尤其是在有IFrame和Window的情况，我们都是用selenium中的switch指来指去的，代码混乱，写程序也容易错位。而使用GUI可以根据层次结构组织GUI，还可以根据根据层次中的Iframe和window来定位元素
* 更适合抓取：如果使用抓取工具的话，那么整页抓取形成GUI，比录制更方便。录制的脚本可用性不高，但是抓取GUI再根据GUI编写脚本会更加稳定，编写也更加有效率（这算是最佳实践）

GUI的缺点：
* 多写一个名字：似乎费事了，不过如果不多写这个名字，而是写一堆似是而非的注释来说明脚本的执行，那就更加费事了。


###GUI的格式
1. 文件的扩展名一般是.gui(虽然这不是强制规定)
2. 文件格式:[类型名称(Element可忽略)][TAB][中文名称][TAB][Xpath]
类型名称主要分为：Page IFrame Window Element 四种，其中Element类型可忽略不写
分割要使用[TAB],层次也需要根据[TAB]来设置
例如：
···ruby
Page	机器管理页面
	IFrame	主页面	//iframe[@id="mainFrame"]

		机器名称搜索	//span[@id="FormRowSet_searchFrm_NAME"]/input
		查询机器	//input[@value="查询机器"]
		查询结果表	//table[@id="DataTable_macTbl"]
		查询结果表第一行第一列	//table[@id="DataTable_macTbl"]/tbody/tr/td
```
3. XPath, GUI只支持xpath方式，其他除index的属性不能使用，都可以通过xpath来做替代。


###关于GUI抓取
TODO：xpath说明和抓取工具的说明
Xpath：
@attribute
parent
text()
contains()


##脚本文件的编写
脚本文件是标准ruby的文件，[文件名].rb。

脚本文件里需要定义一个类，保证类名和文件名一致；
类需要继承自TestCase（在实际使用中，可以写一个工程的TestCase让所有Case继承这个Case，可参看样例 ResMgn < CepCase < AIAuto::TestCase;
类中的构造函数，要调用父函数的构造方法（super(browser))还有加载gui
类中的执行方法，需要使用以test开头，里面可以通过@browser获取浏览器对象

###元素获取API
fetch_element_from_gui(gui_name): 获取GUI名称的元素，进行操作
fetch_gui_wait_display(gui_name): 等待GUI名称的元素显示
element(:xpath=>xxxxx): 获取元素，也就是不使用GUI也可以获得元素	
elements(:xpath=>xxxxxx)：获得多个元素
其他方法请参看工程API

PS：GUI名称是路径名，例如："机器管理页面.主页面.机器名称搜索"。这里的iframe和window都会自行处理，不用再使用switch_to的方法

###场景恢复
TODO：如何写场景恢复


###关于iframe/window/alert
TODO: 处理方式说明

###关于wait

###关于doubleclick/mouse_over


##脚本执行
由于我们的脚本都继承自Testcase，那么就可以通过AIProject来进行执行，执行分集中类型
1. 执行所有的testXxxx方法：run_case_test_method(class_name)
```
p = AIAuto::AIProject.new
p.run_case_test_method ResStore
```
2. 执行类中的某个方法：run_case_test_method(class_name, function_name)
```
p = AIAuto::AIProject.new
p.run_case_test_method ResStore, :testSubmitApply
```
3. 执行某个方法，使用数据驱动：run_case_test_method(class_name, function_name,datas) datas是由hash构成的数组。（PS：使用这种方法要保证case类中定义的方法，接收data参数）
```
data = [{:a=>1, :b=>2}, {:a=>3, :b=>5}]
p = AIAuto::AIProject.new
p.run_case_test_method ResStore, :testSubmitApply, data
```

##输出日志
TODO：
case_start_log and case_end_log
logger.log
screenshot

##如何调试
ruby是一个脚本程序，最好使用irb进行调试，调试分为两种：1.执行完成用例，2.执行一条命令尝试

1.执行完成用例, 可以在irb中通过load脚本执行脚本运行程序，达到调试，注意：可以使用全局变量来保存browser，这样有助于在irb中继续执行。例如：
```
require 'find'

Find.find("./case") do |filename|
	load filename if filename =~ /\.rb$/
end


p = AIAuto::AIProject.new

$b ||= AIAuto::Browser.new :ie
p.browser = $b


p.run_case_test_method ResMgn, :testDel
puts p.result_stat.join("\n")
```
可以load上面的文件，执行ResMgn中的testDel方法，执行完毕后，浏览器未关闭，依然可以用$b来进行调试，实验
2.一条命令执行
可以在irb中执行输入，也可多条写到rb文件里，用load方法调用执行

PS：编码问题：irb在windows下使用的是GBK编码，使用中文可能会有问题