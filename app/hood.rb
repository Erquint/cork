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
  }
end
