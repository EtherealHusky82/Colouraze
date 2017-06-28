local levels = {}
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH
local startPoint, wall_width, wall_height = 2*math.floor(0.8*screenW/9), math.floor(0.8*screenW/4), math.floor(0.8*screenH/40)

levels.difficulty = 'easy'
levels.no_ofshapes = { circles = 5, wall_arrangement_types = 6, portals = 2, exit_sensor = 1 }
	
levels.shapeDetails = { circle_radius = 0.15*wall_width,  scale = 1, 

						circle_coordinates = 
						{ 
							{ x=startPoint + 2*wall_width, y=2*wall_width },
							{ x=startPoint + 3*wall_width, y=2*wall_width },
							{ x=startPoint + 2*wall_width, y=5*wall_width },
							{ x=startPoint + 2*wall_width, y=7*wall_width },				
							{ x=startPoint + 2*wall_width, y=7*wall_width }
						},
						
						circle_colours = { {0.933,0.510,0}, {0.933,0.510,0.933}, {0.510,0.933,0.510}, {0.510,0.933,0.933}, {0.510,0.510,0.933} },

						no_of_groups_for_each_arrangement = {7,1,2,1,1,1}, no_of_walls_in_arrangement = {4,3,3,1,6,2},

						wall_width = wall_width, wall_height = wall_height,

						wall_translations = { { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0}, 
												{0,0.5*wall_width-0.5*wall_height}, {-0.5*wall_width+0.5*wall_height,0} },
											  
											  { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0}, 
												{-0.5*wall_width+0.5*wall_height,0} },										  	 
											  
											  { {0.5*wall_width-0.5*wall_height,0}, {0,0.5*wall_width-0.5*wall_height}, 
												{-0.5*wall_width+0.5*wall_height,0} },													 
											  								 										     							  	 
											  {	{0.5*wall_width-0.5*wall_height,0} }, 
											  					 
											  { {0,-0.5*wall_width+0.5*wall_height}, {0,-0.5*wall_width+wall_height}, {0,-0.5*wall_width+1.5*wall_height}, 
											    {0.5*wall_width-0.5*wall_height,0}, {0,0.5*wall_width-0.5*wall_height}, {-0.5*wall_width+0.5*wall_height,0} },

											  { {0.5*wall_width-0.5*wall_height,0}, {-0.5*wall_width+0.5*wall_height,0} }
											}, 

						wall_rotations = { {0,90,180,270}, {0,90,270}, {90,180,270}, {90}, {0,0,0,90,180,270}, {90,270} }, 

						wall_group_coordinates = { 	{ x=startPoint + 2*wall_width, y=2*wall_width }, 
											 	   	{ x=startPoint + 3*wall_width, y=2*wall_width }, 
											 	   	{ x=startPoint, y=4*wall_width },											 	   	
											 	   	{ x=startPoint + 2*wall_width, y=4*wall_width }, 
											 	   	{ x=startPoint, y=5*wall_width }, 
											 	   	{ x=startPoint + 2*wall_width, y=5*wall_width },				 					 		  
													{ x=startPoint + 2*wall_width, y=6*wall_width },
													{ x=startPoint + 3*wall_width, y=3*wall_width },
													{ x=startPoint + 3*wall_width, y=5*wall_width },
													{ x=startPoint, y=3*wall_width },
													{ x=startPoint + 3*wall_width, y=4*wall_width },
													{ x=startPoint + 2*wall_width, y=7*wall_width },
													{ x=startPoint, y=2*wall_width }													
												},

						wall_colours = { { {0.467,0,0.812}, {0.510,0.933,0.933}, {0.467,0,0.812}, {0.467,0,0.812} }, 
										 { {0.467,0,0.812}, {0.467,0,0.812}, {0.933,0.510,0}, {0.933,0.510,0} },																	 
										 { {0.510,0.933,0.510}, {0.467,0,0.812}, {0.510,0.510,0.933}, {0.467,0,0.812} },																	 
										 { {0.467,0,0.812}, {0.467,0,0.812}, {0.510,0.510,0.933}, {0.467,0,0.812} },
										 { {0.933,0.510,0}, {0.467,0,0.812}, {0.467,0,0.812}, {0.467,0,0.812} },
										 { {0.510,0.933,0.510}, {0.933,0.510,0.933}, {0.510,0.510,0.933}, {0.467,0,0.812} },
										 { {0.933,0.510,0}, {0.467,0,0.812}, {0.933,0.510,0}, {0.467,0,0.812} },
										 { {0.933,0.510,0.933}, {0.467,0,0.812}, {0.467,0,0.812} },
										 { {0.467,0,0.812}, {0.467,0,0.812}, {0.933,0.510,0} },
										 { {0.467,0,0.812}, {0.510,0.933,0.933}, {0.467,0,0.812} },
										 { {0.467,0,0.812} },
										 { {0.933,0.510,0.933}, {0.510,0.933,0.510}, {0.510,0.933,0.933}, {0.467,0,0.812}, {0.467,0,0.812}, {0.467,0,0.812} },										 
										 { {0.467,0,0.812}, {0.467,0,0.812} }
									   },						
						
						portal_coordinates = { { x=startPoint + 2*wall_width, y=4*wall_width }, 
											   { x=startPoint, y=5*wall_width } 
											 },

						exit_coordinates = { { x=startPoint, y=wall_width } } 
					}

levels.wallGroupsTbl = {}
levels.portalTags = {'A', 'A'} --movement is only possible between portals of the same tags

levels.laserTrapDetails = { no_of_traps = 1, no_of_lasers_per_trap = 2, intervaltimer = 2000, 
							lasers_location = { {x=startPoint + 2.75*wall_width, y=3.5*wall_width}, {x=startPoint + 3.5*wall_width,y=4.5*wall_width} },
							lasers_direction = { 90, -90 }, distanceBetweenWalls = wall_width
						  } --wallid refers to the wallgroupid where the laser traps are mounted at

levels.spikesDetails = { no_of_spikes = 3, spikes_location = { {x=startPoint-(0.4*wall_width), y=1.7*wall_width}, {x=startPoint+0.4*wall_width, y=2*wall_width}, 
						 {x=startPoint-(0.4*wall_width), y=2.5*wall_width} }, spikes_direction = {0, 180, 0} 
					   }

levels.movingSpikedWallDetails = { no_of_spikes = 2, spikes_location = { {x=startPoint-0.5*wall_width, y=4*wall_width}, {x=startPoint+0.5*wall_width, y=4*wall_width} }, 
						 		   spikes_direction = {0, 180}, timer = 3000, triggerZone = {x=startPoint-2*wall_height, y=4.7*wall_width}, distancetoMove = wall_height/4, 
						 		   wallGrpId = 3, shortenwallId = {1,3}, movingwallId ={2,4}, iterations = 4
					   			 }

levels.isthereGuideText = true
levels.guideText = { {text="watch out for walls that move! It's possible to avoid triggering it!"} }


return levels 

