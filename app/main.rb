# Encoding: utf-8
# DRGTK 2.26

if $gtk.platform == 'Linux'
  $gtk.reset()
else
  $gtk.disable_nil_coersion!
end

require '/lib/giatros/frametimer.rb'
require '/lib/giatros/ducks.rb'
require '/lib/giatros/nil_panic.rb'
require '/app/hood.rb'

def tick args
  if args.state.tick_count == 0
  else
  end
end
