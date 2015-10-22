

class A
	class <<self
		def a
			puts "a"
		end

		def b
			puts "b"
		end
	end
end

A.a
A.b