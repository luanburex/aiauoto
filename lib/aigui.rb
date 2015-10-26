#coding:utf-8
module AIAuto
	module GUI
		GUI_STORAGE = []

		class GElement
			attr_accessor :name
			attr_accessor :xpath
			attr_accessor :type
			attr_accessor :parent

			def initialize(name, xpath, type='element', parent=nil)
				@name = name
				@xpath = xpath
				@type = type
				@parent = parent
			end
		end

		class GUIFormatException < StandardError; end


		class <<self

			def read_gui_string str, replace=true
				@guis ||= {}
				path = []
				str.each_line do |line|
					next if line.strip.size <= 0
					tab_num = get_gui_line_tab(line)
					element_arr = line.strip.split("\t")
					
					if(element_arr.size != 2 and element_arr.size != 3)
						raise GUIFormatException, "gui formate should be:[Type]<Tab>[Name]<Tab>[Xpath], but line is :#{line}"
					end

					type = "element" 
					name = nil
					xpath = nil
					parent = nil

					case element_arr[0].downcase
					when "element" then 
						type = "element"
						name = element_arr[1]
						xpath = element_arr[2]
					when "iframe" then
						if element_arr.size == 2
							raise GUIFormatException, "gui formate should be:[Type]<Tab>[Name]<Tab>[Xpath], but line is :#{line}"
						end
						type = "iframe"
						name = element_arr[1]
						xpath = element_arr[2]
					when "page" then
						type = "page"
						name = element_arr[1]
					else
						if element_arr.size == 2
							type = "element"
							name = element_arr[0]
							xpath = element_arr[1]
						else
							type = element_arr[0]
							name = element_arr[1]
							xpath = element_arr[2]
						end
						
					end
					if tab_num > 0
						while path[tab_num - 1] == nil do
							tab_num -= 1
							break if tab_num == 0
						end
						parent = path[tab_num - 1]
						if parent != nil
							name = parent.name + "." + name
						end
					end
					element = GElement.new name, xpath, type, parent
					path[get_gui_line_tab(line)] = element
					if @guis.key? name and !replace
						raise "gui has the same name element. Name: #{name}"
					end
					@guis[element.name] = element
				end
				@guis
			end

			def read_gui_file filename, replace=true
				str = ""
				file=File.open(filename,"r:utf-8")
				file.each  do |line|
					str += line + "\n"
				end
			    file.close
			    
			    read_gui_string str, replace
			end


			def get_gui_line_tab line
				count = 0
				while line[count] == "\t" do
					count += 1;
				end
				return count
			end
		end
	end
end