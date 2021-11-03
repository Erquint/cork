# UTF-8
# DRGTK Pro 3.0 RC

require '/lib/giatros/ducks.rb'
require '/lib/xenovmath/vectormath.rb'
require '/lib/giatros/frametimer.rb'
require '/app/hood.rb'

def tick args
  if args.state.tick_count == 0
    $points = {
      base0: Vec2.new(0.0, 0.0),
      base1: Vec2.new(0.0, 0.0),
      other0: Vec2.new(0.0, 0.0),
      other1: Vec2.new(0.0, 0.0)
    }
    $mouse = $gtk.args.inputs.mouse
    $p_size = 5
  elsif args.state.tick_count > 0
    mouse_pos = [$mouse.x, $mouse.y]
    
    if !!args.inputs.keyboard.key_held.shift
      seg_selector = [$points[:base0], $points[:base1]]
    else
      seg_selector = [$points[:other0], $points[:other1]]
    end
    
    if $mouse.button_left
      seg_selector[0].set!(*mouse_pos)
    elsif $mouse.button_right
      seg_selector[1].set!(*mouse_pos)
    end
    
    li = lineseg_int $points[:base0], $points[:base1], $points[:other0], $points[:other1]
    
    args.outputs.primitives << [
      { # Background.
        primitive_marker: :solid,
        x: $args.grid.x, y: $args.grid.y,
        w: $args.grid.w, h: $args.grid.h,
        r: 42, g: 42, b: 42
      }, { # Base segment.
        primitive_marker: :line,
        x: $points[:base0].x, y: $points[:base0].y,
        x2: $points[:base1].x, y2: $points[:base1].y,
        r: 255, g: 255, b: 255
      }, { # Other segment.
        primitive_marker: :line,
        x: $points[:other0].x, y: $points[:other0].y,
        x2: $points[:other1].x, y2: $points[:other1].y,
        r: 255, g: 255, b: 255
      }, { # Blue point.
        primitive_marker: :solid,
        x: $points[:base0].x - $p_size / 2, y: $points[:base0].y - $p_size / 2,
        w: $p_size, h: $p_size, b: 255
      }, { # Red point.
        primitive_marker: :solid,
        x: $points[:base1].x - $p_size / 2, y: $points[:base1].y - $p_size / 2,
        w: $p_size, h: $p_size, r: 255
      }, { # Green point.
        primitive_marker: :solid,
        x: $points[:other0].x - $p_size / 2, y: $points[:other0].y - $p_size / 2,
        w: $p_size, h: $p_size, g: 255
      }, { # Yellow point.
        primitive_marker: :solid,
        x: $points[:other1].x - $p_size / 2, y: $points[:other1].y - $p_size / 2,
        w: $p_size, h: $p_size, r: 255, g: 255
      }, { # Purple point.
        primitive_marker: :solid,
        x: li[:intersection].x - $p_size / 2, y: li[:intersection].y - $p_size / 2,
        w: $p_size, h: $p_size, r: 255, b: 255, a: li[:intersects?] ? 255 : 0
      }, { # Debug.
        primitive_marker: :label,
        x: args.grid.x, y: args.grid.h,
        text: "#{li.inspect}",
        r: 213, g: 213, b: 213
      }
    ]
  end
end
