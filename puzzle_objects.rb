module Objects
  class Wall
    attr_accessor :x, :y, :passable
  def initialize img, x, y
    @img = img
    @x = 500
    @y = 240
    @passable = false
  end
  
  def draw
    @img.draw(@x,@y,0)
  end
end
  
  class River
    attr_accessor :x, :y, :passable
  def initialize img, x, y
    @img = img
    @x = 800
    @y = 400
    @passable = false
  end
    
  def draw
    @img.draw(@x,@y,0)
  end
    
  end
  
  class Advance
    attr_accessor :x, :y, :passable
  def initialize img, x, y
    @img = img
    @x = 2000
    @y = 450
  end
    
  def draw
    @img.draw(@x,@y,1)
  end
  end
  
end