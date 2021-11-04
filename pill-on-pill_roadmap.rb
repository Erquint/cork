# Milestone 1: collision fact.

# Discord version.
def pp_int va1, va2, vb1, vb2
  segments = [va1, va2, vb1, vb2]
  return 0 if segments.seg_intersect?
  pvecs = segments.valid_projection_vectors
  if pvecs.size.zero?
    return segments.end_to_end_shortest_distance
  else
    return pvecs.shortest_magnitude
end

# Adapted version.

# Done as a function!

# Then check distance against sum of pill radii.

# Done in `tick` yet.

# Milestone 2: collision point.

# Milestone X:
#  clip offset point,
#  linear interpolation of parametric equation,
#  resolution.
