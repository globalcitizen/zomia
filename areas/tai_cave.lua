area_types['tai_cave'] = {
				 name  = 'Cave',
				 setup = function(instance) 
					-- Possibly we just copy the name from the already named area above us in the world
					-- Generate an appropriate map
					instance.map=true
					-- Populate with NPCs
				 end
		       	    }
