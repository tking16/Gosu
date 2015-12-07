$LOAD_PATH<<'.'
require 'gosu'
require 'puzzle_objects'

class Player 	
  attr_accessor :x, :y, :max_x, :is_key
	def initialize window
		@window = window
    #Image
    @width = @height = 150
    @idle = Gosu::Image.load_tiles @window, "media/rubychar.png", @width, @height, true
    @boat_spr = Gosu::Image.new @window, "media/spr_boat.png", @width, @height, false
    @key_spr = Gosu::Image.new @window, "media/key_spr.png", @width, @height, false
    #starting location
    @x = 30
    @y = 430
    #bounds
    @min_x = 0
    @max_x = @window.width
    #movement
    @direction = :right
    @frame = 0 #the number of the image from sprite sheet
    @is_boat = false
    @is_key = false
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
    if @is_boat == true
      image = @boat_spr
    elsif @is_key == true
      image = @key_spr
    else
      image = @idle[f] #calculation above is now in an array
    end
    if @direction == :right
    image.draw @x, @y, 1,1,1
    else
      image.draw @x + image.width, @y, 1, -1
    end
    if @x > @window.river.x - 100  && @window.river.passable == true && @x < @max_x - @window.river.x - 100
      @is_boat = true
    else
      @is_boat = false
    end
  end
  
end

include Objects


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
  attr_accessor :river
	def initialize width=1000, height = 600, fullscreen=false
		super
    @sprite = Player.new self
    #puzzle items
    @wall = Wall.new Gosu::Image.new("media/door_spr.png"), 300, 460
    @river = River.new Gosu::Image.new("media/spr_river.png"), 400, 460
    @post = Advance.new Gosu::Image.new("media/nxtlvl.png"), 400, 460
    #background
    @backdrop = Gosu::Image.new(self, "media/background1.png", false)
    @foreground = Gosu::Image.new(self, "media/foreground.png", false)
    @sprite.max_x = @foreground.width
    @x = @y = 0
    @level = 1
    font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    
    @text_input = Input.new(self, font, 50, 30)
    @cursor = Gosu::Image.new(self, "media/tile.png", false)
    @music = Gosu::Song.new "media/gameMusic.wav"
    @music.volume = 0.4
    @music.play
    puzzle_count = 0
	end
  
  def update
    @sprite.update  
    #puzzle solvers
    if @sprite.x > @wall.x - 100 && @wall.passable == false
      @help = Gosu::Image.from_text self, "A massive door is in the way \n create a key class to \n unlock the door", Gosu.default_font_name, 40
       @sprite.x = @wall.x - 100
    elsif @sprite.x > @wall.x - 100 && @wall.passable == true
      @wall.y -= 5
      @sprite.is_key = false
    end
    if @sprite.x > @river.x - 100 && @river.passable == false
      @sprite.x = @river.x - 100
      @help = Gosu::Image.from_text self, "It's a river. You're gonna need a boat \n to get across. Your boat needs to have \n a float method", Gosu.default_font_name, 40
    end
    
    
    if @sprite.x > @post.x - 100 
      @level = 2
      @sprite.x = 30
      @backdrop = nil
      @backdrop = Gosu::Image.load_tiles(self, "media/bg2.png", true)
      @river.y += 1000
    end
    #help boards
    
  end
	
  def draw
    translate *plx_coords do
    @backdrop.draw 0,0,-2,1,0.4
      if @level == 2
        @backdrop.draw 0,0,-2,1,1
      end
    end
    translate *cam_coords do
      @foreground.draw 0,430,2
      @sprite.draw
      @wall.draw
      @river.draw
      @post.draw
      unless @help.nil?
      @help.draw 350, 100, 2,1,1,0xcc666666
      end
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
      error_help(self.text_input.text)
      puzzle_solved(self.text_input.text)
      self.text_input.text = ""
      #close off textbox
      elsif id == Gosu::MsRight
      if self.text_input
        self.text_input = nil
      end
    
    end
  end
  
  def puzzle_solved block
    if block == "class Key end"
      @wall.passable = true
      @sprite.is_key = true
      @help = nil
    elsif block == "class Boat def float end end" && @wall.passable
      @river.passable = true
      @sprite.x += 5 until @sprite.x == @river.x
    end
  end
  
  def error_help block
    if block == "class key end"
      @help = nil
      @help = Gosu::Image.from_text self, "Syntax error: Don't forget \n class names begin with \n capital letters", Gosu.default_font_name, 40
    end
    if block == "class Key" || block == "class key"
      @help = nil
      @help = Gosu::Image.from_text self, "error: Don't forget the 'end' keyword", Gosu.default_font_name, 40
    end
    if block == "class Boat end"
      @help = nil
      @help = Gosu::Image.from_text self, "Don't forget your 'float' method!", Gosu.default_font_name, 40
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

    
    class Puzzles
      def initialize window
        @window = window
        @text = text
        @obj = obj
      end
      def update
      end
    end

Game.new.show