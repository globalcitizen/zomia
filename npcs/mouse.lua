-- mouse
npc_types['mouse'] = {
			name="Mouse",
			color={180,140,190},
			hostile=true,
			move='attack',
			tail=true,
			vocal=true,
                        armour={
                                        {
                                                type="flesh",
                                                natural=true,
                                                value=1
                                        }
                        },
                        weapons={
                                        {
                                                name='teeth',
                                                natural=true,
                                                attacks={
                                                        {
                                                                verbs={'bites','gnaws at','gnaws on','scrapes','nips'},
                                                                damage={dice_qty=1,dice_sides=1,plus=0},
                                                                critical_chance_multiplier=0.2
                                                        }
                                                }
                                        }
                        },
			sounds={
				attack=love.audio.newSource({
								"npcs/mouse/mouse-1.mp3",
								"npcs/mouse/mouse-2.wav",
								"npcs/mouse/mouse-3.wav",
								"npcs/mouse/mouse-4.wav"
							   })
			}
		   }
