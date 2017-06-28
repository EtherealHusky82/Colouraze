local levels = {}
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local myApp = require( "libs.myapp" ) 
-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH
local startPointX, wall_width, wall_height = 2*math.floor(0.8*screenW/9), myApp.wall_width, myApp.wall_height

levels.difficulty = 'easy'
levels.no_ofshapes = { circles = 4, wall_arrangement_types = 3, portals = 2, exit_sensor = 1 }
	
levels.shapeDetails = { circle_radius = 0.15*wall_width,  scale = 1, 

						circle_coordinates = 
						{ 
							{ x=startPointX + 2*wall_width, y=2*wall_width },
							{ x=startPointX - wall_height, y=3*wall_width },
							{ x=startPointX + wall_height, y=3*wall_width },
							{ x=startPointX + 2*wall_width, y=3*wall_width }				
						},
						
						circle_colours = { {1,0,0}, {0,1,0}, {0,0,1}, {0.949,0.839,0} },

						no_of_groups_for_each_arrangement = {8,1,1}, no_of_walls_in_arrangement = {4,5,2},

						wall_width = wall_width, wall_height = wall_height,

						wall_translations = { { {0,-0.5*wall_width+0.5*wall_height}, {0.5*wall_width-0.5*wall_height,0}, 
												{0,0.5*wall_width-0.5*wall_height}, {-0.5*wall_width+0.5*wall_height,0} },

											  { {0,-0.5*wall_width+0.5*wall_height}, {0,-0.5*wall_width+wall_height}, {0,-0.5*wall_width+1.5*wall_height}, 
											    {0.5*wall_width-0.5*wall_height,0}, {-0.5*wall_width+0.5*wall_height,0} }, 
												

											  { {0.5*wall_width-0.5*wall_height,0}, {-0.5*wall_width+0.5*wall_height,0} }											  	
											}, 

						wall_rotations = { {0,90,180,270}, {0,0,0,90,270}, {90,270} }, 

						wall_group_coordinates = { 	{ x=startPointX, y=2*wall_width }, 
											 	   	{ x=startPointX + 2*wall_width, y=2*wall_width }, 
											 	   	{ x=startPointX + 3*wall_width, y=2*wall_width }, 
											 	   	{ x=startPointX, y=3*wall_width }, 
											 	   	{ x=startPointX + 2*wall_width, y=3*wall_width }, 
											 	   	{ x=startPointX + 2*wall_width, y=4*wall_width }, 
											 		{ x=startPointX + wall_width, y=5*wall_width }, 
											 		{ x=startPointX + 2*wall_width, y=5*wall_width }, 
											 		{ x=startPointX + wall_width, y=6*wall_width },
											 		{ x=startPointX + wall_width, y=7*wall_width }
												},

						wall_colours = { { {0.961,0.639,0}, {0.961,0.639,0}, {0,1,0}, {0.961,0.639,0} }, 
										 { {0.961,0.639,0}, {0,1,0}, {0,1,0}, {0.961,0.639,0} 		  },																	 
										 { {0.961,0.639,0}, {0.961,0.639,0}, {0.961,0.639,0}, {1,0,0} 		  },																	 
										 { {1,0,0}, {0.961,0.639,0}, {0.961,0.639,0}, {0.961,0.639,0}	      },
										 { {0,0,1}, {0.961,0.639,0}, {0,1,0}, {0.961,0.639,0}			      },
										 { {0.949,0.839,0}, {0.961,0.639,0}, {0.949,0.839,0}, {0.961,0.639,0} },
										 { {0.961,0.639,0}, {0,1,0}, {0.961,0.639,0}, {0.961,0.639,0}		  },
										 { {0,0,1}, {0.961,0.639,0}, {0.961,0.639,0}, {0.961,0.639,0}	      },
										 { {1,0,0}, {0,0,1}, {0.949,0.839,0}, {0.961,0.639,0}, {0.961,0.639,0} },
										 { {0.961,0.639,0}, {0.961,0.639,0} }
									   },						
						
						portal_coordinates = { { x=startPointX, y=2*wall_width }, 
											   { x=startPointX + 3*wall_width, y=2*wall_width } 
											 },

						exit_coordinates = { { x=startPointX + wall_width, y=7.5*wall_width } }

					}

levels.wallGroupsTbl = {}
levels.portalTags = {'A', 'A'} --movement is only possible between portals of the same tags
levels.isthereGuideText = true
levels.guideText = { {text=''} }

return levels 

