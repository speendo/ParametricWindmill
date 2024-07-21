size = 100;
numberOfLeafs = 4; // [3:1:20]
stroke = 0.8;

thickness = 0.4;
textThickness = 0.2;

switchDirection = false;

imprint = "MARCEL";
font = "DejaVu Sans:style=Bold";
fontSize = 5;
textOffset = 0;
textRotation = 90;
extraTextRotation = 0;

bearingInnerDiameter = 5;
bearingOuterDiameter = 17;
bearingHeight = 8;
bearingWallWidth = 1;

nutDiameter = 24;

foldCut = 3;

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
        leafPart(addToRad = stroke, rot = 360 / numLeafs());
    }
}

module oneLeafWithCutouts() {
!    linear_extrude(height = thickness) {
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
        printedbearing(bearingInnerDiameter,bearingOuterDiameter,bearingHeight, bearingWallWidth);
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

makeWindmillWithScrew();
//oneLeafWithCutouts();