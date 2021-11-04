# UTF-8
# DRGTK Pro 3.0 RC

class Vec2
  include Giatros::Ducks::Serialize
  
  def length
    Math.sqrt(length_sq)
  end
  
  def perp!
    x = @x
    @x = -@y
    @y = x
    return self
  end
  
  def perp
    dup.perp!
  end
  
  alias abs length
  alias abs_sq length_sq
  alias unit normalize
  alias perpdot cross
end

def ortho_proj global_offset, global_base, global_other
  base = global_base - global_offset
  other = global_other - global_offset
  # Check out Vec2#angle_to ?
  theta = (((Math.atan2(other.y, other.x) - Math.atan2(base.y, base.x) + Math::PI) % (2 * Math::PI)) - Math::PI)
  costheta = Math.cos theta
  proj_scale = other.abs * costheta
  proj_bound = (0..1).include?(proj_scale / base.abs)
  projection = base.unit.scale proj_scale
  return {
    theta: theta,
    costheta: costheta,
    projection: {
      vector: projection + global_offset,
      bound: proj_bound
    },
    local: {
      base: base,
      other: other,
      projection: {
        vector: projection,
        magnitude: proj_scale.abs
      }
    }
  }
end

def lineseg_int base0, base1, other0, other1
  base = base1 - base0
  other = other1 - other0
  
  pd = base.perpdot other
  delta0 = base0 - other0
  base_scale = other.perpdot(delta0) / pd
  other_scale = base.perpdot(delta0) / pd
  
  if (0..1).include?(base_scale) && (0..1).include?(other_scale)
    intersection = base0 + base.scale(base_scale)
    intersects = true
  else
    intersection = Vec2.new
    # Dafuq? Generalize this, you dumbass!
    intersects = false
  end
  
  return {
    intersects?: intersects,
    intersection: intersection
  }
end

def lineseg_end_distance base0, base1, other0, other1
  return [
    (base0 - other0).abs,
    (base0 - other1).abs,
    (base1 - other0).abs,
    (base1 - other1).abs
  ].min
end

def lineseg_dist base0, base1, other0, other1
  return 0 if lineseg_int(base0, base1, other0, other1)[:intersects?]
  lsed = lineseg_end_distance base0, base1, other0, other1
  projs = [
    ortho_proj(base0, base1, other0),
    ortho_proj(base0, base1, other1),
    ortho_proj(other0, other1, base0),
    ortho_proj(other0, other1, base1)
  ].filter{|proj| proj[:projection][:bound]}
    .map{|proj| (proj[:local][:projection][:vector] - proj[:local][:other]).abs}
  if projs.empty?
    return lsed
  else
    return [lsed, projs.min].min
  end
end
