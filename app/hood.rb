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
  
  # Bracket 0.
  # theta = (Math.atan2(base.x, base.y) - Math.atan2(other.x, other.y)).abs # 190
  # theta = Math.acos(base.dot(other) / (base.abs * other.abs)) # 194
  # theta = Math.acos(base.unit.dot(other.unit)) # 230
  
  # costheta = Math.cos(Math.acos(base.dot(other) / (base.abs * other.abs))) # 185
  # costheta = Math.cos(Math.acos(base.unit.dot(other.unit))) # 221
  # costheta = Math.cos((Math.atan2(base.x, base.y) - Math.atan2(other.x, other.y)).abs) # 181
  # costheta = Math.cos theta # 180
  # End bracket 0.
  
  # Bracket 1.
  # theta = (Math.atan2(base.x, base.y) - Math.atan2(other.x, other.y)).abs
  theta = (((Math.atan2(other.y, other.x) - Math.atan2(base.y, base.x) + Math::PI) % (2 * Math::PI)) - Math::PI)
  costheta = Math.cos theta
  # 365
  # End bracket 1.
  
  # theta = Math.atan2(other.y, other.x) - Math.atan2(base.y, base.x)
  # costheta = Math.cos theta
  # 370
  # costheta = ((base.dot(other) / (base.abs * other.abs))).clamp(-1, 1)
  # theta = Math.acos(costheta)
  # 370
  
  # Bracket 2.
  # costheta = base.dot(other) / (base.abs * other.abs)
  # costheta = (base.dot(other) / (base.abs * other.abs)).clamp(-1, 1)
  # raise "WTF holy shit! #{costheta.inspect}" if Float::INFINITY == costheta.abs
  # begin
  # theta = Math.acos(costheta) * (base.cross(other) <=> 0)
  # rescue
    # $gtk.args.state.costheta = costheta
    # raise "#{costheta} is whack!"
  # end
  # 190 unsafe (safeguarded now through clamping the Float division error)
  # 380 new metric
  # End bracket 2.
  
  proj_magnitude = other.abs * costheta
  proj_bound = (0..1).include?(proj_magnitude / base.abs)
  # temp = (proj_magnitude / base.abs)
  # proj_bound = temp >= 0 && temp <= 1
   # 187 for both approaches.
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
