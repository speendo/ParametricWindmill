part = "W"; // [W:Windmill, T:Text]

size = 200; // [50:0.1:400]
gap = 0.8; // [0.05:0.01:1]

thickness = 0.25; // [0.05:0.01:1]
textThickness = 0.25; // [0.05:0.01:1]

stickDiameter = 6; // [2.5:0.01:10]
wallThickness = 2; // [1:0.1:4]

switchDirection = false;

imprint = "YourText";
font = "DejaVu Sans:style=Bold";
fontSize = 20; // [5:0.5:50]
textPosition = "F"; // [F:First Layer, L:Last Layer, A:All Layers]
readFrom = "B"; // ["B":Bottom, "T":Top]
textRotation = 0; // [0:1:360]
mirrorText = true;

bearingInnerDiameter = 10;
bearingOuterDiameter = 26;
bearingHeight = 8;
bearingWallWidth = 1.07;
bearingGap = 0.27; // [0.05:0.01:1]
bearingBottomRingHeight = 0.0; // [0.05:0.01:0.5]

snapDiameter = 8;
snapWall = 3.5;
snapOffset = 8;

resolution = 100;

/* [Hidden]*/

debugJustOne = false;
debugNoBearing = false;

increment = 0.00001;

$fn = resolution;

use <printedbearing.scad>;

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

function curLetter(i, maxIt) = switchDirection ? imprint[maxIt - 1 - i] : imprint[i];

rad = size / 4;
rot = 360 / numLeafs();
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
    finalThickness = part == "T" ? textPosition == "A" ? thickness : textThickness : embossThickness;
    
    textPos = part == "T" ? 0 : textPosition == "A" ? -1 : textPosition == "F" ? -1 : textPosition == "L" ? thickness - textThickness : 0;
    
    initTextRot = readFrom == "B" ? 90 : readFrom == "T" ? -90 : 90;
    
    translate([0, 0, textPos]) {
        linear_extrude(height = finalThickness) {
            rotation = (direction() * 0.5* rot);
            rotate(rotation) {
            translate([(direction() * size ) /4 , rad]) {
                    rotate(direction() * (initTextRot + textRotation)) {
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

module allLeafsWithEmboss() {
    maxIt = debugJustOne ? 1 : numLeafs();
    for (i = [0:maxIt-1]) {
        rotate(-i * rot) {
            oneLeafWithEmboss(curLetter(i, maxIt));
        }
    }
}

module allText() {
    maxIt = debugJustOne ? 1 : numLeafs();
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

module connector() {
    union() {
        cylinder(d = bearingInnerDiameter + increment, h = bearingHeight);
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