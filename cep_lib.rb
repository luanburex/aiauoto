#coding:utf-8
require "./lib/aibrowser.rb"

module AIAuto
	class Browser
		def cep_select(element_name, select_text)
			fetch_element_from_gui(element_name).click
			@driver.find_elements(:xpath=>'//div[@class="panel combo-p"]/div/div').each do |e|
				puts "click:#{e.text} equal #{select_text} , result: #{select_text == e.text}"
				if e.text == select_text
					e.click

				end
			end
		end

		def cep_alert()
			alerts = @driver.find_elements(:xpath=>'//div[contains(@class, "aui_outer")]')
			raise "No Alert Window apppeared." if(alerts.size <= 0)
			error_alerts = @driver.find_elements(:xpath=>'//div[contains(@class, "aui_outer")]//div[contains(@style, "error.png")]')
			raise "Error Alert in window. information:#{@driver.find_element(:xpath=>'//div[contains(@class, "aui_outer")]//div[contains(@class, "ui_content")]').text}" if error_alerts.size > 0
			message = @driver.find_element(:xpath=>'//div[contains(@class, "aui_outer")]//div[contains(@class, "ui_content")]').text
			@driver.find_element(:xpath=>'//button[contains(@class, "aui_state_highlight") and text()="确定"]').click
			return message
		end
	end
end