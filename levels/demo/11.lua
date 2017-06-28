local levels = {}
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local myApp = require( "libs.myapp" ) 
-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH
local startPointX, wall_width, wall_height = 2*math.floor(0.8*screenW/9), myApp.wall_width, myApp.wall_height
local spike_width, puzzle_triangle_width = wall_width/5, math.floor((2*wall_width)/7)
local puzzle_triangle_starting_coord = {x=(startPointX+1.65*wall_width)+(0.5*puzzle_triangle_width),y=3*wall_width}

levels.difficulty = 'easy'
levels.no_ofshapes = { circles = 4, wall_arrangement_types = 7, portals = 2, exit_sensor = 1 }
	
levels.shapeDetails = { circle_radius = 0.15*wall_width, scale = 1, 

						circle_coordinates = 
						{ 														
							{ x=startPointX + 0.2*wall_width, y=2.5*wall_width },
							{ x=startPointX + 3.2*wall_width, y=1.5*wall_width },
							{ x=startPointX + 2.8*wall_width, y=1.5*wall_width },									
							{ x=startPointX - 0.2*wall_width, y=2.5*wall_width }	
						},
						
						circle_colours = { {0.510,0.933,0.933}, {0.510,0.510,0.933}, {0.933,0.510,0}, {0.510,0.933,0.510} },					 

						no_of_groups_for_each_arrangement = {5,1,2,2,1,4,2}, no_of_walls_in_arrangement = {4,3,2,2,2,1,1},

						wall_width = wall_width, wall_height = wall_height,

						wall_translations = { { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0}, 
												{0,0.5*wall_width-0.5*wall_height}, {-0.5*wall_width+0.5*wall_height,0} },
											  
											  { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0}, 
												{0,0.5*wall_width-0.5*wall_height} },													 																						  	 
											  
											  { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0} },	

											  { {0,0.5*wall_width-0.5*wall_height}, {-0.5*wall_width+0.5*wall_height,0} },	
																						
											  { {0.5*wall_width-0.5*wall_height,0}, {0,0.5*wall_width-0.5*wall_height} }, 											   											  											 
											  																						  					 
											  { {-0.5*wall_width+0.5*wall_height,0} },

											  { {0.5*wall_width-0.5*wall_height,0} }										
				
											}, 

						wall_rotations = { {0,90,180,270}, {0,90,180}, {0,90}, {180,270}, {90,180}, {270}, {90} }, 

						wall_group_coordinates = { 	{ x=startPointX, y=1.5*wall_width }, 
											 	   	{ x=startPointX + 2*wall_width, y=1.5*wall_width }, 											 	   	
											 	   	{ x=startPointX + 3*wall_width, y=1.5*wall_width }, 
											 	   	{ x=startPointX, y=2.5*wall_width },
											 	   	{ x=startPointX + wall_width, y=5.5*wall_width }, 
											 	   	{ x=startPointX + wall_width, y=6.5*wall_width },				 					 		  
													{ x=startPointX + 3*wall_width, y=2.5*wall_width },
													{ x=startPointX, y=4.5*wall_width },
													{ x=startPointX + 2*wall_width, y=5.5*wall_width }, 																								
													{ x=startPointX, y=6.5*wall_width },	
													{ x=startPointX + 3*wall_width, y=5.5*wall_width },
													{ x=startPointX + 1.5*wall_width + 0.5*wall_height, y=2.5*wall_width },												
													{ x=startPointX + 1.5*wall_width + 0.5*wall_height, y=3.5*wall_width },
													{ x=startPointX + 1.5*wall_width + 0.5*wall_height, y=4.5*wall_width },
													{ x=startPointX - 0.5*wall_width + 0.5*wall_height, y=5.5*wall_width },
													{ x=startPointX + 3.5*wall_width - 0.5*wall_height, y=3.5*wall_width },
													{ x=startPointX + 3.5*wall_width - 0.5*wall_height, y=4.5*wall_width }
																																																	
												},

						wall_colours = { { {0.467,0,0.812}, {0.467,0,0.812}, {0.510,0.933,0.933}, {0.467,0,0.812} }, 
										 { {0.467,0,0.812}, {0.933,0.510,0}, {0.467,0,0.812}, {0.467,0,0.812} },																	 										 																	 
										 { {0.467,0,0.812}, {0.467,0,0.812}, {0.933,0.510,0}, {0.933,0.510,0.933} },
										 { {0.933,0.510,0}, {0.467,0,0.812}, {0.467,0,0.812}, {0.467,0,0.812} },
										 { {0.467,0,0.812}, {0.510,0.933,0.510}, {0.933,0.510,0}, {0.467,0,0.812} },										 								 
										 { {0.510,0.933,0.510}, {0.467,0,0.812}, {0.467,0,0.812} },																			 											
										 { {0.510,0.510,0.933}, {0.467,0,0.812} },	
										 { {0.467,0,0.812}, {0.467,0,0.812} },								
										 { {0.467,0,0.812}, {0.933,0.510,0} }, 																												
										 { {0.467,0,0.812}, {0.467,0,0.812} },
										 { {0.467,0,0.812}, {0.467,0,0.812} },	
										 { {0.467,0,0.812} }, 
										 { {0.467,0,0.812} },
										 { {0.467,0,0.812} },
										 { {0.467,0,0.812} },																		 
										 { {0.467,0,0.812} },
										 { {0.467,0,0.812} }
									   },						
						
						portal_coordinates = { { x=startPointX, y=1.5*wall_width }, 
											   { x=startPointX + 2*wall_width, y=1.5*wall_width } 
											 },

						exit_coordinates = { { x=startPointX-0.45*wall_width, y=4.4*wall_width, rotation=90 } }
					 
					}

levels.wallGroupsTbl = {}
levels.portalTags = {'A', 'A'} --movement is only possible between portals of the same tags

levels.teslaWallsDetails = { scale=0.25, no_of_walls = 4, wall={ colour={0.467,0,0.812}, rotation={0,0,90,90}, 
							coordinates={ {x=startPointX+2*wall_width, y=3.5*wall_width}, {x=startPointX+3*wall_width, y=4.5*wall_width},
										  {x=startPointX+2*wall_width, y=3*wall_width}, {x=startPointX+3*wall_width, y=3.5*wall_width} },
							direction={'vertical', 'vertical', 'horizontal', 'horizontal'}, 										
							speed={ {x=0,y=50},{x=0,y=40},{x=50,y=0},{x=-40,y=0} }, delta=100
							} --closes wall table 
						   } --closes teslaWallDetails table

levels.isthereGuideText = true
levels.guideText = { {text="avoid the electrified walls or...!!"} }


return levels 

