# UTF-8
# DRGTK Pro 3.0 RC

if $gtk.platform == 'Linux'
  $gtk.reset()
else
  $gtk.disable_nil_coersion!
end

# require '/lib/giatros/frametimer.rb'
# require '/lib/giatros/ducks.rb'
# require '/lib/giatros/nil_panic.rb'
# require '/app/hood.rb'

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

    # raise 'Not vec2!' unless self.size == 2
    # raise 'Malformed vec2!' unless
      # self.x.is_a?(Float) || self.x.is_a?(Fixnum) &&
      # self.y.is_a?(Float) || self.y.is_a?(Fixnum)

# (a.v_pdprod b) ** 2 + (a.v_dprod b) ** 2 = (a.v_mag ** 2) * (b.v_mag ** 2)
# a.v_pdprod b = Math.sqrt((a.v_mag ** 2) * (b.v_mag ** 2) - ((a.v_dprod b) ** 2))
# a.v_pdprod b = Math.sqrt((Math.sqrt(a.inject(0) {|sum, a| sum += a ** 2}) ** 2) * (Math.sqrt(b.inject(0) {|sum, a| sum += a ** 2}) ** 2) - ((a.v_dprod b) ** 2))
# sqrt((a.inject(0) {|sum, a| sum += a ^ 2}) * (b.inject(0) {|sum, a| sum += a ^ 2}) - ((a.v_dprod b) ^ 2))
# \sqrt{\left(a_{x}^{2}+a_{y}^{2}\right)\left(b_{x}^{2}+b_{y}^{2}\right)-\left(a·b\right)^{2}}

=begin
def proj_p2l
  # get dot product of e1, e2
  e1 = [v2.x - v1.x, v2.y - v1.y];
  e2 = [out.x - v1.x, out.y - v1.y];
  valDp = e1.dprod e2;
  # get squared length of e1
  len2 = e1.x * e1.x + e1.y * e1.y;
  out = [(int)(v1.x + (val * e1.x) / len2),
         (int)(v1.y + (val * e1.y) / len2)];
  return out;
end
=end

def tick args
  if args.state.tick_count == 0
    $points = {lseg: [0.0, 0.0], rseg: [0.0, 0.0], circle: [0.0, 0.0], alt_int: [0.0, 0.0]}
    $mouse = $gtk.args.inputs.mouse
    $p_size = 5
    $c_radius = 50
  elsif args.state.tick_count > 0
    mouse_pos = [$mouse.x, $mouse.y]
    
    if $mouse.button_left
      $points[:lseg] = mouse_pos
    elsif $mouse.button_right
      $points[:rseg] = mouse_pos
    elsif $mouse.button_middle
      $points[:circle] = mouse_pos
    end
    
    if args.inputs.mouse.wheel
      $c_radius += 5 * args.inputs.mouse.wheel.y
      $c_radius = 0 if $c_radius.negative?
    end
    
    # Offset vectors.
    v0 = $points[:lseg] # Local origin.
    v1 = [$points[:rseg].x, $points[:rseg].y].v_sub(v0) # "Red" point.
    v2 = [$points[:circle].x, $points[:circle].y].v_sub(v0) # "Green" point.
    v3 = v1.v_setmag(v2.v_mag * v1.v_costheta(v2)) # "Yellow" point.
    
    $points[:alt_int] = v3.v_add v0 # Altitude intersection point.
    
    # selfdot = v1.v_dprod(v1)
    alt_int_onseg = (0..(v1.v_mag ** 2)).include?(v1.v_dprod(v3))
    a_collision = (v3.v_sub(v2).v_mag < $c_radius && alt_int_onseg)
    l_collision = v2.v_mag < $c_radius
    r_collision = v1.v_sub(v2).v_mag < $c_radius
    line_collision = a_collision || r_collision || l_collision
    
    rfar = v1.v_smult(1e3).v_add(v0)
    lfar = v1.v_inv.v_smult(1e3).v_add(v0)
    
    args.outputs.primitives << [
      {
        primitive_marker: :solid,
        x: $args.grid.x, y: $args.grid.y,
        w: $args.grid.w, h: $args.grid.h,
        r: 42, g: 42, b: 42
      # }, {
      #   primitive_marker: :label,
      #   x: $args.grid.x, y: $args.grid.h - $args.grid.h / 16,
      #   text: "collision: #{collision}, c_dist: #{c_dist}",
      #   r: 213, g: 213, b: 213
      }, {
        primitive_marker: :line,
        x: lfar.x, y: lfar.y,
        x2: rfar.x, y2: rfar.y,
        r: 108, g: 108, b: 108
      }, {
        primitive_marker: :line,
        x: $points[:lseg].x, y: $points[:lseg].y,
        x2: $points[:rseg].x, y2: $points[:rseg].y,
        r: 255, g: 255, b: 255
      }, {
        primitive_marker: :line,
        x: $points[:circle].x, y: $points[:circle].y,
        x2: $points[:alt_int].x, y2: $points[:alt_int].y,
        r: 108, g: 108, b: 108
      }, {
        primitive_marker: :solid,
        x: $points[:lseg].x - $p_size / 2, y: $points[:lseg].y - $p_size / 2,
        w: $p_size, h: $p_size, b: 255
      }, {
        primitive_marker: :solid,
        x: $points[:rseg].x - $p_size / 2, y: $points[:rseg].y - $p_size / 2,
        w: $p_size, h: $p_size, r: 255
      }, {
        primitive_marker: :solid,
        x: $points[:circle].x - $p_size / 2, y: $points[:circle].y - $p_size / 2,
        w: $p_size, h: $p_size, g: 255
      }, {
        primitive_marker: :sprite,
        x: $points[:circle].x - $c_radius, y: $points[:circle].y - $c_radius,
        w: $c_radius * 2, h: $c_radius * 2,
        path: 'assets/circle.png',
      }.merge!(line_collision ? {r: 255, g: 0, b: 0} : {r: 255, g: 255, b: 255}), {
        primitive_marker: :solid,
        x: $points[:alt_int].x - $p_size / 2, y: $points[:alt_int].y - $p_size / 2,
        w: $p_size, h: $p_size, r: 255, g: 255, a: alt_int_onseg ? 255 : 0
      }, {
        primitive_marker: :solid,
        x: v1.x - $p_size / 2, y: v1.y - $p_size / 2,
        w: $p_size, h: $p_size,
        r: 255, g: 255, b: 255
      }, {
        primitive_marker: :line,
        x2: v1.x, y2: v1.y,
        r: 255, g: 255, b: 255
      }, {
        primitive_marker: :solid,
        x: v2.x - $p_size / 2, y: v2.y - $p_size / 2,
        w: $p_size, h: $p_size,
        r: 255, g: 255, b: 255
      }, {
        primitive_marker: :line,
        x2: v2.x, y2: v2.y,
        r: 255, g: 255, b: 255
      }, {
        primitive_marker: :solid,
        x: v3.x - $p_size / 2, y: v3.y - $p_size / 2,
        w: $p_size, h: $p_size,
        r: 255, g: 255, b: 255
      }, {
        primitive_marker: :line,
        x2: v3.x, y2: v3.y,
        r: 255, g: 255, b: 255
      # }, {
        # primitive_marker: :label,
        # x: $args.grid.x, y: $args.grid.h - $args.grid.h / 64,
        # text: "",
        # r: 213, g: 213, b: 213
      # }, {
        # primitive_marker: :label,
        # x: $args.grid.x, y: $args.grid.h - $args.grid.h / 16,
        # text: "",
        # r: 213, g: 213, b: 213
      # }, {
        # primitive_marker: :label,
        # x: $args.grid.x, y: $args.grid.h - $args.grid.h / 16,
        # text: "",
        # r: 213, g: 213, b: 213
      # }, {
        # primitive_marker: :label,
        # x: $args.grid.x, y: $args.grid.h - $args.grid.h / 16,
        # text: "",
        # r: 213, g: 213, b: 213
      }
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
