module Objects
  class Wall
    attr_accessor :x, :y, :passable
  def initialize img, x, y
    @img = img
    @x = 500
    @y = 440
    @passable = false
  end
  
  def draw
    @img.draw(@x,@y,1)
  end
end
  
  class River
    attr_accessor :x, :y, :passable
  def initialize img, x, y
    @img = img
    @x = 800
    @y = 450
    @passable = false
  end
    
  def draw
    @img.draw(@x,@y,1)
  end
    
  end
  
end