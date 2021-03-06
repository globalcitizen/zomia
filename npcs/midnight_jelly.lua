npc_types['midnight_jelly'] = {
			name="Midnight Jelly",
			color={140,240,30},
			hostile=true,
			move='attack',
			vocal=true,
			max_health=16,
                        armour={
                                        {
                                                type="flesh",
                                                natural=true,
                                                value=1
                                        }
                        },
                        weapons={
                                        {
                                                name='nebulous mouth-like opening',
                                                natural=true,
                                                likelihood=3,
                                                attacks={
                                                        {
                                                                verbs={'bites at','gnaws on','seizes','chomps on','absorbs part of','sinks in to','melds with','reverse-regurgitates'},
                                                                damage={dice_qty=1,dice_sides=6,plus=2},
                                                                critical_chance_multiplier=1.5
                                                        }
                                                }
                                        },
                                        {
                                                name='jelly',
                                                natural=true,
                                                likelihood=7,
                                                attacks={
                                                        {
                                                                verbs={'subsumes','absorbs','digests','dissolves','obtains','draws from','invests in'},
                                                                damage={dice_qty=1,dice_sides=6,plus=0},
                                                                critical_chance_multiplier=0.7
                                                        }
                                                }
                                        }
                        },
			sounds={
				attack=love.audio.newSource({
"sounds/impact/slime-eat-1.mp3",
"sounds/impact/slime-eat-10.mp3",
"sounds/impact/slime-eat-11.mp3",
"sounds/impact/slime-eat-12.mp3",
"sounds/impact/slime-eat-13.mp3",
"sounds/impact/slime-eat-14.mp3",
"sounds/impact/slime-eat-15.mp3",
"sounds/impact/slime-eat-16.mp3",
"sounds/impact/slime-eat-17.mp3",
"sounds/impact/slime-eat-18.mp3",
"sounds/impact/slime-eat-19.mp3",
"sounds/impact/slime-eat-2.mp3",
"sounds/impact/slime-eat-3.mp3",
"sounds/impact/slime-eat-4.mp3",
"sounds/impact/slime-eat-5.mp3",
"sounds/impact/slime-eat-6.mp3",
"sounds/impact/slime-eat-7.mp3",
"sounds/impact/slime-eat-8.mp3",
"sounds/impact/slime-eat-9.mp3"
							     }),
				target=love.audio.newSource({
"sounds/impact/slime-eat-1.mp3",
"sounds/impact/slime-eat-10.mp3",
"sounds/impact/slime-eat-11.mp3",
"sounds/impact/slime-eat-12.mp3",
"sounds/impact/slime-eat-13.mp3",
"sounds/impact/slime-eat-14.mp3",
"sounds/impact/slime-eat-15.mp3",
"sounds/impact/slime-eat-16.mp3",
"sounds/impact/slime-eat-17.mp3",
"sounds/impact/slime-eat-18.mp3",
"sounds/impact/slime-eat-19.mp3",
"sounds/impact/slime-eat-2.mp3",
"sounds/impact/slime-eat-3.mp3",
"sounds/impact/slime-eat-4.mp3",
"sounds/impact/slime-eat-5.mp3",
"sounds/impact/slime-eat-6.mp3",
"sounds/impact/slime-eat-7.mp3",
"sounds/impact/slime-eat-8.mp3",
"sounds/impact/slime-eat-9.mp3",
"sounds/impact/slime-feast-1.mp3",
"sounds/impact/slime-feast-2.mp3",
"sounds/impact/slime-feast-3.mp3"
							     }),
				move=love.audio.newSource({
"sounds/impact/slime-1.mp3",
"sounds/impact/slime-10.mp3",
"sounds/impact/slime-11.mp3",
"sounds/impact/slime-12.mp3",
"sounds/impact/slime-13.mp3",
"sounds/impact/slime-14.mp3",
"sounds/impact/slime-15.mp3",
"sounds/impact/slime-16.mp3",
"sounds/impact/slime-17.mp3",
"sounds/impact/slime-18.mp3",
"sounds/impact/slime-2.mp3",
"sounds/impact/slime-3.mp3",
"sounds/impact/slime-4.mp3",
"sounds/impact/slime-5.mp3",
"sounds/impact/slime-6.mp3",
"sounds/impact/slime-7.mp3",
"sounds/impact/slime-8.mp3",
"sounds/impact/slime-9.mp3"
							     }),
				distance=love.audio.newSource({
"sounds/impact/slime-1.mp3",
"sounds/impact/slime-10.mp3",
"sounds/impact/slime-11.mp3",
"sounds/impact/slime-12.mp3",
"sounds/impact/slime-13.mp3",
"sounds/impact/slime-14.mp3",
"sounds/impact/slime-15.mp3",
"sounds/impact/slime-16.mp3",
"sounds/impact/slime-17.mp3",
"sounds/impact/slime-18.mp3",
"sounds/impact/slime-2.mp3",
"sounds/impact/slime-3.mp3",
"sounds/impact/slime-4.mp3",
"sounds/impact/slime-5.mp3",
"sounds/impact/slime-6.mp3",
"sounds/impact/slime-7.mp3",
"sounds/impact/slime-8.mp3",
"sounds/impact/slime-9.mp3"
							     }),
				victory=love.audio.newSource({
"sounds/impact/slime-feast-1.mp3",
"sounds/impact/slime-feast-2.mp3",
"sounds/impact/slime-feast-3.mp3"
				})
			}
		}
