# UTF-8
# DRGTK Pro 3.0 RC

require '/lib/giatros/ducks.rb'
require '/lib/xenovmath/vectormath.rb'
require '/lib/giatros/frametimer.rb'
require '/app/hood.rb'

# https://www.nagwa.com/en/explainers/175169159270/
# http://www.sunshine2k.de/coding/java/PointOnLine/PointOnLine.html.
# https://falstad.com/dotproduct/
# https://mathworld.wolfram.com/search/?query=vector+determinant&x=0&y=0
# https://www.xarg.org/book/linear-algebra/2d-perp-product/
# https://books.physics.oregonstate.edu/GMM/book-1.html
# https://books.physics.oregonstate.edu/LinAlg/book-1.html

# args.inputs.mouse.click && args.inputs.mouse.button_right
# if args.inputs.mouse.click
  # puts args.inputs.mouse.class.instance_methods
# end
# args.inputs.mouse&.button_right

=begin
class Array
  def v_inv # Inversion. → Vector
    return self.map(&:-@)
  end
  def v_add other # Vector addition. → Vector
    return self.zip(other).map {|pair| pair.first + pair.last}
    # return self.zip(other).map {|v_a, v_b| v_a + v_b}
    # return self.zip(other).map {|pair| pair.inject(&:+)}
  end
  def v_sub other # Vector subtraction. → Vector
    return self.v_add other.v_inv
  end
  def v_smult scalar # Scalar multiplication. Scaling. → Vector
    return self.map {|v| v * scalar}
  end
  def v_sdiv scalar # Scalar division. → Vector
    return self.v_smult (1.0 / scalar)
  end
  def v_cmult other # Complex multiplication. → Vector
    return [
      self.first * other.first - self.last * other.last,
      self.first * other.last  + self.last * other.first
    ]
  end
  def v_cdiv other # Complex division. → Vector
    return [
      (self.first * other.first + self.last * other.last) /
        (other.first ** 2 + other.last ** 2),
      (self.last * other.first - self.first * other.last) /
        (other.first ** 2 + other.last ** 2)
    ]
  end
  def v_mag # Magnitude. Norm. → Scalar
    return Math.sqrt((self.first ** 2) + (self.last ** 2))
    # return Math.sqrt(self.inject(0) {|sum, a| sum += a ** 2})
  end
  def v_unit # Normalize vector. → Vector
    return self.v_sdiv self.v_mag
  end
  def v_setmag scalar # Sets arbitrary magnitude. → Vector
    return self.v_unit.v_smult scalar
  end
  def v_theta other # Angle in radians. → Scalar
    return Math.acos(self.v_costheta other)
  end
  def v_costheta other # Cosine of angle in radians. → Scalar
    return (self.v_dprod other) / (self.v_mag * other.v_mag)
    # v1.unit.dot(v2.unit) == Math.cos(v1.theta(v2))
  end
  def v_perp # Perpendicular. → Vector
    return [-self.y, self.x]
  end
  def v_dprod other # Dot product. → Scalar
    raise 'Size mismatch!' unless self.size == other.size
    return self.zip(other).inject(0) {|sum, (v_a, v_b)| sum += v_a * v_b}
  end
  def v_pdprod other # Perp dot product. → Scalar
    return self.x * other.y - self.y * other.x
    # return self.v_perp.v_dprod other
    # return Math.sqrt((self.v_mag ** 2) * (other.v_mag ** 2) - ((self.v_dprod other) ** 2))
    # return Math.sqrt(((self.first ** 2) + (self.last ** 2)) * ((other.first ** 2) + (other.last ** 2)) - ((self.v_dprod other) ** 2))
  end
end
=end

    # raise 'Not vec2!' unless self.size == 2
    # raise 'Malformed vec2!' unless
      # self.x.is_a?(Float) || self.x.is_a?(Fixnum) &&
      # self.y.is_a?(Float) || self.y.is_a?(Fixnum)

# (a.v_pdprod b) ** 2 + (a.v_dprod b) ** 2 = (a.v_mag ** 2) * (b.v_mag ** 2)
# a.v_pdprod b = Math.sqrt((a.v_mag ** 2) * (b.v_mag ** 2) - ((a.v_dprod b) ** 2))
# a.v_pdprod b = Math.sqrt((Math.sqrt(a.inject(0) {|sum, a| sum += a ** 2}) ** 2) * (Math.sqrt(b.inject(0) {|sum, a| sum += a ** 2}) ** 2) - ((a.v_dprod b) ** 2))
# sqrt((a.inject(0) {|sum, a| sum += a ^ 2}) * (b.inject(0) {|sum, a| sum += a ^ 2}) - ((a.v_dprod b) ^ 2))
# \sqrt{\left(a_{x}^{2}+a_{y}^{2}\right)\left(b_{x}^{2}+b_{y}^{2}\right)-\left(a·b\right)^{2}}

# To be benchmarked.
# costheta = Math.cos(Math.acos( v1.dot(v2) / (v1.abs * v2.abs) ))
# costheta = Math.cos(Math.acos( v1.unit.dot(v2.unit) ))
# costheta = Math.cos( (Math.atan2(v1.x, v1.y) - Math.atan2(v2.x, v2.y)).abs )
# proj_bound = (0..1).include?(proj_magnitude / v1.abs)
# v3 = v1.unit.scale proj_magnitude # "Yellow" point.
# v3 = v1.v_setmag(v2.abs * v1.v_costheta(v2)) # "Yellow" point.
# proj_bound = (0..(v1.abs ** 2)).include?(v1.dot(v3))
# proj_bound = (0..(v1.dot(v1))).include?(v1.dot(v3))

def tick args
  if args.state.tick_count == 0
    $points = {
      lseg: Vec2.new(0.0, 0.0),
      rseg: Vec2.new(0.0, 0.0),
      circle: Vec2.new(0.0, 0.0),
      proj: Vec2.new(0.0, 0.0)
    }
    $mouse = $gtk.args.inputs.mouse
    $p_size = 5
    $c_radius = 50
  elsif args.state.tick_count > 0
    mouse_pos = [$mouse.x, $mouse.y]
    
    if $mouse.button_left
      $points[:lseg].set!(*mouse_pos)
    elsif $mouse.button_right
      $points[:rseg].set!(*mouse_pos)
    elsif $mouse.button_middle
      $points[:circle].set!(*mouse_pos)
    end
    
    if args.inputs.mouse.wheel
      $c_radius += 5 * args.inputs.mouse.wheel.y
      $c_radius = 0 if $c_radius.negative?
    end
    
    # op = nil
    # 1e4.truncate.times do
    op = ortho_proj $points[:lseg], $points[:rseg], $points[:circle]
    # end
    
    $points[:proj] = op[:global][:projected]
    
    if op[:proj_bound]
      proj_collision = (op[:local][:projected] - op[:local][:other]).abs < $c_radius
    else
      proj_collision = false
    end
    
    blue_collision = op[:local][:other].abs < $c_radius
    red_collision = (op[:local][:base] - op[:local][:other]).abs < $c_radius
    line_collision = proj_collision || red_collision || blue_collision
    
    rfar = op[:local][:base].scale(1e3) + $points[:lseg]
    lfar = op[:local][:base].invert.scale(1e3) + $points[:lseg]
    
    args.outputs.primitives << [
      { # Background.
        primitive_marker: :solid,
        x: $args.grid.x, y: $args.grid.y,
        w: $args.grid.w, h: $args.grid.h,
        r: 42, g: 42, b: 42
      }, { # Base line.
        primitive_marker: :line,
        x: lfar.x, y: lfar.y,
        x2: rfar.x, y2: rfar.y,
        r: 108, g: 108, b: 108
      }, { # Projection segment.
        primitive_marker: :line,
        x: $points[:circle].x, y: $points[:circle].y,
        x2: $points[:proj].x, y2: $points[:proj].y,
        r: 108, g: 108, b: 108
      }, { # Base segment.
        primitive_marker: :line,
        x: $points[:lseg].x, y: $points[:lseg].y,
        x2: $points[:rseg].x, y2: $points[:rseg].y,
        r: 255, g: 255, b: 255
      }, { # Other segment.
        primitive_marker: :line,
        x: $points[:lseg].x, y: $points[:lseg].y,
        x2: $points[:circle].x, y2: $points[:circle].y,
        r: 108, g: 108, b: 108
      }, { # Yellow point.
        primitive_marker: :solid,
        x: $points[:proj].x - $p_size / 2, y: $points[:proj].y - $p_size / 2,
        w: $p_size, h: $p_size, r: 255, g: 255, a: op[:proj_bound] ? 255 : 0
      }, { # Blue point.
        primitive_marker: :solid,
        x: $points[:lseg].x - $p_size / 2, y: $points[:lseg].y - $p_size / 2,
        w: $p_size, h: $p_size, b: 255
      }, { # Red point.
        primitive_marker: :solid,
        x: $points[:rseg].x - $p_size / 2, y: $points[:rseg].y - $p_size / 2,
        w: $p_size, h: $p_size, r: 255
      }, { # Green point.
        primitive_marker: :solid,
        x: $points[:circle].x - $p_size / 2, y: $points[:circle].y - $p_size / 2,
        w: $p_size, h: $p_size, g: 255
      }, { # Base vector point.
        primitive_marker: :solid,
        x: op[:local][:base].x - $p_size / 2, y: op[:local][:base].y - $p_size / 2,
        w: $p_size, h: $p_size,
        r: 255, g: 255, b: 255
      }, { # Base vector segment.
        primitive_marker: :line,
        x2: op[:local][:base].x, y2: op[:local][:base].y,
        r: 255, g: 255, b: 255
      }, { # Other vector point.
        primitive_marker: :solid,
        x: op[:local][:other].x - $p_size / 2, y: op[:local][:other].y - $p_size / 2,
        w: $p_size, h: $p_size,
        r: 255, g: 255, b: 255
      }, { # Other vector segment.
        primitive_marker: :line,
        x2: op[:local][:other].x, y2: op[:local][:other].y,
        r: 255, g: 255, b: 255
      }, { # Projected vector point.
        primitive_marker: :solid,
        x: op[:local][:projected].x - $p_size / 2, y: op[:local][:projected].y - $p_size / 2,
        w: $p_size, h: $p_size,
        r: 255, g: 255, b: 255
      }, { # Projected vector segment.
        primitive_marker: :line,
        x2: op[:local][:projected].x, y2: op[:local][:projected].y,
        r: 255, g: 255, b: 255
      }, { # Angle "arc".
        primitive_marker: :line,
        x: (op[:local][:base].unit.scale 15).x + $points[:lseg].x,
        y: (op[:local][:base].unit.scale 15).y + $points[:lseg].y,
        x2: (op[:local][:other].unit.scale 15).x + $points[:lseg].x,
        y2: (op[:local][:other].unit.scale 15).y + $points[:lseg].y,
        r: 213, g: 213
      }, { # Angle degrees readout.
        primitive_marker: :label,
        x: $points[:lseg].x + $p_size / 2, y: $points[:lseg].y + $p_size / 2,
        # text: "#{(op[:theta] / DEG2RAD).round(2)}°",
        text: "%.2f°" % (op[:theta] / DEG2RAD),
        r: 213, g: 213, b: 213
      }, { # Circle sprite.
        primitive_marker: :sprite,
        x: $points[:circle].x - $c_radius, y: $points[:circle].y - $c_radius,
        w: $c_radius * 2, h: $c_radius * 2,
        path: 'assets/circle.png',
      }.merge!(line_collision ? {r: 255, g: 0, b: 0} : {r: 255, g: 255, b: 255}),
      Giatros::Frametimer.frametime_label,
      Giatros::Frametimer.fps_label,
      Giatros::Frametimer.graph
    ]
  end
end

=begin
  $a, $b, $c = [0.8, 1.1], [9, 0.6], 100000
  
  if args.state.tick_count == 500
    time = Time.now; $c.times{$a.v_pdprod1 $b}; puts Time.now - time
  end
  if args.state.tick_count == 501
    time = Time.now; $c.times{$a.v_pdprod2 $b}; puts Time.now - time
  end
  if args.state.tick_count == 502
    time = Time.now; $c.times{$a.v_pdprod3 $b}; puts Time.now - time
  end
=end
