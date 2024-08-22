/* [Main Settings] */

// Text (controls # of leaves)
imprint = "YourText";


// Which part to generate
part = "W"; // [W:Windmill, T:Text, A:All, B:Bearing, L:First Leaf]

// Total Diameter
size = 200; // [50:0.1:400]

// Diameter of the holding stick
stickDiameter = 6; // [2.5:0.01:10]

orientation = "V"; // [V:Vertical, H:Horizontal]

/* [Text Settings] */
// Selected Font
font = "DejaVu Sans:style=Bold";
// Font Size
fontSize = 20; // [5:0.5:50]
// First Layer (inside of leaves), Last layer (outside of leaves), All Layers (inside and outside)
textPosition = "A"; // [F:First Layer, L:Last Layer, A:All Layers]
// When Blowing the Windmill, Correct Letter order on Top or Bottom
readFrom = "T"; // ["B":Bottom, "T":Top]
textRotation = 0; // [0:1:360]
// Mirror Text to Read from inside
mirrorText = true;
// Text Thickness (<= than Leaf Thickness)
textThickness = 0.3; // [0.05:0.01:1]

/* [Leaf Settings] */
// Gap between Leaves
gap = 0.6; // [0.05:0.01:1]

// Leave Thickness
thickness = 0.3; // [0.05:0.01:1]

// Leaves Facing Left or Right
switchDirection = false;

/* [Connector Settings] */
// Connector Circle Diameter
snapDiameter = 7; // [1:0.01:10]

// Wall Thickness where the Connector Ring ends on the leaf
snapWall = 3.5;

// Offset from the Leaf Tip to the Connector Ring Center
snapOffset = 8;

/* [Bearing Settings] */
// Inner Diameter (advanced)
bearingInnerDiameter = 10; // [3:0.1:20]
//Outer Diameter (advanced)
bearingOuterDiameter = 26; // [6:0.1:40]
// Bearing Height (advanced)
bearingHeight = 8; // [4:0.1:15]
// Bearing Wall Width
bearingWallWidth = 1.08; // [0.5:0.01:3]
// Gap between Bearing "balls" and wall
bearingGap = 0.2; // [0.05:0.001:1]
// A ring on the build plate reduces the risk of "balls" detaching from the build plate during printing. leave at zero for no ring.
bearingBottomRingHeight = 0.0; // [0.00:0.01:0.5]
invertedRollers = true;

/* [Other Settings] */
// Wall Thickness surrounding holding stick
wallThickness = 2; // [1:0.1:4]

resolution = 100;


/* [Hidden]*/

debugJustOne = false;
debugNoBearing = false;

increment = 0.00001;

$fn = resolution;

function numLeaves() = len(imprint);

function direction() = switchDirection ? -1 : 1;

function cutOutCircleCenter(radius, angle) = [-direction() * radius * sin(angle), radius * cos(angle)];

function circleIntersectionC(P1, P2) = sqrt(pow(P2[0] - P1[0], 2) + pow(P2[1] - P1[1], 2));

function circleIntersectionX(P1, r1, P2, r2) = (pow(r1, 2) - pow(r2, 2) + pow(circleIntersectionC(P1, P2), 2)) / (2 * circleIntersectionC(P1, P2));

function circleIntersectionY(P1, r1, P2, r2) = sqrt(pow(r1, 2) - pow(circleIntersectionX(P1, r1, P2, r2), 2));

function Q1(P1, r1, P2, r2) = [P1[0] + circleIntersectionX(P1, r1, P2, r2) * (P2[0] - P1[0]) / circleIntersectionC(P1, P2) - circleIntersectionY(P1, r1, P2, r2) * (P2[1] - P1[1]) / circleIntersectionC(P1, P2), P1[1] + circleIntersectionX(P1, r1, P2, r2) * (P2[1] - P1[1]) / circleIntersectionC(P1, P2) + circleIntersectionY(P1, r1, P2, r2) * (P2[0] - P1[0]) / circleIntersectionC(P1, P2)];

function Q2(P1, r1, P2, r2) = [P1[0] + circleIntersectionX(P1, r1, P2, r2) * (P2[0] - P1[0]) / circleIntersectionC(P1, P2) + circleIntersectionY(P1, r1, P2, r2) * (P2[1] - P1[1]) / circleIntersectionC(P1, P2), P1[1] + circleIntersectionX(P1, r1, P2, r2) * (P2[1] - P1[1]) / circleIntersectionC(P1, P2) - circleIntersectionY(P1, r1, P2, r2) * (P2[0] - P1[0]) / circleIntersectionC(P1, P2)];

function calcAngle(P1, P2) = 
    let (
        x = P2[0] - P1[0],
        y = P2[1] - P1[1],
        theta = atan2(y, x)
    )
    theta;

function curLetter(i, maxIt) = switchDirection ? imprint[maxIt - 1 - i] : imprint[i];

rad = size / 4;
rot = 360 / numLeaves();
P1 = [0, rad];
P2 = cutOutCircleCenter(rad, rot);
Q1 = Q1(P1, rad, P2, rad + gap);
Q2 = Q2(P1, rad, P2, rad + gap);

higherQ = Q1[1] >= Q2[1] ? Q1 : Q2;

snapQ1 = Q1(P1, rad, P2, rad + gap + snapWall);
snapQ2 = Q2(P1, rad, P2, rad + gap + snapWall);

higherSnapQ = snapQ1[1] >= snapQ2[1] ? snapQ1 : snapQ2;

snapCenterQ1 = Q1(P2, rad + gap + snapWall, higherSnapQ, snapOffset + snapDiameter / 2);
snapCenterQ2 = Q2(P2, rad + gap + snapWall, higherSnapQ, snapOffset + snapDiameter / 2);

snapCenter = snapCenterQ1[1] <= snapCenterQ2[1] ? snapCenterQ1 : snapCenterQ2;

snapTouchQ1 = Q1(P2, rad + gap, snapCenter, snapDiameter / 2 + increment);
snapTouchQ2 = Q2(P2, rad + gap, snapCenter, snapDiameter / 2 + increment);

lowerSnapTouch = snapTouchQ1[1] <= snapTouchQ2[1] ? snapTouchQ1 : snapTouchQ2;

module drawCircle(P = [0,0], d = -1, r = 0.5) {
    d = d == -1 ? 2 * r : d;
    translate(P) {
        circle(d = d);
    }
}

module oneLeaf() {
    difference() {
        drawCircle(P = P1, r = rad);
        drawCircle(P = P2, r = rad + gap);
    }
}

module oneLeafWithCutouts() {
    cutOutGap = max(2 * thickness, gap);
    linear_extrude(height = thickness) {
        difference() {
            oneLeaf();
            difference() {
                drawCircle(P = snapCenter, d = snapDiameter + 2 * cutOutGap);
                drawCircle(P = snapCenter, d = snapDiameter);
                difference() {
                    drawCircle(P = P2, r = rad + gap + snapWall);
                    translate([lowerSnapTouch[0], snapCenter[1] - snapDiameter / 2 - 1]) {
                       square(snapDiameter + 2* cutOutGap + 2, center = false);
                    }
                }
            }
        }
    }
}

module leafText(letters) {
    embossThickness = textPosition == "A" ? thickness + 2 : textThickness + 1;
    finalThickness = part == "T" || part == "A" || part == "L" ? textPosition == "A" ? thickness : textThickness : embossThickness;
    
    textPos = part == "T" || part == "A" || part == "L" ? 0 : textPosition == "A" ? -1 : textPosition == "F" ? -1 : textPosition == "L" ? thickness - textThickness : 0;
    
    initTextRot = readFrom == "B" ? 90 : readFrom == "T" ? -90 : 90;
    
    orientationTextRot = orientation == "V" ? 0 : 90;
    
    translate([0, 0, textPos]) {
        linear_extrude(height = finalThickness) {
            rotation = (direction() * 0.5* rot);
            rotate(rotation) {
            translate([(direction() * size ) /4 , rad]) {
                    rotate(direction() * (initTextRot + textRotation + orientationTextRot)) {
                        mirror([mirrorText ? 1 : 0, 0]) {
                            text(letters, font = font, size = fontSize, halign="center", valign="center");
                        }
                    }
                }
            }
        }
    }
}

module oneLeafWithEmboss(letters) {
    difference() {
        oneLeafWithCutouts();
        leafText(letters);
    }
}

module allLeavesWithEmboss() {
    maxIt = debugJustOne ? 1 : numLeaves();
    for (i = [0:maxIt-1]) {
        rotate(-i * rot) {
            oneLeafWithEmboss(curLetter(i, maxIt));
        }
    }
}

module allText() {
    maxIt = debugJustOne ? 1 : numLeaves();
    for (i = [0:maxIt-1]) {
        rotate(-i * rot) {
            leafText(curLetter(i, maxIt));
        }
    }
}

module bearingDummy() {
    translate([0,0,-1]) {
        cylinder(d = bearingOuterDiameter - increment, h = bearingHeight + 2);
    }
}

module connectorV() {
    union() {
        cylinder(d = bearingInnerDiameter + increment, h = bearingHeight);
        translate([0, 0, bearingHeight]) {
            difference() {
                cylinder(h = 2 * wallThickness + stickDiameter, d = invertedRollers?  bearingInnerDiameter + 2 * bearingWallWidth : bearingInnerDiameter + 4 * bearingWallWidth);
                translate([-(bearingInnerDiameter / 2 + 2 * bearingWallWidth), 0, wallThickness + stickDiameter / 2]) {
                    rotate([0, 90, 0]) {
                        cylinder(h = bearingInnerDiameter + 4 * bearingWallWidth + 2, d = stickDiameter);
                    }
                }
            }
        }
    }
}

module connectorH() {
    difference() {
        union() {
            cylinder(d = bearingInnerDiameter + increment, h = bearingHeight);
            translate([0, 0, bearingHeight]) {
                cylinder(h = wallThickness + stickDiameter, d = invertedRollers?  bearingInnerDiameter + 2 * bearingWallWidth : bearingInnerDiameter + 4 * bearingWallWidth);
            }
        }
        translate([0, 0, -1]) {
            cylinder(d = stickDiameter, h = bearingHeight + wallThickness + stickDiameter + 2);
        }
    }
}

module makeWindmill() {
    union() {
        difference() {
            allLeavesWithEmboss();
            if (!debugNoBearing) bearingDummy();
        }
        if (!debugNoBearing) {
            makeConnector();    
        }
    }
}

module makeConnector() {
    union() {
        printedbearing(bearingInnerDiameter,bearingOuterDiameter,bearingHeight, bearingWallWidth, bearingGap, bearingBottomRingHeight, invertedRollers);
        if (orientation == "V") {
            connectorV();
        } else {
            connectorH();
        }
    }
}

module select() {
    if (part == "W" || part == "A") {
        color("green") {
            makeWindmill();
        }
    }
    if (part == "T" || part == "A") {
        color("red") {
            allText();
        }
    }
    if (part == "B") {
        makeConnector();
    }
    if (part == "L") {
        oneLeafWithEmboss(curLetter(0, 1));
    }
}

select();


//* Libraries *//

//* printedbearing.scad *//

// Modified for
// (1) gap as parameter
// (2) bottom ring height as parameter
// (3) inverted rollers

// Printed Bearing
// by Radus 2018
// http://vk.com/linuxbashev

// remixed by Marcel Jira 2024

// Parameters

// Inner (hole) diameter
diameter_in=8;   // [0:0.1:200]

// Outer diameter
diameter_out=22; // [0:0.1:150]

// Bearing height
height=7;        // [0:0.1:50]

// Wall thickness
wall_width=0.79; // [0:0.001:3]

// Gap between rollers and walls
roller_gap=0.14; // [0:0.001:1]

// When > 0, the rollers are connected with a ring - this improves printability but the ring needs to be removed after printing
bottom_ring_height=0.0; // [0:0.001:0.5]

// set false for original design by Radus
inverted_roller=true;

// printedbearing(diameter_in, diameter_out, height, wall_width, roller_gap, bottom_ring_height, inverted_roller);  // 608

// New Examples
//printedbearing(8, 22, 7, 1.07, 0.14, 0, true); // 608 bearing for fast speed & low load
//printedbearing(8, 22, 7, 0.82, 0.14, 0, true); // 608 bearing for low speed & high load
//printedbearing(10, 26, 8, 1.07, 0.14, 0, true); // 6000 bearing for fast speed & low load
//printedbearing(10, 26, 8, 0.82, 0.14, 0, true); // 6000 bearing for low speed & high load
//printedbearing(10, 26, 8, 0.86, 0.14, 0, true); // 6000 bearing for low speed & high load
//printedbearing(10, 26, 8, 1.08, 0.2, 0, true); // 6000 bearing - balanced and easy to print

// Old Examples
//translate([0,0,0])  printedbearing(3,10,4, 0.52);  // 623
//translate([20,0,0]) printedbearing(4,13,5, 0.65);  // 624
//translate([-20,0,0]) printedbearing(5,16,5, 0.81); // 625
//translate([0,20,0]) printedbearing(6,19,6, 0.76);  // 626
//translate([0,-20,0]) printedbearing(7,22,7, 0.83); // 627
//translate([25,25,0]) printedbearing(8,24,8, 0.79);   // 628
//translate([25,-25,0]) printedbearing(8,22,7, 0.79);  // 608
//translate([-25,-25,0]) printedbearing(9,26,8, 1.11); // 629
//translate([-25,25,0]) printedbearing(10,26,8, 1.07); // 6000
//translate([0,0,0]) printedbearing(20,42,12, 1.64); // 6004
//translate([0,0,0]) printedbearing(100,150,24, 2.06); // 6020


function catb(cata,catang)=cata/cos(catang)*sin(catang);

module printedbearing(pdi=8, pdo=22, ph=7, pw=1, rg=0.15, brh=0.15, inr=false){

do=pdo;
di=pdi;
h=ph;
w2=pw;
w1=w2;

zz=rg;             // gap between two rollers and rollers and base

dr=do/2-di/2-w1*2-w2*2-zz*2;

h2=catb(w1,45);     // angle inside rollers
//h3=(dr-h2*2)/1.5;
//h1=(h-h3-h2*2)/2;
h1=w1;
h3=h-h1*2-h2*2;

rollerLineCircumf = PI * (do + di) / 2;
virtRollerCountNoGap = rollerLineCircumf / (dr + 2 * w1);
virtRollerCountWGap = rollerLineCircumf / (dr + 2 * w1 + zz);

n = floor(virtRollerCountWGap);

maxGap = rollerLineCircumf - n * (dr + 2 * w1);
maxGapShare =  round(1000 * (maxGap / (dr + 2 * w1))) / 1000;

avgGap = (rollerLineCircumf - n * (dr + 2 * w1)) / n;
avgGapShare =  round(1000 * (avgGap / (dr + 2 * w1))) / 1000;


sph=brh;
spw=0.6;
$fn=64;

echo("");
echo("=== Bearing Data ===");
echo(str("Number of rollers: ", n));
echo(str("Roller size: ", dr + 2 * w1));
echo(str("Biggest possible gap: ", maxGap));
echo(str("Biggest Gap Share: ", 100 * maxGapShare, " % of a complete roller"));
echo(str("Average gap: ", avgGap));
echo(str("Average Gap Share: ", 100 * avgGapShare, " % of a complete roller"));
echo("=== End Bearing Data ===");
echo("");

module bout(){
difference(){
    union(){
        translate([0,0,h/2]) cylinder(h,do/2,do/2,true);
    } // un
    
    if (inr) {
        union() {
            translate([0,0,h1/2-1/2]) cylinder(h1+1.0001,do/2-w2,do/2-w2,true);
            translate([0,0,h1+h2/2]) cylinder(h2,do/2-w2,do/2-w2-w1,true);
            translate([0,0,h1+h2+h3/2]) cylinder(h3+0.02,do/2-w1-w2,do/2-w1-w2,true);
            translate([0,0,h1+h2+h3+h2/2]) cylinder(h2,do/2-w1-w2,do/2-w2,true);
            translate([0,0,h1+h2+h3+h2+h1/2+1/2]) cylinder(h1+1.0001,do/2-w2,do/2-w2,true);
        }
    } else {
        union() {
            translate([0,0,h1/2-1/2]) cylinder(h1+1.1,do/2-w1-w2,do/2-w1-w2,true);
            translate([0,0,h1+h2/2]) cylinder(h2,do/2-w1-w2,do/2-w2,true);
            translate([0,0,h1+h2+h3/2]) cylinder(h3+0.02,do/2-w2,do/2-w2,true);
            translate([0,0,h1+h2+h3+h2/2]) cylinder(h2,do/2-w2,do/2-w2-w1,true);
            translate([0,0,h1+h2+h3+h2+h1/2+1/2]) cylinder(h1+1.1,do/2-w2-w1,do/2-w2-w1,true);
        }
    }
} // df
} // mod

module bin(){
difference(){
    if (inr) {
        union() {
            translate([0,0,h1/2]) cylinder(h1,di/2+w2,di/2+w2,true);
            translate([0,0,h1+h2/2]) cylinder(h2,di/2+w2,di/2+w2+w1,true);
            translate([0,0,h1+h2+h3/2]) cylinder(h3,di/2+w2+w1,di/2+w2+w1,true);
            translate([0,0,h1+h2+h3+h2/2]) cylinder(h2,di/2+w2+w1,di/2+w2,true);
            translate([0,0,h1+h2+h3+h2+h1/2]) cylinder(h1,di/2+w2,di/2+w2,true);
        }
    } else {
        union(){
            translate([0,0,h1/2]) cylinder(h1,di/2+w2+w1,di/2+w2+w1,true);
            translate([0,0,h1+h2/2]) cylinder(h2,di/2+w2+w1,di/2+w2,true);
            translate([0,0,h1+h2+h3/2]) cylinder(h3,di/2+w2,di/2+w2,true);
            translate([0,0,h1+h2+h3+h2/2]) cylinder(h2,di/2+w2,di/2+w2+w1,true);
            translate([0,0,h1+h2+h3+h2+h1/2]) cylinder(h1,di/2+w2+w1,di/2+w2+w1,true);
        } // un
    }
        
    translate([0,0,h/2]) cylinder(h+1,di/2,di/2,true);
} // df
} // mod

module rol(){
if (inr) {
    union() {
        translate([0,0,h1/2]) cylinder(h1,dr/2+w1,dr/2+w1,true);
        translate([0,0,h1+h2/2]) cylinder(h2,dr/2+w1,dr/2,true);
        translate([0,0,h1+h2+h3/2]) cylinder(h3,dr/2,dr/2,true);
        translate([0,0,h1+h2+h3+h2/2]) cylinder(h2,dr/2,dr/2+w1,true);
        translate([0,0,h1+h2+h3+h2+h1/2]) cylinder(h1,dr/2+w1,dr/2+w1,true);
    }
} else {
    union(){
        translate([0,0,h1/2]) cylinder(h1,dr/2,dr/2,true);
        translate([0,0,h1+h2/2]) cylinder(h2,dr/2,dr/2+w1,true);
        translate([0,0,h1+h2+h3/2]) cylinder(h3,dr/2+w1,dr/2+w1,true);
        translate([0,0,h1+h2+h3+h2/2]) cylinder(h2,dr/2+w1,dr/2,true);
        translate([0,0,h1+h2+h3+h2+h1/2]) cylinder(h1,dr/2,dr/2,true);
    } // un
}
} // mod

module sp(){
difference(){
translate([0,0,sph/2]) cylinder(sph, di/2+(do/2-di/2)/2+spw/2, di/2+(do/2-di/2)/2+spw/2,true);
translate([0,0,sph/2]) cylinder(sph+1, di/2+(do/2-di/2)/2-spw/2, di/2+(do/2-di/2)/2-spw/2,true);
} // df
} // mod sp


difference(){
union(){
bout();
bin();
for (r=[0:n-1]) rotate([0,0,360/n*r])
translate([di/2+(do/2-di/2)/2,0,0]) rol();
if (brh > 0) {
    sp();
}
} //un
//cube([100,100,100]);
} // df

} // mod prinbe



