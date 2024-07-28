part = "W"; // [W:Windmill, T:Text]

size = 200;
gap = 0.6; // [0.05:0.01:1]

thickness = 0.3; // [0.05:0.01:1]
textThickness = 0.3; // [0.05:0.01:1]

stickDiameter = 5; // [2.5:0.01:10]
wallThickness = 2;

switchDirection = false;

imprint = "YourText";
font = "DejaVu Sans:style=Bold";
fontSize = 20;
textOffset = 0;
textRotation = 0;
extraTextRotation = 0;

bearingInnerDiameter = 7;
bearingOuterDiameter = 25;
bearingHeight = 5;
bearingWallWidth = 1;
bearingGap = 0.3; // [0.05:0.01:1]
bearingBottomRingHeight = 0.0; // [0.05:0.01:0.5]

centerOverlap = 7;
overlapAngle = 120;

resolution = 100;

/* [Hidden]*/

debugJustOne = false;
debugNoBearing = false;

$fn = resolution;

use <printedbearing.scad>;
use <slice.scad>;

function numLeafs() = len(imprint);

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


rad = size / 4;
rot = 360 / numLeafs();
P1 = [0, rad];
P2 = cutOutCircleCenter(rad, rot);
Q1 = Q1(P1, rad, P2, rad + gap);
Q2 = Q2(P1, rad, P2, rad + gap);

higherQ = Q1[1] >= Q2[1] ? Q1 : Q2;

QOv1 = Q1(P2, rad + gap, higherQ, 2 * centerOverlap);
QOv2 = Q2(P2, rad + gap, higherQ, 2 * centerOverlap);

lowerQOv = QOv1[1] <= QOv2[1] ? QOv1 : QOv2;

IOv1 = Q1(P2, rad + gap, lowerQOv, centerOverlap);
IOv2 = Q2(P2, rad + gap, lowerQOv, centerOverlap);

higherIOv = IOv1[1] >= IOv2[1] ? IOv1 : IOv2;

module drawCircle(P = [0,0], d = -1, r = 0.5) {
    d = d == -1 ? 2 * r : d;
    translate(P) {
        circle(d = d);
    }
}

module drawSlice(P = [0,0], r = 1, ang = 30, spin = 0) {
    translate(P) {
        slice(radius = r, angle = ang, spin = spin);
    }
}

module oneLeaf() {
    difference() {
        drawCircle(P = P1, r = rad);
        drawCircle(P = P2, r = rad + gap);
    }
}

module oneLeafWithCutouts() {
    linear_extrude(height = thickness) {
        difference() {
            oneLeaf();
            difference() {
                drawSlice(P = lowerQOv, r = centerOverlap, ang = overlapAngle + 1, spin = switchDirection ? calcAngle(lowerQOv, higherIOv) - 1 : calcAngle(lowerQOv, higherIOv) - overlapAngle);
                drawCircle(P = lowerQOv, r = centerOverlap - max(gap, 2 * thickness));
            }
        }
    }
}

module leafText(letters) {
    linear_extrude(height = textThickness) {
        rotation = (direction() * 0.5* rot);
        rotate(rotation) {
        translate([(direction() * size ) /4 , rad]) {
                rotate(textRotation) {
                    text(letters, font = font, size = fontSize, halign="center", valign="center");
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

module allLeafsWithEmboss() {
    maxIt = debugJustOne ? 1 : numLeafs();
    for (i = [0:maxIt-1]) {
        curLetter = imprint[i];
        rotate(-i * rot) {
            oneLeafWithEmboss(curLetter);
        }
    }
}

module allText() {
    maxIt = debugJustOne ? 1 : numLeafs();
    for (i = [0:maxIt-1]) {
        curLetter = imprint[i];
        rotate(-i * rot) {
            leafText(curLetter);
        }
    }
}

module bearingDummy() {
    translate([0,0,-1]) {
        cylinder(d = bearingOuterDiameter - 0.001, h = bearingHeight + 2);
    }
}

module connector() {
    union() {
        cylinder(d = bearingInnerDiameter + 0.001, h = bearingHeight);
        translate([0, 0, bearingHeight]) {
            difference() {
                cylinder(h = 2 * wallThickness + stickDiameter, d = bearingInnerDiameter + 4 * bearingWallWidth);
                translate([-(bearingInnerDiameter / 2 + 2 * bearingWallWidth), 0, wallThickness + stickDiameter / 2]) {
                    rotate([0, 90, 0]) {
                        cylinder(h = bearingInnerDiameter + 4 * bearingWallWidth + 2, d = stickDiameter);
                    }
                }
            }
        }
    }
}

module makeWindmill() {
    union() {
        difference() {
            allLeafsWithEmboss();
            if (!debugNoBearing) bearingDummy();
        }
        if (!debugNoBearing) {
            union() {
                printedbearing(bearingInnerDiameter,bearingOuterDiameter,bearingHeight, bearingWallWidth, bearingGap, bearingBottomRingHeight);
                connector();
            }
        }
    }
}

module select() {
    if (part == "W") {
        color("green") {
            makeWindmill();
        }
    } else if (part == "T") {
        color("red") {
            allText();
        }
    }

}

select();