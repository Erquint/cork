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
  projs = [
    ortho_proj base0, base1, other0,
    ortho_proj base0, base1, other1,
    ortho_proj other0, other1, base0,
    ortho_proj other0, other1, base1
  ].filter{|proj| proj[:proj_bound]}.map{|proj| proj[:proj_magnitude]}
  if projs.empty?
    # return segments.end_to_end_shortest_distance
  else
    return projs.min
    # return projs.min{|prev_proj, next_proj| prev_vec[:proj_magnitude] <=> next_vec[:proj_magnitude]}.[:proj_magnitude]
end
