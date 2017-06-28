local levels = {}
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local myApp = require( "libs.myapp" ) 
-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH
local startPointX, wall_width, wall_height = 2*math.floor(0.8*screenW/8), myApp.wall_width, myApp.wall_height
local spike_width = wall_width/5

levels.difficulty = 'easy'
levels.no_ofshapes = { circles = 4, wall_arrangement_types = 9, portals = 2, exit_sensor = 1 }
	
levels.shapeDetails = { circle_radius = 0.15*wall_width, scale = 1, 

						circle_coordinates = 
						{ 							
							{ x=startPointX + 3*wall_width, y=2*wall_width },
							{ x=startPointX - wall_height, y=3.2*wall_width },
							{ x=startPointX + wall_height, y=3.2*wall_width },				
							{ x=startPointX + 2*wall_width, y=2*wall_width }
						},
						
						circle_colours = { {0.933,0.510,0.933}, {0.510,0.933,0.933}, {0.510,0.933,0.510}, {0.510,0.510,0.933} },

						no_of_groups_for_each_arrangement = {5,1,1,1,1,1,1,1,1}, no_of_walls_in_arrangement = {4,3,3,1,6,3,2,2,2},

						wall_width = wall_width, wall_height = wall_height,

						wall_translations = { { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0}, 
												{0,0.5*wall_width-0.5*wall_height}, {-0.5*wall_width+0.5*wall_height,0} },
											  
											  { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0}, 
												{-0.5*wall_width+0.5*wall_height,0} },										  	 
											  
											  { {0.5*wall_width-0.5*wall_height,0}, {0,0.5*wall_width-0.5*wall_height}, 
												{-0.5*wall_width+0.5*wall_height,0} },													 
											  								 										     							  	 
											  {	{0.5*wall_width-0.5*wall_height,0} }, 
											  					 
											  { {0,-0.5*wall_width+0.5*wall_height}, {0,-0.5*wall_width+1.6*wall_height}, {0,-0.5*wall_width+2.6*wall_height}, 
											    {0.5*wall_width-0.5*wall_height,0}, {0,0.5*wall_width-0.5*wall_height}, {-0.5*wall_width+0.5*wall_height,0} },

											  { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0}, {-0.5*wall_width+0.5*wall_height,0} },
											  
											  { {0.5*wall_width-0.5*wall_height,0}, {0,0.5*wall_width-0.5*wall_height} },

											  { {0,-0.5*wall_width+0.5*wall_height}, {0,0.5*wall_width-0.5*wall_height} },

											  { {0,-0.5*wall_width+0.5*wall_height}, {0,0.5*wall_width-0.5*wall_height} }											 
				
											}, 

						wall_rotations = { {0,90,180,270}, {0,90,270}, {90,180,270}, {90}, {0,0,0,90,180,270}, {0,90,270}, {90,180}, {0,180}, {0,180} }, 

						wall_group_coordinates = { 	{ x=startPointX, y=2*wall_width }, 
											 	   	{ x=startPointX + 2*wall_width, y=2*wall_width }, 											 	   	
											 	   	{ x=startPointX + 3*wall_width, y=2*wall_width }, 
											 	   	{ x=startPointX + 2*wall_width, y=4*wall_width },
											 	   	{ x=startPointX + 2*wall_width, y=5*wall_width }, 
											 	   	{ x=startPointX + 3*wall_width, y=3*wall_width },				 					 		  
													{ x=startPointX + 3*wall_width, y=5*wall_width },
													{ x=startPointX + 3.5*wall_width - 0.5*wall_height, y=4*wall_width },													
													{ x=startPointX, y=3*wall_width },
													{ x=startPointX + 2*wall_width, y=6*wall_width },
													{ x=startPointX + 2*wall_width, y=7*wall_width },
													{ x=startPointX + wall_width, y=7*wall_width },
													{ x=startPointX, y=7*wall_width }										
												},

						wall_colours = { { {0.467,0,0.812}, {0.467,0,0.812}, {0.510,0.933,0.933}, {0.467,0,0.812} }, 
										 { {0.467,0,0.812}, {0.510,0.933,0.933}, {0.467,0,0.812}, {0.467,0,0.812} },																	 										 																	 
										 { {0.467,0,0.812}, {0.467,0,0.812}, {0.933,0.510,0}, {0.510,0.510,0.933} },
										 { {0.467,0,0.812}, {0.467,0,0.812}, {0.510,0.510,0.933}, {0.467,0,0.812} },
										 { {0.510,0.933,0.510}, {0.933,0.510,0.933}, {0.467,0,0.812}, {0.467,0,0.812} },
										 { {0.933,0.510,0.933}, {0.467,0,0.812}, {0.467,0,0.812} },								 
										 { {0.467,0,0.812}, {0.467,0,0.812}, {0.933,0.510,0} },		
										 { {0.467,0,0.812} },
										 { {0.510,0.510,0.933}, {0.510,0.933,0.510}, {0.467,0,0.812}, {0.467,0,0.812}, {0.467,0,0.812}, {0.467,0,0.812} },																		 
										 { {0.510,0.933,0.933}, {0.467,0,0.812}, {0.467,0,0.812} }, 
										 { {0.467,0,0.812}, {0.467,0,0.812} }, 
										 { {0.467,0,0.812}, {0.467,0,0.812} }, 
										 { {0.467,0,0.812}, {0.467,0,0.812} }										
									   },						
						
						portal_coordinates = { { x=startPointX, y=2*wall_width }, 
											   { x=startPointX + 2*wall_width, y=4*wall_width } 
											 },

						exit_coordinates = { { x=startPointX-0.5*wall_width, y=7*wall_width, rotation=270 } }

					}

levels.wallGroupsTbl = {}
levels.portalTags = {'A', 'A'} --movement is only possible between portals of the same tags

levels.laserTrapDetails = { no_of_traps = 1, no_of_lasers_per_trap = 2, intervaltimer = 2000, 
							lasers_location = { {x=startPointX + 2.75*wall_width, y=3.5*wall_width}, {x=startPointX + 3.5*wall_width,y=4.5*wall_width} },
							lasers_direction = { 90, -90 }, distanceBetweenWalls = wall_width
						  } --wallid refers to the wallgroupid where the laser traps are mounted at

levels.rapidSpikeTrapDetails = { startPos = {x=startPointX+0.5*wall_width, y=6*wall_width}, endPos = {x=startPointX+0.5*wall_width, y=8.5*wall_width},
								 intervaltimer = 2000, spike_direction = 90, x_velocitymin = 0, x_velocitymax = 0, y_velocitymin = 80, y_velocitymax = 150													 			  
					   		   }

levels.isthereGuideText = true
levels.guideText = { {text="Wut! rapid moving spikes??!! Got to dodge them!"} }


return levels 

