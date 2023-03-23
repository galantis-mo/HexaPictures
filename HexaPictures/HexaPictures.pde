/**
 * HexaPictures.pde
 * Pixelisation of pictures into hexagons.
 * Inspired from a test in the module X22I050 at Nantes University.
 * @author Monique RIMBERT (monique.rimbert@etu.univ-nantes.fr)
 *
 *  KEYBOARD CONTROLS :
 *  k  -> Saves the current frame.
 *  UP -> Increase the size of hexagones by 5 pixels;
 *  DOWN -> Decrease the size of hexagones by 5 pixels, unless if it is already at 5 pixels.
 */
 
//-------------------USERS-VARIABLES--------------------
PImage PICTURE = loadImage("https://i.imgur.com/NgWjF0R.jpg");  //Credits : @megane_wakui (https://www.flickr.com/photos/megane_wakui)

//User's screen resolution * a percentage less than 100%
int SCREEN_WIDTH_MAX  = floor(1920*0.75);  
int SCREEN_HEIGHT_MAX = floor(1080*0.75);

//-------------------GLOBAL-VARIABLES--------------------
float HEXAGONE_SIDE = 5;

//cos(a) = adjacent / hypotenuse
float INTERVAL_X = 2.0 * cos(PI/6.0) * HEXAGONE_SIDE;  
float INTERVAL_Y = 1.5 * HEXAGONE_SIDE;

//-------------------------------------------------------
/**
 * settings()
 * Allows us to set the size of the window with variables.
 */
void settings() {
  //println(PICTURE.width + "x" + PICTURE.height);
  
  // If the picture width is greater than the maximum width allowed and the picture is in a landscape orientation. 
  if (PICTURE.width > SCREEN_WIDTH_MAX && PICTURE.width > PICTURE.height) {
    size(SCREEN_WIDTH_MAX, PICTURE.height*SCREEN_WIDTH_MAX/PICTURE.width);
    
  } 
  // Else if the picture height is greater than the maximum height allowed and the picture is in a portrait orientation. 
  else if (PICTURE.height > SCREEN_HEIGHT_MAX && PICTURE.height >= PICTURE.width) {
    size(PICTURE.width*SCREEN_HEIGHT_MAX/PICTURE.height, SCREEN_HEIGHT_MAX);
    
  } 
  // Else, the picture size is within the interval allowed.
  else {
    size(PICTURE.width, PICTURE.height);
  }
}

/**
 * setup()
 * Defines the initial environment.
 */
void setup() {
  colorMode(RGB, 255);
}

//-------------------------------------------------
/**
 * Transforms polar coordinates into cartesian coordinates.
 * @param centre The cartesian coordinates of the circle.
 * @param radius The radius of the circle in pixels. 
 * @param angle  An angle in radians.
 */
PVector pol2Cart(PVector centre, float radius, float angle) {
  return new PVector(centre.x + radius*cos(angle), centre.y + radius*sin(angle));
}
 
//-------------------------------------------------
/**
 * @param ima       The image where the color is taken from. The image must have been load beforehand.
 * @param percentX  Horizontal position in the picture using percentages.
 * @param percentY  Vertical position in the picture using percentages.
 * @returns the color of the pixel situated at the position indicated by the percentages.
 */
color getColorPixelPercent(PImage ima, float percentX, float percentY) {
  int column = (int)(ima.width * percentX); 
  int row = (int)(ima.height * percentY);
  
  color colPix = ima.pixels[((row*ima.width) + column) % ima.pixels.length]; //Takes the last color in case the (row*ima.width) + column) is greater than the number of pixels in the picture.
  return colPix;
}

//-------------------------------------------------
/**
 * Draws an hexagone in the color choosen.
 * @param centre    The caretsian coordinate of the centre of the hexagone.
 * @param side      The size of one side of the hexagone.
 * @param fillColor The color of the inside of the hexagone.
 */
void dessineHexagone(PVector centre, float side, color fillColor) {
  strokeWeight(1);  
  //stroke(128, 128, 128, 128); //A thin grey line of 1px with an opacity half opaque.
  stroke(fillColor);
  
  fill(fillColor);  //The filling color of the hexagone.

  beginShape();
  for (int i = 0; i < 6; i++) {
    /* 
      At each iteration, we calculate the coordinate of the i-th corner, 
      knowing that the first angle equals 30° or pi/6 rads. After which,
      we need to add i times 60° (PI/3 rads).
    */
    float stepAngle = PI/6.0 + PI*(float)i/3.0;
    
    PVector p = pol2Cart(centre, side, stepAngle);
    vertex(p.x, p.y);
  }
  endShape(CLOSE);
}

//-------------------------------------------------
/**
 * Determine the coordinate of the centre of an hexagone by its position on the grid.
 * @param i Its column on the grid.
 * @param j Its row on the grid.
 * @return a new PVector with the cartesian coords of the center.
 */
PVector centreIJ(int i, int j) {
  float x = (float)i * INTERVAL_X;
  float y = (float)j * INTERVAL_Y;
  
  /*
    We can see that when we are at odd rows, the centerX of the hexagone are in between two hexagones of the rows above and under it.
    This small gap is equal to half of INTERVAL_X.
  */
  x += (j%2 != 0)? INTERVAL_X/2 : 0; 
  
  return new PVector(x, y);
}

//-------------------------------------------------
/**
 * Pixelise an image using hexagones.
 * @param ima The picture that will be pixalised. It must have been loaded beforehand.
 */
void pixelisationHexagone(PImage ima) {
  int nbColumns = ceil(width / INTERVAL_X);
  int nbRows    = ceil(height / INTERVAL_Y);
  
  for (int i = 0; i <= nbColumns; i++) {
    for (int j = 0; j <= nbRows; j++) {
      PVector centreHexa = centreIJ(i, j);  //The cartesian coordinates of the hexagone.
      
      /*
        The two following lines controls if the center of the hexagone is outside of the window.
        If it is, we take the the closest pixel within the window.
      */
      int xColor = (int)centreHexa.x % width;
      int yColor = (int)centreHexa.y % height;
            
      color fillHexa = getColorPixelPercent(ima, xColor/(float)(width), yColor/(float)(height));
      
      dessineHexagone(centreHexa, HEXAGONE_SIDE, fillHexa);
    }
  }
}

//-------------------------------------------------
/**
 * Function executed everytime a key is pressed. 
 *
 *  KEYBOARD CONTROLS :
 *  k  -> Saves the current frame.
 *  UP -> Increase the size of hexagones by 5 pixels;
 *  DOWN -> Decrease the size of hexagones by 5 pixels, unless if it is already at 5 pixels.
 */
void keyPressed() {
  switch(key) {
    case 'k':
      saveFrame("SavedFrames/HexaPictures-######.png");
      println("Frame saved!");
      break;
      
    case CODED:
      switch(keyCode) {
        case UP:
          HEXAGONE_SIDE += 5;
          break;
          
        case DOWN:
          HEXAGONE_SIDE -= (HEXAGONE_SIDE-5<5)? 0 : 5;
          break;
      }
      
      //Udpates the interval according to the new size of the hexagone.
      INTERVAL_X = 2.0 * cos(PI/6.0) * HEXAGONE_SIDE;
      INTERVAL_Y = 1.5 * HEXAGONE_SIDE;
      break;
  }
}

//-------------------------------------------------
/**
 * The drawing function that is in loop.
 */
void draw() {
  background(0);  //A black background.
  pixelisationHexagone(PICTURE);
}
