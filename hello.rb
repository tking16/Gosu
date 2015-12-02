require 'gosu'

class Hello < Gosu::Window
	
	def initialize width=800, height=600, fullscreen=false
		super
		self.caption = "hello ruby"
		@Image = Gosu::Image.from_text self, "Hello ruby", Gosu.default_font_name, 100
	end
	
	def button_down id
		close if id == Gosu::KBEscape
	end
	
	def draw
		@Image.draw @x ,@y,0
	end
	
	def update
		@x = self.width/2 - @Image.width/2 + Math.sin(Time.now.to_f)*100
		@y = self.height/2 - @Image.height/2
	end
	
end

Hello.new.show