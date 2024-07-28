part = "W"; // [W:Windmill, T:Text]

size = 200;
gap = 0.6; // [0.05:0.01:1]

thickness = 0.3; // [0.05:0.01:1]
textThickness = 0.15; // [0.05:0.01:1]

switchDirection = false;

imprint = "YourText";
font = "DejaVu Sans:style=Bold";
fontSize = 10;
textOffset = 0;
textRotation = 0;
extraTextRotation = 0;

bearingInnerDiameter = 5;
bearingOuterDiameter = 19;
bearingHeight = 5;
bearingWallWidth = 1;
bearingGap = 0.3; // [0.05:0.01:1]
bearingBottomRingHeight = 0.0; // [0.05:0.01:0.5]

foldCut = 5;

resolution = 100;

/* [Hidden]*/

debugJustOne = true;
debugNoBearing = true;

$fn = resolution;

use <printedbearing.scad>;
use <revolve2.scad>;

function numLeafs() = len(imprint);

function direction() = switchDirection ? -1 : 1;

function cutOutCircleCenter(radius, angle) = [-direction() * radius * sin(angle), radius * cos(angle)];

module leafPart(rad = size / 4, addToRad = 0, rot = 0) {
    translate(cutOutCircleCenter(size / 4, rot)) {
            circle(r = rad + addToRad);
    }
}

module oneLeaf() {
    difference() {
        leafPart();
        leafPart(addToRad = gap, rot = 360 / numLeafs());
    }
}

module oneLeafWithCutouts() {
    linear_extrude(height = thickness) {
        difference() {
            oneLeaf();
            difference() {
                leafPart(rad = size / 4 - 1);
                leafPart(rad = size / 4 - 1 -gap);
                
            }
        }
    }
}

module leafText(letters) {
    linear_extrude(height = textThickness) {
        rotation = (direction() * 0.5*360 / numLeafs());
        rotate(rotation) {
        translate([(direction() * size ) /4 , size / 4]) {
                rotate(textRotation) {
                    mirror([1,0,0]) {
                        text(letters, font = font, size = fontSize, halign="center", valign="center");
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
        curLetter = imprint[i];
        rotate(-i * (360 / numLeafs())) {
            oneLeafWithEmboss(curLetter);
        }
    }
}

module allText() {
    maxIt = debugJustOne ? 1 : numLeafs();
    for (i = maxIt) {
        curLetter = imprint[i];
        rotate(-i * (360 / numLeafs())) {
            leafText(curLetter);
        }
    }
}

module bearingDummy() {
    translate([0,0,-1]) {
        cylinder(d = bearingOuterDiameter - 0.001, h = bearingHeight + 2);
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
                cylinder(d = bearingInnerDiameter + 0.001, h = bearingHeight);
            }
        }
    }
}

module makeScrew() {
    difference() {
        translate([0,0,3 * thickness]) {
            cylinder(h = bearingHeight - 3 * thickness, d1 = bearingOuterDiameter, d2 = bearingOuterDiameter + 2 * (bearingHeight - 3 * thickness));
        }
        bearingDummy();
    }
}

module makeNut() {

}

module makeWindmillWithScrew() {
    union() {
        makeScrew();
        makeWindmill();
    }
}

module select() {
    if (part == "W") {
        color("green") {
            makeWindmillWithScrew();
        }
    } else if (part == "T") {
        color("red") {
            allText();
        }
    }

}

select();