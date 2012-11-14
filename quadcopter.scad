/*   	Flyscreen quadcopter.
		
		These pieces are designed to fit onto the square folded aluminium bars used
		as frames around flyscreens.
		
		by Travis Howse <tjhowse@gmail.com>
		2012.   License, GPL v2 or later
**************************************************/

// Screen frame profile
/*
^
| Y
|
|	X
------>

-----	
| i	|
| n	|
| n	| <-- body
| r	|
-----
	|
	| <-- channel
-----
*/

inner_x = 9.3;
inner_y = 16.3;

whole_x = 9.9;
whole_y = 24.0;

channel_x = 7.5;
channel_y = 4.88;

body_x = whole_x;
body_y = 17.75;

plug_z = 20;
plug_exp = 0.5;
plug_x = inner_x - plug_exp;
plug_y = inner_y - plug_exp;

wall_thickness = 2;
spread_gap = 0.75;
hub_spread_gap = 0;
spread_slice = 0.6;
$fn = 20;

plate_hole_dist = 42;
plate_xy = (plate_hole_dist+5*wall_thickness)/sqrt(2);

hub_sleeve_z = 20;
hub_plug_z = 30;

leg_clip_clippy = 1.5;
leg_clip_z = 10;
leg_z = 50;
leg_xy = 5;

zff = 0.005;

apm_sleeve_z = 15;

module spreader_plug()
{
	// This piece forms a part of the motor_mount();
	translate([0,0,plug_z/2]) difference()
	{
		union()
		{
			difference()
			{
				cube([plug_x-spread_gap,plug_y-spread_gap,plug_z],true);
				rotate([0,0,atan(plug_x/plug_y)]) cube([spread_slice,100,plug_z],true);
				rotate([0,0,-atan(plug_x/plug_y)]) cube([spread_slice,100,plug_z],true);
			}
		}
		translate([0,0,-plug_z/2-5]) cylinder(r1=2.8/2, r2=0.8,h=plug_z*2);
	}	
}

module mount_plate()
{
	// This piece forms a part of the motor_mount();
	difference()
	{
		cube([plate_xy,plate_xy,wall_thickness],true);
		for (i = [45, 135, 225, 315])
		{
			rotate([0,0,i]) translate([plate_hole_dist/2,0,-zff-wall_thickness/2]) cylinder(r=1.5,h=10);
		}
	}	
}

module motor_mount()
{
	// This clips onto the end of the arm. You can optionally put a screw in the end
	// to assist with locking it in place.
	
	difference()
	{
		cube([whole_x+2*wall_thickness,whole_y+2*wall_thickness,plate_xy]);
		translate([wall_thickness,wall_thickness,wall_thickness]) cube([whole_x,whole_y,plate_xy]);
		translate([(whole_x+2*wall_thickness)/2,body_y/2+wall_thickness,0]) cylinder(r=1.5, h=100);
	}
	translate([(whole_x+2*wall_thickness)/2,wall_thickness/2,plate_xy/2]) rotate([90,0,0]) mount_plate();
	translate([(whole_x+2*wall_thickness)/2,body_y/2+wall_thickness,0]) spreader_plug();
}

module hub_sleeve()
{
	// This piece slips over the arm prior to attaching it to the hub. When attached
	// to the hub, this slides back towards the hub, locking the arm on.
	difference()
	{
		cube([whole_x+2*wall_thickness,whole_y+2*wall_thickness,hub_sleeve_z]);
		translate([wall_thickness,wall_thickness,0]) cube([whole_x,whole_y,hub_sleeve_z]);
	}
}

module hub_junction()
{
	// This is the centre hub piece. The four arms join here.
	difference()
	{
		union()
		{
			for (i = [0, 90, 180, 270])
			{
				rotate([0,0,i]) translate([0,hub_plug_z/2,0]) rotate([90,0,0]) cube([plug_x-hub_spread_gap/2,plug_y+0.5,hub_plug_z],true);
			}
		}
		// This prompts the slicer to add reenforcement here.
		translate([0,0,-plug_y/2]) #cylinder(r=0.1,h=plug_y);
		for (i = [0, 90, 180, 270])
		{
			rotate([0,0,i]) translate([-(plug_x-hub_spread_gap/2)/2-1,0,-(plug_y+0.5)/2]) #cylinder(r=0.3,h=plug_y+0.5);
		}		
	}
	for (i = [0, 90, 180, 270])
	{
		rotate([0,0,i]) translate([4.4,-4.4,-(plug_y+0.5)/2]) rotate([90,0,0]) fillet(4,plug_y+0.5);
	}	
}

module fillet(radius, length)
{
	translate([-zff,0,-zff]) difference()
	{
		cube([radius,length,radius]);
		translate([radius,length+zff,radius]) rotate([90,0,0]) cylinder(r=radius,h=length+2*zff);
	}
}

module hub_junction_channel()
{
	// This is a little bar that fits into the channel and can be hammered into the
	// sleve to strengthen the grip at the hub.
	rotate([0,0,i]) translate([0,hub_plug_z/2,0]) rotate([90,0,0]) cube([channel_x-spread_gap/2,channel_y-spread_gap/2,hub_plug_z],true);
}

module leg()
{
	// This clips onto the arm near the motor mount and holds the quad leg_z mm off the
	// ground. They are somewhat sacrificial, expect to break a few on rough landings.
	// This is intentional, because they're cheap and easy to make. It's better to 
	// break these than other bits.
	
	whole_y = whole_y*1.04;
	
	difference()
	{
		cube([whole_x+2*wall_thickness,whole_y+2*wall_thickness,hub_sleeve_z]);
		translate([wall_thickness,wall_thickness,0]) cube([whole_x,whole_y,hub_sleeve_z]);
		translate([wall_thickness*2,leg_clip_clippy*2,0]) cube([whole_x,whole_y-2*leg_clip_clippy,hub_sleeve_z]);
	}
	translate([-leg_xy,0,0]) cube([leg_xy,leg_z+whole_y+2*wall_thickness,leg_xy]);
}

module apm_mount()
{
	// This clips onto the arm near the motor mount and holds the quad leg_z mm off the
	// ground. They are somewhat sacrificial, expect to break a few on rough landings.
	// This is intentional, because they're cheap and easy to make. It's better to 
	// break these than other bits.
	
	whole_x = whole_x*1.04;
	whole_y = whole_y*1.04;
	
	apm_space_z = 6;
	apm_band_gap = 4;
	
	peg_size = 3;
	
	difference()
	{
		cube([whole_x+2*wall_thickness,whole_y+2*wall_thickness,apm_sleeve_z]);
		translate([wall_thickness,wall_thickness,0]) cube([whole_x,whole_y,apm_sleeve_z]);
		translate([wall_thickness*2,leg_clip_clippy*2,0]) cube([whole_x,whole_y-2*leg_clip_clippy,apm_sleeve_z]);
	}
	translate([whole_x/2+wall_thickness-leg_xy/2,whole_y+2*wall_thickness,0]) #cube([leg_xy,apm_space_z+2*peg_size+apm_band_gap,peg_size]);
	translate([whole_x/2+wall_thickness-peg_size*1.5,whole_y+2*wall_thickness+apm_space_z,0]) cube([peg_size*3,peg_size,peg_size]);
	translate([whole_x/2+wall_thickness-peg_size*1.5,whole_y+2*wall_thickness+apm_space_z+peg_size+apm_band_gap,0]) cube([peg_size*3,peg_size,peg_size]);
	translate([-leg_xy/2,0,0]) cube([leg_xy/2,whole_y+2*wall_thickness,leg_xy]);
}

module apm_tab()
{
	difference()
	{
		hull()
		{
			translate([0,10,0]) cube([10,10,2]);
			translate([5,5,0]) cylinder(r=5,h=2);
		}
		translate([5,5,0]) cylinder(r=2.5,h=2);
	}
	translate([0,8,0])cube([10,2,4]);
}

module apm_frame()
{
	//71x45
	apm_y = 71;
	
	cube([10,apm_y,2],true);
	cube([45,10,2],true);
	translate([-5,-apm_y/2-10,-1]) apm_tab();
	mirror([0,-1,0]) translate([-5,-apm_y/2-10,-1]) apm_tab();
	translate([45/2+10,-5,-1]) rotate([0,0,90]) apm_tab();
	mirror([-1,0,0]) translate([45/2+10,-5,-1]) rotate([0,0,90]) apm_tab();


}

module leg2()
{
	// This clips onto the arm near the motor mount and holds the quad leg_z mm off the
	// ground. They are somewhat sacrificial, expect to break a few on rough landings.
	// This is intentional, because they're cheap and easy to make. It's better to 
	// break these than other bits.
	
	whole_y = whole_y*1.04;
	leg2_clip_clippy = 2;
	
	leg_r = 30;
	leg_z = 10;
	leg_wall_thickness = 1.6;
	
	difference()
	{
		cube([whole_x+2*wall_thickness,whole_y+2*wall_thickness,hub_sleeve_z]);
		translate([wall_thickness,wall_thickness,0]) cube([whole_x,whole_y,hub_sleeve_z]);
		#translate([wall_thickness+leg2_clip_clippy,0,0]) cube([whole_x-2*leg2_clip_clippy,whole_y,hub_sleeve_z]);
	}
	translate([(whole_x+2*wall_thickness)/2,whole_y+wall_thickness+leg_r,0]) difference()
	{
		cylinder(r=leg_r,h=leg_z,$fn=30);
		cylinder(r=leg_r-leg_wall_thickness,h=leg_z,$fn=30);
	}
	
}

module leg3()
{
	// This clips onto the arm near the motor mount and holds the quad leg_z mm off the
	// ground. They are somewhat sacrificial, expect to break a few on rough landings.
	// This is intentional, because they're cheap and easy to make. It's better to 
	// break these than other bits.
	
	whole_y = whole_y*1.04;
	leg2_clip_clippy = 2;
	
	leg_r = 30;
	leg_z = 10;
	leg_wall_thickness = 1.125;
	hub_sleeve_z = 10;
	
	difference()
	{
		union()
		{
			difference()
			{
				cube([whole_x+2*wall_thickness,whole_y+2*wall_thickness,hub_sleeve_z]);
				translate([wall_thickness+leg2_clip_clippy,0,0]) cube([whole_x-2*leg2_clip_clippy,whole_y,hub_sleeve_z]);
			}
			translate([-1,2,0]) cube([2,2,hub_sleeve_z]);
			translate([whole_x+2*wall_thickness-1,2,0]) cube([2,2,hub_sleeve_z]);
			translate([(whole_x+2*wall_thickness)/2,whole_y+wall_thickness+leg_r,0]) difference()
			{
				union()
				{
					intersection()
					{
						translate([0,11,0]) scale([0.94,1.4,1]) cylinder(r=leg_r+1.5*wall_thickness,h=leg_z,$fn=30);
						translate([0,-60,0]) cube([100,100,100],true);
					}
					cylinder(r=leg_r,h=leg_z,$fn=30);
				}
				cylinder(r=leg_r-leg_wall_thickness*1.3,h=leg_z,$fn=30);
			}
		}
		translate([wall_thickness,wall_thickness,0]) cube([whole_x,whole_y,hub_sleeve_z]);
	}
	
}

module leg3_clip(hub_sleeve_z = 10)
{
	whole_x = whole_x+wall_thickness/2+0.5;
	
	
	difference()
	{
		cube([whole_x+4*wall_thickness,9+wall_thickness,hub_sleeve_z]);
		translate([wall_thickness,0,0]) cube([whole_x+2*wall_thickness,9,hub_sleeve_z]);
		translate([1,2,0]) cube([2,4,hub_sleeve_z]);
		translate([whole_x+2*wall_thickness+1,2,0]) cube([2,4,hub_sleeve_z]);
	}

}

module cam_mount()
{
	whole_y = whole_y*1.04;
	leg2_clip_clippy = 2;
	
	//leg_r = 28.5/2;
	//leg_r = 28.5/2;
	nleg_r = 15;
	leg_z = 10;
	leg_wall_thickness = 1.125;
	hub_sleeve_z = 10;
	
	extra_z_offset = 8;
	
	difference()
	{
		union()
		{
			difference()
			{
				cube([whole_x+2*wall_thickness,whole_y+2*wall_thickness+extra_z_offset,hub_sleeve_z]);
				translate([wall_thickness+leg2_clip_clippy,0,0]) cube([whole_x-2*leg2_clip_clippy,whole_y,hub_sleeve_z]);
			}
			translate([-1,2,0]) cube([2,2,hub_sleeve_z]);
			translate([whole_x+2*wall_thickness-1,2,0]) cube([2,2,hub_sleeve_z]);
			translate([(whole_x+2*wall_thickness)/2,whole_y+wall_thickness+leg_r+extra_z_offset+1,0]) difference()
			{
				union()
				{
					intersection()
					{
						translate([0,7,0]) scale([0.88,1.4,1]) cylinder(r=leg_r+1.5*wall_thickness,h=leg_z,$fn=30);
						translate([0,-55,0]) cube([100,100,100],true);
					}
					cylinder(r=leg_r,h=leg_z,$fn=30);
				}
				cylinder(r=leg_r-leg_wall_thickness*1.3,h=leg_z,$fn=30);
			}
		}
		translate([wall_thickness,wall_thickness,0]) cube([whole_x,whole_y,hub_sleeve_z]);
		translate([wall_thickness-whole_x/4,wall_thickness+extra_z_offset+leg_z+leg_r+whole_y/2,0]) #cube([whole_x*1.5,whole_y,hub_sleeve_z]);
	}
}

module arm_clip(hub_sleeve_z = 10)
{
	whole_y = whole_y*1.04;
	leg2_clip_clippy = 2;
	
	leg_r = 30;
	leg_z = 10;
	leg_wall_thickness = 1.125;
	
	difference()
	{
		union()
		{
			difference()
			{
				cube([whole_x+2*wall_thickness,whole_y+2*wall_thickness,hub_sleeve_z]);
				translate([wall_thickness+leg2_clip_clippy,0,0]) cube([whole_x-2*leg2_clip_clippy,whole_y,hub_sleeve_z]);
			}
			translate([-1,2,0]) cube([2,2,hub_sleeve_z]);
			translate([whole_x+2*wall_thickness-1,2,0]) cube([2,2,hub_sleeve_z]);
		}
		translate([wall_thickness,wall_thickness,0]) cube([whole_x,whole_y,hub_sleeve_z]);
	}
}

module apm_mount2()
{
	// This clips onto the arm near the motor mount and holds the quad leg_z mm off the
	// ground. They are somewhat sacrificial, expect to break a few on rough landings.
	// This is intentional, because they're cheap and easy to make. It's better to 
	// break these than other bits.
	
	whole_x = whole_x*1.04;
	whole_y = whole_y*1.04;
	
	apm_space_z = 6;
	apm_band_gap = 4;
	
	peg_size = 4;
	
	arm_clip();
	
	translate([whole_x/2+wall_thickness-leg_xy/2,whole_y+2*wall_thickness,0]) cube([leg_xy,apm_space_z+2*peg_size+apm_band_gap,peg_size]);
	
	translate([0,whole_y+2*wall_thickness,0]) cube([whole_x/1.04+2*wall_thickness,peg_size+apm_space_z,peg_size]);
	translate([whole_x/2+wall_thickness-peg_size*1.5,whole_y+2*wall_thickness+apm_space_z+peg_size+apm_band_gap,0]) cube([peg_size*3,peg_size,peg_size]);
}

module leg4()
{
	// This clips onto the arm near the motor mount and holds the quad leg_z mm off the
	// ground. They are somewhat sacrificial, expect to break a few on rough landings.
	// This is intentional, because they're cheap and easy to make. It's better to 
	// break these than other bits.
	
	whole_y = whole_y*1.04;
	leg2_clip_clippy = 2;
	
	leg_r = 30;
	leg_z = 10;
	leg_wall_thickness = 2.2;
	hub_sleeve_z = 10;
	spring_stem = 4.5;
	
	intersection()
	{
		translate([-(leg_r),0,0]) cube([2*(leg_r),100,100]);
		union()
		{
			translate([-(whole_x+2*wall_thickness)/2,0,0])	difference()
			{
				difference()
				{
					cube([whole_x+2*wall_thickness,whole_y+2*wall_thickness,hub_sleeve_z]);
					translate([wall_thickness+leg2_clip_clippy,0,0]) cube([whole_x-2*leg2_clip_clippy,whole_y,hub_sleeve_z]);
				}
						
				translate([wall_thickness,wall_thickness,0]) cube([whole_x,whole_y,hub_sleeve_z]);
			}
			translate([-2-(whole_x+wall_thickness)/2,2,0]) cube([2,2,hub_sleeve_z]);
			translate([(whole_x+wall_thickness)/2,2,0]) cube([2,2,hub_sleeve_z]);
			
			translate([0,whole_y+2*wall_thickness+leg_r,0]) difference()	
			{
				union()
				{
					cylinder(r=leg_r,h=leg_z);
					translate([0,10,0]) scale([0.94,1.4,1]) cylinder(r=leg_r+1.5*wall_thickness,h=leg_z,$fn=30);
				}
				translate([0,0,-zff]) cylinder(r=leg_r-leg_wall_thickness,h=leg_z+2*zff);
				translate([0,50,0]) cube([100,100,100],true);
				translate([-whole_x/2,-(whole_y+1*wall_thickness+leg_r),0]) cube([whole_x,whole_y,hub_sleeve_z]);
			}
			
			translate([0,spring_stem+leg_r*2,0]) rotate([0,0,180]) leg4_part(30,5+spring_stem);
			translate([0,leg_r*2,leg_z]) rotate([0,180,180]) leg4_part(30,5);
		}
	}
}

module leg4_part(radius, stem)
{
	whole_y = whole_y*1.04;
	leg2_clip_clippy = 2;
	
	leg_r = 30;
	leg_z = 10;
	leg_wall_thickness = 2.2;
	hub_sleeve_z = 10;
	
	difference()
	{
		cylinder(r=radius,h=leg_z);
		translate([0,0,-zff]) cylinder(r=radius-leg_wall_thickness,h=leg_z+2*zff);
		translate([0,50,0]) cube([100,100,100],true);
		rotate([0,0,45]) translate([0,50,0]) cube([100,100,100],true);
		
	}
	translate([radius-leg_wall_thickness,0,0]) cube([leg_wall_thickness,stem,leg_z]);
}

module flyscreen_rightangle()
{
	// This is the centre hub piece. The four arms join here.
	difference()
	{
		union()
		{
			for (i = [0, 90])
			{
				rotate([0,0,i]) translate([0,hub_plug_z/2,0]) rotate([90,90,0]) cube([plug_x-hub_spread_gap/2,plug_y+0.5,hub_plug_z+1.3]);
			}
		}
		// This prompts the slicer to add reenforcement here.
	
	}
	
}

module motor_mount2()
{
	arm_clip(plate_xy);
	translate([whole_x+2*wall_thickness,whole_y+2.5*wall_thickness,0]) rotate([90,0,0]) fillet(5,plate_xy);
	translate([0,whole_y+2.5*wall_thickness,0]) rotate([90,0,-90]) fillet(5,plate_xy);
	translate([whole_x/2+wall_thickness,whole_y+3*wall_thickness-0.2,plate_xy/2]) rotate([90,0,0]) mount_plate();
	// To help home the

}

module fillet(radius, length)
{
	translate([-zff,0,-zff]) difference()
	{
		cube([radius,length,radius]);
		translate([radius,length+zff,radius]) rotate([90,0,0]) cylinder(r=radius,h=length+2*zff);
	}
}

module motor_mount2_plug()
{
	difference()
	{
		translate([-(plug_x-hub_spread_gap/2)/2,-(plug_y+0.5)/2,0]) cube([plug_x-hub_spread_gap/2,plug_y+0.5,plate_xy]);
		translate([plug_x-hub_spread_gap/2,0,plate_xy+(20*sqrt(2))/4]) rotate([0,45,0]) cube([20,20,20],true);
		translate([-plug_x-hub_spread_gap/2,0,plate_xy+(20*sqrt(2))/4]) rotate([0,45,0]) cube([20,20,20],true);
		
		translate([0,plug_y+0.5-5,plate_xy+(20*sqrt(2))/4]) rotate([45,0,0]) cube([20,20,20],true);
		translate([0,-(plug_y+0.5)+5,plate_xy+(20*sqrt(2))/4]) rotate([45,0,0]) cube([20,20,20],true);
		cylinder(r=1.5,h=20);
	}
	
}
	
// Four of each of these:
//motor_mount();
//hub_sleeve();
//hub_junction_channel();
//leg();
//apm_mount();
//leg2();
//leg3();
//leg4();
//leg4_part(30,10);
//motor_mount2();
//translate([50,0,0]) motor_mount();
//leg3_clip(plate_xy);
 motor_mount2_plug();
//cam_mount();
//apm_mount2();

//apm_mount2();
//apm_frame();
//cube([45,70,20],true);

// And one of these:
//hub_junction();
//flyscreen_rightangle();



