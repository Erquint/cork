# UTF-8
# DRGTK Pro 3.0 RC

class Vec2
  include Giatros::Ducks::Serialize
  alias abs length
  alias abs_sq length_sq
  alias unit normalize
  alias perpdot cross
end

def ortho_proj v_offset, v_base, v_other
  offset = v_offset
  base = v_base - v_offset
  other = v_other - v_offset
  theta = (((Math.atan2(other.y, other.x) - Math.atan2(base.y, base.x) + Math::PI) % (2 * Math::PI)) - Math::PI)
  costheta = Math.cos theta
  proj_magnitude = other.abs * costheta
  proj_bound = (0..1).include?(proj_magnitude / base.abs)
  projected = base.unit.scale proj_magnitude
  return {
    offset: offset,
    theta: theta,
    costheta: costheta,
    proj_magnitude: proj_magnitude,
    proj_bound: proj_bound,
    local: {base: base, other: other, projected: projected},
    global: {base: base + offset, other: other + offset, projected: projected + offset}
    # global: {base: v_base, other: v_other, projected: projected + offset}
  }
end

# https://stackoverflow.com/a/1968345/2407356
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
