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
def pp_dist base0, base1, other0, other1
  # segments = [va1, va2, vb1, vb2]
  return 0 if lineseg_int base0, base1, other0, other1
  pvecs = [
    ortho_proj base0, base1, other0,
    ortho_proj base0, base1, other1,
    ortho_proj other0, other1, base0,
    ortho_proj other0, other1, base1
  ].filter{|pvec| pvec[:proj_bound]}
  if pvecs.size.zero?
    # return segments.end_to_end_shortest_distance
  else
    # return pvecs.shortest_magnitude
end
