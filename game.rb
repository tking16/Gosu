require 'gosu'

class Game < Gosu::Window
	
	def initialize width=800, height = 600, fullscreen=false
		super
		def draw
		
		end
	end
	
end

class Player 
	
	def initialize window
		@window = window
		@image = Gosu::Image.new @window, "rubychar.png"
	end
	
end


Game.new.show