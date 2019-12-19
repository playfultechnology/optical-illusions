/* Creates a series of blocks that are each shaped like two different letters
   when viewed from two orthogonal viewpoints.
   This script is licensed under the Creative Commons - Attribution - Share Alike license. 
   Original script by Lyl3, modified by AlastairA
*/

/* [Parameters] */
// Letters on left side (USE ONLY UPPERCASE LETTERS!)
string_1 = str("HERO");
// Letters on right side (USE ONLY UPPERCASE LETTERS!)
string_2 = str("8390");
// Scale of letters (1 = letters 20 mm tall and spaced 22.2 mm apart if spacing is set to 0% below )
letterScaling = 1.0; // [0.5:0.1:10.0]
// Additional spacing between letters (% of letter width, none needed, can be negative)
letterSpacing = 0.0; // [-10.0:0.1:30.0]
// Height of base plinth (mm)
padHeight = 1.0; // [0.0:0.1:30.0]

fontName = "Overpass Mono:style=Bold";      // Also try fontName = "Liberation Mono:style=Bold";
fontSize = 18;                              // ensure extents of letters don't get clipped
letterWidth = 18.4;                         // enough space for the W
blockHeight = 21.37;                        // required height for chosen font size, could be larger
blockSize = 18.5;                           // big enough for letter width with minimal spacing
letterSpace = letterWidth*(0.9+(letterSpacing/100)); // 10% closer + what user selects 
padWidth = sqrt(2*blockSize*blockSize);     // hypotenuse of the block sides
myScale = letterScaling * 20 / blockHeight; // adjust scaling so that selected scale is based on nice even number
adjustedPadHeight = padHeight / myScale;    // adjust pad height before being scaled with the letters
minWidth = 1.2;                             // width of block for a space character

// Chr function used to add special characters
specialCharacters = chr([36, 60, 62, 9829, 9824, 9830, 9827, 9834, 9835, 8592, 8594, 960]);
// echo("Special characters:", specialCharacters);  // Uncomment to see what the characters are
// Scaling and positioning for special characters is set based on
// fontName = "Overpass Mono:style=Bold", fontSize = 22
scales = [0.81, 1.8, 1.8, 1.175, 1.05, 1.175, 1.05, 1.05, 0.88, 2.1, 2.1, 1.5];
shifts = [-2.0, 9, 9, 2.5, 0, 2.5, 0, 1.0, -2.7, 12.5, 12.5, 0]; 

// Create a block from a letter pair
module doubleLetterBlock (letter1, letter2) {
  // Create scale/shift factors for each letter
  pos1 = search(letter1,specialCharacters)[0]; // Check if the "letter" is a special character
  scale1 = pos1==undef ? 1 : scales[pos1];     // Default scaling of 1 unless it's special
  shift1 = pos1==undef ? 0 : shifts[pos1];     // Default shifting of 0 unless it's special
  pos2 = search(letter2,specialCharacters)[0]; // Do the same for the other letter
  scale2 = pos2==undef ? 1 : scales[pos2];
  shift2 = pos2==undef ? 0 : shifts[pos2];

  intersection() {
    // Start with a full block
    cube([blockSize,blockHeight,blockSize]);
    // Create intersection with first letter
    if (letter1 != " " && letter1 != undef)
      translate([0,-shift1,0]) scale([1,scale1,1])  // scale it and shift it if special character
        linear_extrude(blockSize) text (letter1, size=fontSize, font=fontName);
    else
      translate ([(blockSize-minWidth)/2,0,0]) cube([minWidth,blockHeight,blockSize]);
    // Create intersection with second letter
    if (letter2 != " " && letter2 != undef)
      translate ([0,0,letterWidth]) rotate([0,90,0]) // move it to orthogonally into position
      translate([0,-shift2,0]) scale([1,scale2,1])   // scale it and shift it if special character
        linear_extrude(blockSize) text (letter2, size=fontSize, font=fontName);
    else
      translate ([0,0,letterWidth]) rotate([0,90,0])
        translate ([(blockSize-minWidth)/2,0,0]) cube([minWidth,blockHeight,blockSize]);  
  }
}

module doubleLetterString(string1, string2) {
  stringLength = max(len(string1),len(string2));
  translate([-sqrt(2*letterSpace*letterSpace)*(stringLength-1)/2,padWidth/2,0]) rotate ([0,0,-45])
    union() {
      translate ([0,0,adjustedPadHeight]) rotate ([90,0,0])
      for (i = [0:stringLength-1]) {
        translate ([i*letterSpace,0, -i*letterSpace]) 
          doubleLetterBlock(string1[i], string2[i]);
      }
      // Create a base for the letters
      translate ([letterWidth/2,-letterWidth/2,0])
        linear_extrude (adjustedPadHeight) hull() {
          translate([letterSpace*(stringLength-1),letterSpace*(stringLength-1),0]) circle(d=padWidth);
          circle(d=padWidth);
        }
   }
}

// Create the block
scale([myScale, myScale, myScale]) doubleLetterString (string_1, string_2);