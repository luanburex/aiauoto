#coding:utf-8
$LOAD_PATH.unshift  File.expand_path(File.join(File.dirname(__FILE__)))
require "../lib/aibrowser.rb"

module AIAuto
	class Browser
		def tree_select tree_name, path=[]
			fetch_element_from_gui(tree_name)
			path.each do |p|
				e = element(:xpath=>'//div[@id="$Tree_staffTree"]//label[text()="' + p + '"]/parent::*/parent::*/td/img[contains(@id, "$Tree_staffTree|||")]')
				e.click if e.attribute("src") =~ /close\.gif/
				sleep(0.5)
				e.click if e.attribute("src") =~ /close\.gif/
				if e.attribute("src") =~ /node\.gif/
					e = element(:xpath=>'//div[@id="$Tree_staffTree"]//label[text()="' + p + '"]')
					e.click
					e.click
				end
			end
		end

		def table_click_column_by_text table, text
			table.find_element(:xpath=>"//table[@id=\"#{table.attribute("id")}\"]/tbody/tr/td[text()=\"#{text}\"]").click
		end
	end
end

class CepCase < AIAuto::TestCase

	def initialize browser = nil
		super(browser)
		init_parameter
		init_cep_gui
	end

	def init_parameter
		@username = "administrator"
		@password = "Abc123"
		@login_url = "http://10.1.195.100:8081/aialm/"
	end

	def init_cep_gui
		@browser.read_gui_string '''
Page	登录页面
	用户名称输入框	//input[@id="UserAccount"]
	密码输入框	//input[@id="UserPwd"]
	登录按钮	//input[@id="loginIMG"]
Page	主页面
	主框架DIV	//div[@id="frameBodyDiv"]
		'''
	end

	def login username, password
		@browser.goto @login_url

		@browser.fetch_element_from_gui("登录页面.用户名称输入框").set username
		@browser.fetch_element_from_gui("登录页面.密码输入框").set password
		@browser.fetch_element_from_gui("登录页面.登录按钮").click
	end
	
	def menu first, second, third = nil

		first_xpath = '//li/em[text()="' + first + '"]'
		second_xpath = '//li/a[text()="' + second + '"]'
		@browser.wait_until(:message=>"等待一级窗口出现") {@browser.element(:xpath => first_xpath)}
		
		@browser.driver.action.move_to(@browser.element(:xpath=>first_xpath)).perform
		@browser.element(:xpath => first_xpath).click
		begin
			@browser.element(:xpath => second_xpath).click
		rescue
			#@browser.driver.action.move_to(@browser.element(:xpath=>first_xpath)).perform
			@browser.element(:xpath => first_xpath).click
			@browser.element(:xpath => second_xpath).click
		end
	end

	def scence_recover
		@logger.log "[Recover]Start"

		begin
			@browser.title
		rescue
			@logger.log "[Reover]Reopen the browser..."

			@browser = AIAuto::TestCase.new(AIAuto::Browser.new :ie)
			init_cep_gui
		end
		
		@logger.log "[Revoer] goto main page."
		if @browser.find_element_from_gui("主页面.主框架DIV").nil?
			@browser.goto "http://10.1.195.100:8081/aialm"
			login @username, @password
		else
			@browser.goto "http://10.1.195.100:8081/aialm/webframe/shdesktopui/WebAppFrameSet_new.jsp"
		end

		@logger.log "[Recover]End"
	end

	

	
end