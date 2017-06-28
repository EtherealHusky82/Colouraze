local levels = {}
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local myApp = require( "libs.myapp" ) 
-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH
local startPointX, wall_width, wall_height = 2*math.floor(0.8*screenW/9), myApp.wall_width, myApp.wall_height
local spike_width = wall_width/5

levels.difficulty = 'easy'
levels.no_ofshapes = { circles = 4, wall_arrangement_types = 7, portals = 2, exit_sensor = 1 }
	
levels.shapeDetails = { circle_radius = 0.15*wall_width, scale = 1, 

						circle_coordinates = 
						{ 							
							{ x=startPointX + 3*wall_width - wall_height, y=1.5*wall_width },									
							{ x=startPointX + 3*wall_width + wall_height, y=1.5*wall_width },
							{ x=startPointX - wall_height, y=2.8*wall_width },
							{ x=startPointX + wall_height, y=2.8*wall_width }	
						},
						
						circle_colours = { {0.510,0.510,0.933}, {0.933,0.510,0.933}, {0.510,0.933,0.933}, {0.510,0.933,0.510} },					 

						no_of_groups_for_each_arrangement = {6,1,2,2,3,1,1}, no_of_walls_in_arrangement = {4,3,2,3,2,6,1},

						wall_width = wall_width, wall_height = wall_height,

						wall_translations = { { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0}, 
												{0,0.5*wall_width-0.5*wall_height}, {-0.5*wall_width+0.5*wall_height,0} },
											  
											  { {0,-0.5*wall_width+0.5*wall_height}, {0,0.5*wall_width-0.5*wall_height}, 
												{-0.5*wall_width+0.5*wall_height,0} },

											  { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0} },																						  	 
											  
											  { {0.5*wall_width-0.5*wall_height,0}, {0,0.5*wall_width-0.5*wall_height}, 
												{-0.5*wall_width+0.5*wall_height,0} },													 
											  								 										     							  	 
											  {	{0.5*wall_width-0.5*wall_height,0}, {-0.5*wall_width+0.5*wall_height,0} }, 
											  					 
											  { {0,-0.5*wall_width+0.5*wall_height}, {0,-0.5*wall_width+1.6*wall_height}, {0,-0.5*wall_width+2.6*wall_height}, 
											    {0.5*wall_width-0.5*wall_height,0}, {0,0.5*wall_width-0.5*wall_height}, {-0.5*wall_width+0.5*wall_height,0} },

											  { {-0.5*wall_width+0.5*wall_height,0} }										
				
											}, 

						wall_rotations = { {0,90,180,270}, {0,180,270}, {0,90}, {90,180,270}, {90,270}, {0,0,0,90,180,270}, {225} }, 

						wall_group_coordinates = { 	{ x=startPointX, y=1.5*wall_width }, 
											 	   	{ x=startPointX + 2*wall_width, y=1.5*wall_width }, 											 	   	
											 	   	{ x=startPointX + 3*wall_width, y=1.5*wall_width }, 
											 	   	{ x=startPointX + 2*wall_width, y=5.5*wall_width },
											 	   	{ x=startPointX + wall_width, y=6.5*wall_width }, 
											 	   	{ x=startPointX + 2*wall_width, y=6.5*wall_width },				 					 		  
													{ x=startPointX + 2*wall_width, y=2.5*wall_width },
													{ x=startPointX + 3*wall_width, y=2.5*wall_width },
													{ x=startPointX, y=4.5*wall_width }, 																								
													{ x=startPointX + 3*wall_width, y=5.5*wall_width },	
													{ x=startPointX, y=6.5*wall_width },												
													{ x=startPointX + 3*wall_width, y=3.5*wall_width },
													{ x=startPointX + 3*wall_width, y=4.5*wall_width },
													{ x=startPointX, y=5.5*wall_width },
													{ x=startPointX, y=2.5*wall_width },
													{ x=startPointX-0.75*wall_width, y=4.6*wall_width }
																							
												},

						wall_colours = { { {0.467,0,0.812}, {0.467,0,0.812}, {0.510,0.933,0.933}, {0.467,0,0.812} }, 
										 { {0.467,0,0.812}, {0.510,0.510,0.933}, {0.467,0,0.812}, {0.467,0,0.812} },																	 										 																	 
										 { {0.467,0,0.812}, {0.467,0,0.812}, {0.933,0.510,0}, {0.933,0.510,0.933} },
										 { {0.467,0,0.812}, {0.933,0.510,0.933}, {0.933,0.510,0}, {0.467,0,0.812} },
										 { {0.467,0,0.812}, {0.510,0.933,0.510}, {0.467,0,0.812}, {0.933,0.510,0} },
										 { {0.510,0.510,0.933}, {0.467,0,0.812}, {0.467,0,0.812}, {0.933,0.510,0} },								 
										 { {0.467,0,0.812}, {0.467,0,0.812}, {0.467,0,0.812} },	
										 { {0.933,0.510,0.933}, {0.467,0,0.812} },
										 { {0.467,0,0.812}, {0.467,0,0.812} },											
										 { {0.467,0,0.812}, {0.510,0.933,0.510}, {0.933,0.510,0} },
										 { {0.510,0.933,0.510}, {0.467,0,0.812}, {0.467,0,0.812} },	
										 { {0.467,0,0.812}, {0.467,0,0.812} }, 																												
										 { {0.467,0,0.812}, {0.467,0,0.812} },
										 { {0.467,0,0.812}, {0.467,0,0.812} },	
										 { {0.510,0.510,0.933}, {0.510,0.933,0.510}, {0.467,0,0.812}, {0.467,0,0.812}, {0.467,0,0.812}, {0.467,0,0.812} },
										 { {0.467,0,0.812} }																		 
										 
									   },						
						
						portal_coordinates = { { x=startPointX, y=1.5*wall_width }, 
											   { x=startPointX + 2*wall_width, y=1.5*wall_width } 
											 },

						exit_coordinates = { { x=startPointX-0.45*wall_width, y=4.4*wall_width, rotation=45 } },

						no_of_pairs_of_walls_toOpen = 8, no_of_opened_pairs_of_walls = 0  
					}

levels.wallGroupsTbl = {}
levels.portalTags = {'A', 'A'} --movement is only possible between portals of the same tags

levels.spikesDetails = { no_of_spikes = 6, spikes_location = { {x=startPointX, y=4*wall_width+2*wall_height}, {x=startPointX+0.5*wall_width-2*wall_height, y=4.8*wall_width}, 
						 {x=startPointX-0.5*wall_width+2*wall_height, y=5.3*wall_width}, {x=startPointX+0.5*wall_width-2*wall_height, y=5.7*wall_width},
						  {x=startPointX-0.5*wall_width+2*wall_height, y=6.2*wall_width}, {x=startPointX, y=7*wall_width-2*wall_height} },
						   
						 spikes_direction = { 90,180,0,180,0,270 } 
					   }

levels.asteroidTrapDetails = { no_of_traps = 1, no_of_asteroids_per_trap = 4, coordinates = { {x=startPointX+2*wall_width, y=2.5*wall_width} }, 
								filename="graphics/sprites/moving_asteroid_sprite.png",

							   	moving_asteroid_sheetoptions =
								{
								    width = 240,
								    height = 240,
								    numFrames = 32
								},

								moving_asteroid_sequenceData =
								{
								    name="normalMove", --normal speed
								    start=1,
								    count=32,
								    time=4000,
								    loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
								    loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
								},
													
								{
								    name="fastMove", --normal speed
								    start=1,
								    count=32,
								    time=2500,
								    loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
								    loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
								},

							   triggerZone = { {x=startPointX+3*wall_width, y=2.5*wall_width, width=wall_width, height=wall_width/2} },  

							   velocities = { {x_velocitymin = 0, x_velocitymax = 0, y_velocitymin = 100, y_velocitymax = 150} },

							   timerForDirectionChange = 650
							}

levels.isthereGuideText = true
levels.guideText = { {text="Be careful of the asteroid that might follow you! Avoid colliding with it!"} }


return levels 

