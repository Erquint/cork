# UTF-8
# DRGTK Pro 3.0 RC

require '/lib/giatros/ducks.rb'
require '/lib/xenovmath/vectormath.rb'
require '/lib/giatros/frametimer.rb'
require '/app/hood.rb'

def tick args
  if args.state.tick_count == 0
    new_vector = Vec2.new(0.0, 0.0)
    $pills = {
      base: {start: new_vector.dup, end: new_vector.dup, radius: 20},
      other: {start: new_vector.dup, end: new_vector.dup, radius: 20}
    }
    $mouse = $gtk.args.inputs.mouse
    $marker_size = 5
  elsif args.state.tick_count > 0
    @base0 = $pills[:base][:start]
    @base1 = $pills[:base][:end]
    @base_radius = $pills[:base][:radius]
    @other0 = $pills[:other][:start]
    @other1 = $pills[:other][:end]
    @other_radius = $pills[:other][:radius]
    
    if !!args.inputs.keyboard.key_held.shift
      pill_selector = $pills[:base]
    else
      pill_selector = $pills[:other]
    end
    
    mouse_pos = [$mouse.x, $mouse.y]
    if $mouse.button_left
      pill_selector[:start].set!(*mouse_pos)
    elsif $mouse.button_right
      pill_selector[:end].set!(*mouse_pos)
    end
    
    if args.inputs.mouse.wheel
      scroll = -args.inputs.mouse.wheel.y # Temp. DRGTK bug workaround.
      pill_selector[:radius] += 5 * scroll
      pill_selector[:radius] = 0 if pill_selector[:radius].negative?
    end
    
    # Rudiments.
    # op = ortho_proj @base0, @base1, @other0
    lsi = lineseg_int @base0, @base1, @other0, @other1
    # lsed = lineseg_end_distance @base0, @base1, @other0, @other1
    
    # The real deal.
    lsd = lineseg_dist @base0, @base1, @other0, @other1
    pills_intersect = lsd <= @base_radius + @other_radius
    
    pwalls_prims = $pills.values.map do |pill|
      wall_offset = (pill[:start] - pill[:end]).perp.unit.scale(pill[:radius])
      next [
        [pill[:end] + wall_offset,
          pill[:start] + wall_offset],
        [pill[:end] - wall_offset,
          pill[:start] - wall_offset]
      ].map do |wall|
        next [
          {
            primitive_marker: :line,
            x: wall[0].x, y: wall[0].y,
            x2: wall[1].x, y2: wall[1].y,
            r: 255, g: 255, b: 255
          }
        ]
      end
    end
    
    args.outputs.primitives << [
      { # Background.
        primitive_marker: :solid,
        x: $args.grid.x, y: $args.grid.y,
        w: $args.grid.w, h: $args.grid.h,
        r: 42, g: 42, b: 42
      }.tap{|prim| prim.merge!({r: 80, g: 42, b: 42}) if pills_intersect},
      pwalls_prims,
      { # Base segment.
        primitive_marker: :line,
        x: @base0.x, y: @base0.y,
        x2: @base1.x, y2: @base1.y,
        r: 255, g: 255, b: 255
      }, { # Other segment.
        primitive_marker: :line,
        x: @other0.x, y: @other0.y,
        x2: @other1.x, y2: @other1.y,
        r: 255, g: 255, b: 255
      }, { # Purple point.
        primitive_marker: :solid,
        x: lsi[:intersection].x - $marker_size / 2, y: lsi[:intersection].y - $marker_size / 2,
        w: $marker_size, h: $marker_size, r: 255, b: 255, a: lsi[:intersects?] ? 255 : 0
      }, { # Blue point.
        primitive_marker: :solid,
        x: @base0.x - $marker_size / 2, y: @base0.y - $marker_size / 2,
        w: $marker_size, h: $marker_size, b: 255
      }, { # Red point.
        primitive_marker: :solid,
        x: @base1.x - $marker_size / 2, y: @base1.y - $marker_size / 2,
        w: $marker_size, h: $marker_size, r: 255
      }, { # Green point.
        primitive_marker: :solid,
        x: @other0.x - $marker_size / 2, y: @other0.y - $marker_size / 2,
        w: $marker_size, h: $marker_size, g: 255
      }, { # Yellow point.
        primitive_marker: :solid,
        x: @other1.x - $marker_size / 2, y: @other1.y - $marker_size / 2,
        w: $marker_size, h: $marker_size, r: 255, g: 255
      }, { # Circle base0.
        primitive_marker: :sprite,
        x: @base0.x - @base_radius, y: @base0.y - @base_radius,
        w: @base_radius * 2, h: @base_radius * 2,
        path: 'assets/circle.png',
      }, { # Circle base1.
        primitive_marker: :sprite,
        x: @base1.x - @base_radius, y: @base1.y - @base_radius,
        w: @base_radius * 2, h: @base_radius * 2,
        path: 'assets/circle.png',
      }, { # Circle other0.
        primitive_marker: :sprite,
        x: @other0.x - @other_radius, y: @other0.y - @other_radius,
        w: @other_radius * 2, h: @other_radius * 2,
        path: 'assets/circle.png',
      }, { # Circle other1.
        primitive_marker: :sprite,
        x: @other1.x - @other_radius, y: @other1.y - @other_radius,
        w: @other_radius * 2, h: @other_radius * 2,
        path: 'assets/circle.png',
      },
      Giatros::Frametimer.frametime_label,
      Giatros::Frametimer.fps_label,
      Giatros::Frametimer.graph
    ]
  end
end
