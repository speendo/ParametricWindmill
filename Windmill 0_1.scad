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
textRotation = 90;
extraTextRotation = 0;

bearingInnerDiameter = 5;
bearingOuterDiameter = 19;
bearingHeight = 5;
bearingWallWidth = 1;
bearingGap = 0.4; // [0.05:0.01:1]
bearingBottomRingHeight = 0.0; // [0.05:0.01:0.5]

nutDiameter = 24;

foldCut = 3;

resolution = 100;

/* [Hidden]*/
$fn = resolution;

use <printedbearing.scad>;
use <revolve2.scad>;

function numLeafs() = len(imprint);

module leafPart(addToRad = 0, rot = 0) {
    rotate(switchDirection ? rot : -rot) {
        translate([0,size / 4]) {
            circle(r = ((size / 4) + addToRad));
        }
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
            translate([0,(size + bearingOuterDiameter + 2.1) / 2 - foldCut ]) {
                union() {
                    circle(d = bearingOuterDiameter + 2.1);
                    intersection() {
                        rotate(360 / numLeafs()) {
                            translate([0,-(size + bearingOuterDiameter + 2.1) / 2 + foldCut ]) {
                                leafPart();
                            }
                        }
                        circle(d = nutDiameter);
                    }
                }
            }
        }
    }
}

module leafText(letters) {
    linear_extrude(height = textThickness) {
        rotation = (180 / numLeafs() + extraTextRotation);
        rotate(switchDirection ? - rotation : rotation) {
            translate([0,size / 4 + textOffset]) {
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
    for (i = [0:numLeafs()-1]) {
        curLetter = imprint[i];
        rotate(-i * (360 / numLeafs())) {
            oneLeafWithEmboss(curLetter);
        }
    }
}

module allText() {
    for (i = [0:numLeafs()-1]) {
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
            bearingDummy();
        }
        union() {
            printedbearing(bearingInnerDiameter,bearingOuterDiameter,bearingHeight, bearingWallWidth, bearingGap, bearingBottomRingHeight);
            cylinder(d = bearingInnerDiameter + 0.001, h = bearingHeight);
        }
    }
}

module makeScrew() {
    difference() {
        union() {
            revolve(profile=[[0,bearingOuterDiameter / 2],[1,bearingOuterDiameter / 2 + 1],[2,bearingOuterDiameter / 2]], length=bearingHeight, nthreads=4, $fn=100);
            cylinder(h = 1.5 * thickness, d = bearingOuterDiameter + 2.1);
            cylinder(h = thickness, d = nutDiameter);
        }
        bearingDummy();
        translate([0,0,bearingHeight - 1]) {
            difference() {
                cylinder(h = 2, d = bearingOuterDiameter + 4);
                cylinder(h = 1, d1 = bearingOuterDiameter + 2, d2 = bearingOuterDiameter);
            }
        }
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