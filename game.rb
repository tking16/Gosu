require 'gosu'

class Player 	
  attr_accessor :x, :y, :max_x
	def initialize window
		@window = window
    #Image
    @width = @height = 150
    @idle = Gosu::Image.load_tiles @window, "media/rubychar.png", @width, @height, true
    #starting location
    @x = 30
    @y = 430
    #bounds
    @min_x = 0
    @max_x = @window.width
    #movement
    @direction = :right
    @frame = 0 #the number of the image from sprite sheet
	end
	
  def update
    @frame += 1 
    if @window.button_down? Gosu::KbLeft
      @direction = :left
      @x += -5 
      @x = @min_x if @x < @min_x
    end
    
    def wall
      if Gosu::distance(@x,@y,wall.x,wall.y) < 35
        @x=0
      end
    end
    
    if @window.button_down? Gosu::KbRight
    @direction = :right
    @x += 5
    @x = @max_x if @x > @max_x
    end
    
  end
  
  def draw
    f = @frame % @idle.size
    image = @idle[f] #calculation above is now in an array
    if @direction == :right
    image.draw @x, @y, 1,1,1
    else
      image.draw @x + image.width, @y, 1, -1

    end
  end
  
end


class Wall
  def initialize img, x, y
    @img = img
    @x = @y = 0
  end
  
  def draw
    @img.draw(500,440,1)
  end
end

class Game < Gosu::Window
	
	def initialize width=1000, height = 600, fullscreen=false
		super
    @sprite = Player.new self
    @wall = Wall.new Gosu::Image.new("media/tile.png"), 300, 430
    @backdrop = Gosu::Image.new(self, "media/background1.png", false)
    @foreground = Gosu::Image.new(self, "media/foreground.png", false)
    @sprite.max_x = @foreground.width
    @x = @y = 0
	end
  
  def update
    @sprite.update
  end
	
  def draw
    translate *plx_coords do
    @backdrop.draw 0,0,-2,0.9,0.4
    end
    translate *cam_coords do
      @foreground.draw 0,430,-1
    @sprite.draw
      @wall.draw
    end
  end
  
  def button_down id
    close if id == Gosu::KbEscape
  end
  #paralax
  def plx_ratio
    @plx_ratio ||= (@backdrop.width - self.width) / (@foreground.width - self.width).to_f
  end
  
  def plx_coords
    [(cam_coords.first * plx_ratio), 0]
  end
  
  def cam_coords
    cam_x = [[@sprite.x - self.width/2, 0].max, [@sprite.x + self.width/2, @foreground.width - self.width].min].min
    [0 - cam_x, 0 - @y]
  end
  
end



Game.new.show