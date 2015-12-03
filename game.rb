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
  attr_accessor :x, :y
  def initialize img, x, y
    @img = img
    @x = 500
    @y = 440
  end
  
  def draw
    @img.draw(@x,@y,1)
  end
end

class Input < Gosu::TextInput  
  attr_reader :x, :y
  INACTIVE_COLOR = 0xcc666666
  ACTIVE_COLOR = 0xccff6666
  SELECTION_COLOR = 0xcc0000ff
  CARET_COLOR     = 0xffffffff
  PADDING = 5
	
  def initialize window, font, x, y
    super()
    @window = window
    @font = font
    @x = x
    @y = y
    self.text = "Enter code here!"
  end
  
  def draw
    if @window.text_input == self
      background_color = ACTIVE_COLOR
    else
      background_color = INACTIVE_COLOR
    end
    @window.draw_quad(x - PADDING,         y - PADDING,          background_color,
                      x + width + PADDING, y - PADDING,          background_color,
                      x - PADDING,         y + height + PADDING, background_color,
                      x + width + PADDING, y + height + PADDING, background_color, 0)
    pos_x = x + @font.text_width(self.text[0...self.caret_pos])
    sel_x = x + @font.text_width(self.text[0...self.selection_start])
    
    
    	    # Draw the selection background, if any; if not, sel_x and pos_x will be
    # the same value, making this quad empty.
    @window.draw_quad(sel_x, y,          SELECTION_COLOR,
                      pos_x, y,          SELECTION_COLOR,
                      sel_x, y + height, SELECTION_COLOR,
                      pos_x, y + height, SELECTION_COLOR, 0)
    
	    if @window.text_input == self then
      @window.draw_line(pos_x, y,          CARET_COLOR,
                        pos_x, y + height, CARET_COLOR, 0)
    end
# draw the text!
    @font.draw(self.text, x, y, 0)
        
end
    
    def width
    @font.text_width(self.text)
  end
        
  def height
    @font.height
  end
        
  def under_point?(mouse_x, mouse_y)
    mouse_x > x - PADDING and mouse_x < x + width + PADDING and
    mouse_y > y - PADDING and mouse_y < y + height + PADDING
  end
        
# Tries to move the caret to the position specifies by mouse_x
  def move_caret(mouse_x)
    # Test character by character
    1.upto(self.text.length) do |i|
      if mouse_x < x + @font.text_width(text[0...i]) then
        self.caret_pos = self.selection_start = i - 1;
        return
      end
    end
    # Default case: user must have clicked the right edge
    self.caret_pos = self.selection_start = self.text.length
  end
        
  end

class Game < Gosu::Window
	def initialize width=1000, height = 600, fullscreen=false
		super
    @sprite = Player.new self
    @wall = Wall.new Gosu::Image.new("media/tile.png"), 300, 460
    @backdrop = Gosu::Image.new(self, "media/background1.png", false)
    @foreground = Gosu::Image.new(self, "media/foreground.png", false)
    @sprite.max_x = @foreground.width
    @x = @y = 0
    font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    
    @text_input = Input.new(self, font, 50, 30)
    @cursor = Gosu::Image.new(self, "media/tile.png", false)
	end
  
  def update
    @sprite.update
    
          
    if @sprite.x > @wall.x - 100
      @sprite.x= @wall.x - 100
      end
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
    
    @text_input.draw
    @cursor.draw(mouse_x, mouse_y, 0)
  end
  
  
  def button_down id
    if id == Gosu::KbEscape
      close
      elsif id == Gosu::MsLeft
      self.text_input = @text_input
      self.text_input.move_caret(mouse_x) unless self.text_input.nil?
    elsif id == Gosu::KbEnter
      self.text_input.x = -500
    end
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