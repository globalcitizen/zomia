-- mouse
npc_types['mouse'] = {
			name="Mouse",
			color={180,140,190},
			hostile=true,
			move='attack',
			tail=true,
			vocal=true,
			sounds={
				attack=love.audio.newSource({
								"npcs/mouse/mouse-1.mp3",
								"npcs/mouse/mouse-2.wav",
								"npcs/mouse/mouse-3.wav",
								"npcs/mouse/mouse-4.wav"
							   })
			}
		   }
