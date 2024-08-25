/*
cnc 3018 300 watt power supply case
rounded cube approach

Created June 12, 2022
Modified June 20, 2022

Remix, but total rewrite of
https://www.printables.com/model/94588

Requires roundedcube.scad library
https://danielupshaw.com/openscad-rounded-corners/

June 15, 2022 - added variables to OpenSCAD customizer
*/

include <roundedcube.scad>
include <honeycomb.scad>

/* [tolerance / error] */

// printing tolerance
err = 0.1; // 0.02

/* [power supply exterior dimensions] */

// power supply length
ps_l= 215; // 0.1
// p/s width
ps_w = 114.5; // 0.1
// p/s height
ps_h = 50; // 0.1

/* [case dimensiona] */

// case rounded cube corner radius
case_r = 1.5; // 0.1
// case wall thickness
case_t = 1.6;
// case width

/* [screw hole dimensions] */

// screw hole diameter (m4 screw)
scr_d = 4.2;
// countersink diameter
scr_cs_d = 8.3;

/* [mounting screw dimensions] */

// mounting screw x / y offset from corner
mnt_scr_off = 32.5;
// x distance between bottom mounting screws
bott_hole_dist = 50; // 0.1
// z distance from p/s side to mounting screw
mnt_scr_z_off = 12.7;

/* [iec320 c14 fused switch dimensions from datasheet] */

// switch hole width
sw_w = 28; // 0.1
// length
sw_l = 48; // 0.1
// switch screw hole distance
sw_hole_dist = 40; // 0.1
// tad more space at p/s end (screw hole radius puts hole edge at case edge)
ps_addl_sp = 5; // 0.1

/* ["bumper" bracket for power supply] */

// bracket arm height
brack_h = 2;
// bracket arm width
brack_w = 6;

/*  [wiring holes] */

// hole for spindle power wires
spindle_wire_hole_d = 15; // 0.1
// hole length for JST PWM wires (to motherboard GND / 0-5V PWM connector)
jst_wire_hole_l = 12; // 0.1
// hole width for JST PWM wires (to motherboard GND / 0-5V PWM connector)
jst_wire_hole_w = 7; // 0.1
// extra wiring length (padding)
wiring_addl_sp = 0; // 0.1

/* [ventilation slots] */
// type of ventilation slot
vent_type = "none"; // ["diagonal", "honeycomb", "none"]
// vent angle if vent_type == "diagonal"
vent_theta = 30;
// vent slot width
vent_slot_w = 2; // 0.1
// top/bottom vent spacing margin
vent_slot_margin = 3;

/* [switch options] */

// switch position
sw_pos = "front"; // ["front", "top"]
// switch hole is rectangle (else 6-sided polygon)
sw_hole_is_rect = false;
// flat end of switch hole on right (if 6-sided polygon)
switch_flat_right = true;

/* [drawing options] */

// draw main case
draw_case = true;
// draw test slice of case top
draw_test_top = false;
// draw test slice of case front
draw_test_front = false;
// draw test slice of case slide
draw_test_side = false;
// test slice thickness
slice_t = 3;

/* [Hidden] */

// case width
case_w = ps_w + case_t * 2;
// case height
case_h = ps_h + case_t * 2;
// length of power supply end
ps_end_l = mnt_scr_off + ps_addl_sp;

// switch housing wall thickness
sw_wall_t = case_t * 1.5 + err/2;
// switch housing width
sw_frame_w = sw_w + sw_wall_t * 2;
// switch housing length
sw_frame_l = sw_l + sw_wall_t * 2;
// switch housing height
sw_frame_h = case_t + err;

// switch screw hole y offset (screw near end)
sw_near_hole_y_off = case_t + 5;
// space between screws and switch
sw_frame_y_sp = (sw_hole_dist - sw_frame_w) / 2;
// switch frame y offset
sw_frame_y_off = sw_near_hole_y_off + sw_frame_y_sp;
// switch frame z offset
sw_frame_z_off = case_h - sw_frame_h;
// switch frame x offset
sw_frame_x_off = 10;

// length of wiring end
wiring_end_l = sw_near_hole_y_off + sw_hole_dist + wiring_addl_sp;
// mounting screw y offset
mnt_scr_case_y_off = wiring_end_l + mnt_scr_off;
// total case length
case_l = ps_end_l + wiring_end_l;

// switch hole x offset
sw_hole_x_off = sw_frame_x_off + sw_frame_l / 2;
// far switch screw hole y offset (inside screw)
sw_far_hole_y_off = sw_near_hole_y_off + sw_hole_dist;
// switch hole z offset
sw_hole_z_off = case_h - case_t - err;

// general hole height
hole_h = case_t + err;

sw_poly_pts_ctr = [
    [-sw_l/2, -sw_w/2],
    [sw_l * 3/8, -sw_w/2],
    [sw_l/2, -sw_w/2 + sw_l/8], // + 6
    [sw_l/2, sw_w/2 - sw_l/8],
    [sw_l * 3/8, sw_w/2],
    [-sw_l/2, sw_w/2]
];

ps_brack_pts = [
    [0, 0],
    [brack_w, 0],
    [brack_w, brack_h],
    [brack_h, brack_h],
    [brack_h, case_h - case_t * 2 - brack_h],
    [brack_w, case_h - case_t * 2 - brack_h],
    [brack_w, case_h - case_t * 2],
    [0, case_h - case_t * 2]
];

/* begin code modules */

module reg_screwhole() {
    cylinder(d=scr_d, h=hole_h);
}

// not used
module cs_screwhole() {
    reg_screwhole();
    translate([0, 0, case_t - scr_cs_h])
        cylinder(d=scr_cs_d, scr_cs_h);
}

// entire cube of case -- rest will be cut from this
module case_stock() {
    roundedcube(size=[case_w, case_l, case_h], radius=case_r);
}

module case_main() {
    difference() {
        case_stock();
        translate([case_t, case_t, case_t])
            cube(size=[ps_w, case_l, ps_h]);
    }
    draw_brackets();
}

module draw_switch_frame_rect() {
    if(sw_pos == "top") {
        translate([sw_frame_x_off, sw_frame_y_off, case_h - sw_frame_h])
        difference() {
            color("blue")
            cube(size=[sw_frame_l, sw_frame_w, sw_frame_h]);
            translate([sw_wall_t, sw_wall_t, 0])
            color("red")
                cube(size=[sw_l + err, sw_w + err, sw_frame_h]);
        }
    }
    else { // front
        translate([sw_frame_x_off, 0, sw_near_hole_y_off + sw_frame_y_sp])
        difference() {
            color("blue")
            cube(size=[sw_frame_l, sw_frame_h, sw_frame_w]);
            translate([sw_wall_t, 0, sw_wall_t])
            color("red")
                cube(size=[sw_l + err, sw_frame_h, sw_w + err]);
        }
    }
}

module draw_switch_frame_six_sides() {
    /*
    Rough sketch:
        ─ ─ ─ ─ ─ ─ ─ 
        │             ╲ 
        │              │
        │              │
        │             ╱ 
        ─ ─ ─ ─ ─ ─ ─ 
    */

    reflect = switch_flat_right ? [1, 0, 0] : [0, 0, 0];
    if(sw_pos == "top") {
        translate([sw_frame_x_off + sw_l/2 + sw_wall_t, sw_frame_y_off + sw_w/2 + sw_wall_t, sw_frame_z_off])
        linear_extrude(sw_frame_h) {
            mirror(reflect)
            color("yellow")
            difference() {
                offset(delta=sw_wall_t)
                polygon(sw_poly_pts_ctr);

                offset(delta=err/2)
                polygon(sw_poly_pts_ctr);
            }
        }
    }
    else { // front}
        translate([sw_frame_x_off + sw_l/2 + sw_wall_t, sw_frame_h, case_h/2])
        rotate([90, 0, 0])
        linear_extrude(sw_frame_h) {
            mirror(reflect)
            difference() {
                offset(delta=sw_wall_t)
                polygon(sw_poly_pts_ctr);

                offset(delta=err/2)
                polygon(sw_poly_pts_ctr);
            }
        }
    }
}

module draw_plug_hole_rect() {
    if(sw_pos == "top") {
        translate([sw_frame_x_off, sw_frame_y_off, case_h  - sw_frame_h])
            cube(size=[sw_frame_l, sw_frame_w, sw_frame_h]);
    }
    else { // front
        translate([sw_frame_x_off, 0, sw_near_hole_y_off + sw_frame_y_sp])
            cube(size=[sw_frame_l, sw_frame_h, sw_frame_w]);
    }
}

module draw_plug_hole_six_sides() {
    reflect = switch_flat_right ? [1, 0, 0] : [0, 0, 0];
    if(sw_pos == "top") {
        translate([sw_frame_x_off + sw_l/2 + sw_wall_t, sw_frame_y_off + sw_w/2 + sw_wall_t, case_h - sw_frame_h])
            linear_extrude(sw_frame_h) {
                mirror(reflect)
                offset(delta=err/2)
                polygon(sw_poly_pts_ctr);
            }
    }
    else { // front
        translate([sw_frame_x_off + sw_l/2 + sw_wall_t, sw_frame_h, case_h/2])
        rotate([90, 0, 0])
        linear_extrude(sw_frame_h) {
            mirror(reflect)
            offset(delta=err/2)
            polygon(sw_poly_pts_ctr);
        }
    }
}
reg_switch_snap_on = true;
module draw_switch_holes() {
    if(sw_hole_is_rect) {
        draw_plug_hole_rect();
    }
    else {
        draw_plug_hole_six_sides();
    }
    if (!reg_switch_snap_on){
    if(sw_pos == "top") {
        translate([sw_hole_x_off, sw_near_hole_y_off, sw_hole_z_off])
            reg_screwhole();
        translate([sw_hole_x_off, sw_far_hole_y_off, sw_hole_z_off])
            reg_screwhole();
    }
    else {
        rotate([90, 0, 0]) {
        translate([sw_hole_x_off, sw_near_hole_y_off, -hole_h])
            reg_screwhole();
        translate([sw_hole_x_off, sw_far_hole_y_off, -hole_h])
            reg_screwhole();
        }
    }
}
}

module bracket() {
    linear_extrude(wiring_end_l) {
        polygon(ps_brack_pts);
    }
}

module draw_brackets() {
    translate([case_t, wiring_end_l, case_t])
    rotate([90, 0, 0])
    bracket();

    translate([case_w - case_t, wiring_end_l, case_t])
    rotate([90, 0, 0])
    mirror([1, 0, 0])
    bracket();
}

module diagonal_vent(dim_x, dim_y) {
    min_dim = min(dim_x, dim_y);
    max_dim = max(dim_x, dim_y);
    hyp_dim = sqrt(pow(min_dim, 2) + pow(max_dim, 2));
    inc = vent_slot_w + vent_slot_margin;
    num_vents = floor(max_dim / inc) + 2 * floor(min_dim / inc);
    factor = max_dim == dim_x ? [1, 0] : [0, 1];

    linear_extrude(case_t)
    intersection() {
        square(size=[dim_x, dim_y]);
        for(i = [0 : num_vents]) {
            translate([factor.y * inc/2 + inc * i * factor.x, factor.x * inc/2 + inc * i * factor.y, 0])
            rotate([0, 0, vent_theta]) {
                round_all_vertices(0.75)
                square(size=[vent_slot_w, hyp_dim], center=false);
            }
        }
    }
}

module honeycomb_vent(dim_x, dim_y, dia=8, wall_t=1.4) {
    translate([dim_x, 0, 0])
    rotate(90)
    linear_extrude(case_t)
    difference() {
        square(size=[dim_y, dim_x]);
        honeycomb(dim_y, dim_x, dia, wall_t);
    }
}

module draw_vents(type=vent_type) {
    vent_w = case_w - case_t * 2 - brack_w * 2;

    if(sw_pos == "top") {  // front vents
        dims = [vent_w, case_h - case_t * 4];

        translate([case_t + brack_w, case_t, case_t * 2])
        rotate([90, 0, 0])
        if(type == "honeycomb") {
            honeycomb_vent(dims.x, dims.y);
        }
        else { // diagonal
            diagonal_vent(dims.x, dims.y);
        }
    }
    else {
        // top vents
        dims = [vent_w, wiring_end_l];

        translate([case_t + brack_w, case_t * 2, case_h - case_t])
        if(type == "honeycomb") {
            honeycomb_vent(dims.x, dims.y);
        }
        else {
            diagonal_vent(dims.x, dims.y);
        }
    }
}

module draw_wire_holes() {
    if(sw_pos == "top") {
        // spindle wire hole
        translate([case_w - 35, sw_near_hole_y_off + sw_hole_dist/2, case_h - case_t - err])
        linear_extrude(hole_h) {
            round_all_vertices(1.5)
            circle(d=spindle_wire_hole_d, $fn=6);
        }

        // jst wire hole
        translate([case_w - 15, sw_near_hole_y_off + sw_hole_dist/2, case_h - case_t/2])
            roundedcube(size=[jst_wire_hole_w, jst_wire_hole_l, hole_h], radius=1, center=true);
    }
    else {
        // spindle wire hole
        translate([sw_frame_l + 30, 0, case_h / 2])
        rotate([270, 0, 0])
        linear_extrude(hole_h) {
            round_all_vertices(1.5)
            circle(d=spindle_wire_hole_d, $fn=6);
        }

        // jst wire hole
        translate([case_w - 15, case_t/2, case_h / 2])
        rotate([270, 0, 0])
            roundedcube(size=[jst_wire_hole_w, jst_wire_hole_l, hole_h], radius=1, center=true);
    }
}

module draw_mounting_holes() {
    // two mounting holes, one cylinder
    translate([0, mnt_scr_case_y_off, mnt_scr_z_off])
    rotate([0, 90, 0])
    cylinder(d=scr_d, h=case_w);

    // bottom mounting holes
    translate([case_t + mnt_scr_off, mnt_scr_case_y_off, 0])
        reg_screwhole();
    translate([case_t + mnt_scr_off + bott_hole_dist, mnt_scr_case_y_off, 0])
        reg_screwhole();
}

/* test slices */

module draw_test_case() {
    difference() {
        case_main();

        draw_switch_holes();
        draw_wire_holes();
    }

    if(sw_hole_is_rect) {
        draw_switch_frame_rect();
    }
    else {
        draw_switch_frame_six_sides();
    }
}

// test side length
module side_test_slice() {
    difference() {
        draw_case();

        translate([sw_frame_x_off + 1, -err, -err])
        scale([1, 1.1, 1.1])
            case_stock();
    }
}

// test front width
module front_test_slice() {
    difference() {
        draw_test_case();

        color("red")
        translate([0, slice_t, 0])
            case_stock();
    }
}

// test switch hole
module top_test_slice() {
    difference() {
        draw_test_case();

        color("orange")
        translate([0, 0, -slice_t])
            scale([1, 1, 1])
            case_stock();
    }
}

/* drawing */

module draw_test_side() {
    translate([case_h, 0, 0])
    rotate([0, 270, 0])
    color("red")
    side_test_slice();
}

module draw_test_front() {
    translate([case_w/2, case_h, 0])
    rotate([90, 0, 0])
    color("green")
    front_test_slice();
}

module draw_test_top() {
    translate([case_w/2, case_h + 5, case_h]) // - thickness/2])
    mirror([0, 0, 1])
    color("blue")
    top_test_slice();
}

module draw_case() {
    difference() {
        case_main();

        if(vent_type != "none") {
            draw_vents();
        }
        draw_switch_holes();
        //draw_wire_holes();
        draw_mounting_holes();
    }

    if(sw_hole_is_rect) {
        draw_switch_frame_rect();
    }
    else {
        draw_switch_frame_six_sides();
    }
}

/* here we go */

if(draw_test_front) {
    draw_test_front();
}

if(draw_test_side) {
    draw_test_side();
}

if(draw_test_top) {
    draw_test_top();
}

if(draw_case) {
    rotate([90, 0, 0])
    draw_case();
}

/* included  */

module round_all_vertices(off) {
    // rounds all inside and outside vertices of a polygon
    // see https://en.wikibooks.org/w/index.php?title=OpenSCAD_User_Manual/Tips_and_Tricks#Rounding_polygons
    // preserves polygon dimensions
    // call with:
    //
    // round_all_vertices(off=x) {
    //   polygon(points);
    // }
    //
    // off = "rounding" coefficient -- adjust as needed

   $fn = 24;

   offset(-off) offset(off)
   offset(off) offset(-off)
   children();
}

/*

NOTES

*/

echo("wiring end length: ", wiring_end_l, "power supply end length: ", ps_end_l);
echo("total case length: ", case_l);
