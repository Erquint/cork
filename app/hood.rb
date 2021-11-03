# UTF-8
# DRGTK Pro 3.0 RC

class Vec2
  include Giatros::Ducks::Serialize
  alias abs length
  alias abs_sq length_sq
  alias unit normalize
  alias perpdot cross
end

def ortho_proj global_offset, global_base, global_other
  base = global_base - global_offset
  other = global_other - global_offset
  theta = (((Math.atan2(other.y, other.x) - Math.atan2(base.y, base.x) + Math::PI) % (2 * Math::PI)) - Math::PI)
  costheta = Math.cos theta
  proj_magnitude = other.abs * costheta
  proj_bound = (0..1).include?(proj_magnitude / base.abs)
  projected = base.unit.scale proj_magnitude
  return {
    theta: theta,
    costheta: costheta,
    projected: {
      vector: projected + global_offset,
      magnitude: proj_magnitude,
      bound: proj_bound
    },
    local: {
      base: base,
      other: other,
      projected: projected
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
    # intersection = other0 + other.scale(other_scale)
    intersects = true
  else
    intersection = Vec2.new
    intersects = false
  end
  
  return {
    intersects?: intersects,
    intersection: intersection
  }
end
