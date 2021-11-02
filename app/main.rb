# UTF-8
# DRGTK Pro 3.0 RC

require '/lib/giatros/ducks.rb'
require '/lib/xenovmath/vectormath.rb'
require '/lib/giatros/frametimer.rb'
require '/app/hood.rb'

def tick args
  if args.state.tick_count == 0
    $points = {
      lseg: Vec2.new(0.0, 0.0),
      rseg: Vec2.new(0.0, 0.0),
      circle: Vec2.new(0.0, 0.0),
      proj: Vec2.new(0.0, 0.0)
    }
    $mouse = $gtk.args.inputs.mouse
    $p_size = 5
    $c_radius = 50
  elsif args.state.tick_count > 0
    mouse_pos = [$mouse.x, $mouse.y]
    
    if $mouse.button_left
      $points[:lseg].set!(*mouse_pos)
    elsif $mouse.button_right
      $points[:rseg].set!(*mouse_pos)
    elsif $mouse.button_middle
      $points[:circle].set!(*mouse_pos)
    end
    
    if args.inputs.mouse.wheel
      $c_radius += 5 * args.inputs.mouse.wheel.y
      $c_radius = 0 if $c_radius.negative?
    end
    
    op = ortho_proj $points[:lseg], $points[:rseg], $points[:circle]
    
    $points[:proj] = op[:global][:projected]
    
    if op[:proj_bound]
      proj_collision = (op[:local][:projected] - op[:local][:other]).abs < $c_radius
    else
      proj_collision = false
    end
    
    blue_collision = op[:local][:other].abs < $c_radius
    red_collision = (op[:local][:base] - op[:local][:other]).abs < $c_radius
    line_collision = proj_collision || red_collision || blue_collision
    
    rfar = op[:local][:base].scale(1e3) + $points[:lseg]
    lfar = op[:local][:base].invert.scale(1e3) + $points[:lseg]
    
    args.outputs.primitives << [
      { # Background.
        primitive_marker: :solid,
        x: $args.grid.x, y: $args.grid.y,
        w: $args.grid.w, h: $args.grid.h,
        r: 42, g: 42, b: 42
      }, { # Base line.
        primitive_marker: :line,
        x: lfar.x, y: lfar.y,
        x2: rfar.x, y2: rfar.y,
        r: 108, g: 108, b: 108
      }, { # Projection segment.
        primitive_marker: :line,
        x: $points[:circle].x, y: $points[:circle].y,
        x2: $points[:proj].x, y2: $points[:proj].y,
        r: 108, g: 108, b: 108
      }, { # Base segment.
        primitive_marker: :line,
        x: $points[:lseg].x, y: $points[:lseg].y,
        x2: $points[:rseg].x, y2: $points[:rseg].y,
        r: 255, g: 255, b: 255
      }, { # Other segment.
        primitive_marker: :line,
        x: $points[:lseg].x, y: $points[:lseg].y,
        x2: $points[:circle].x, y2: $points[:circle].y,
        r: 108, g: 108, b: 108
      }, { # Yellow point.
        primitive_marker: :solid,
        x: $points[:proj].x - $p_size / 2, y: $points[:proj].y - $p_size / 2,
        w: $p_size, h: $p_size, r: 255, g: 255, a: op[:proj_bound] ? 255 : 0
      }, { # Blue point.
        primitive_marker: :solid,
        x: $points[:lseg].x - $p_size / 2, y: $points[:lseg].y - $p_size / 2,
        w: $p_size, h: $p_size, b: 255
      }, { # Red point.
        primitive_marker: :solid,
        x: $points[:rseg].x - $p_size / 2, y: $points[:rseg].y - $p_size / 2,
        w: $p_size, h: $p_size, r: 255
      }, { # Green point.
        primitive_marker: :solid,
        x: $points[:circle].x - $p_size / 2, y: $points[:circle].y - $p_size / 2,
        w: $p_size, h: $p_size, g: 255
      }, { # Base vector point.
        primitive_marker: :solid,
        x: op[:local][:base].x - $p_size / 2, y: op[:local][:base].y - $p_size / 2,
        w: $p_size, h: $p_size,
        r: 255, g: 255, b: 255
      }, { # Base vector segment.
        primitive_marker: :line,
        x2: op[:local][:base].x, y2: op[:local][:base].y,
        r: 255, g: 255, b: 255
      }, { # Other vector point.
        primitive_marker: :solid,
        x: op[:local][:other].x - $p_size / 2, y: op[:local][:other].y - $p_size / 2,
        w: $p_size, h: $p_size,
        r: 255, g: 255, b: 255
      }, { # Other vector segment.
        primitive_marker: :line,
        x2: op[:local][:other].x, y2: op[:local][:other].y,
        r: 255, g: 255, b: 255
      }, { # Projected vector point.
        primitive_marker: :solid,
        x: op[:local][:projected].x - $p_size / 2, y: op[:local][:projected].y - $p_size / 2,
        w: $p_size, h: $p_size,
        r: 255, g: 255, b: 255
      }, { # Projected vector segment.
        primitive_marker: :line,
        x2: op[:local][:projected].x, y2: op[:local][:projected].y,
        r: 255, g: 255, b: 255
      }, { # Angle "arc".
        primitive_marker: :line,
        x: (op[:local][:base].unit.scale 15).x + $points[:lseg].x,
        y: (op[:local][:base].unit.scale 15).y + $points[:lseg].y,
        x2: (op[:local][:other].unit.scale 15).x + $points[:lseg].x,
        y2: (op[:local][:other].unit.scale 15).y + $points[:lseg].y,
        r: 213, g: 213
      }, { # Angle degrees readout.
        primitive_marker: :label,
        x: $points[:lseg].x + $p_size / 2, y: $points[:lseg].y + $p_size / 2,
        text: "%.2f°" % (op[:theta] / DEG2RAD),
        r: 213, g: 213, b: 213
      }, { # Circle sprite.
        primitive_marker: :sprite,
        x: $points[:circle].x - $c_radius, y: $points[:circle].y - $c_radius,
        w: $c_radius * 2, h: $c_radius * 2,
        path: 'assets/circle.png',
      }.merge!(line_collision ? {r: 255, g: 0, b: 0} : {r: 255, g: 255, b: 255}),
      Giatros::Frametimer.frametime_label,
      Giatros::Frametimer.fps_label,
      Giatros::Frametimer.graph
    ]
  end
end
