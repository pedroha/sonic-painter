Maxim maxim;
AudioPlayer player;
AudioPlayer player2;

int[] anchorPoints = new int[6];

int counter = 0;

void setup()
{
  size(640, 960);
  
  var suffix = "mp3";
  var ua = navigator.userAgent.toLowerCase();
  var isAndroid = ua.indexOf("android") > -1; //&& ua.indexOf("mobile");
  if(isAndroid) {
    suffix = "ogg";
  }
  // alert("Android? " + suffix);

  maxim = new Maxim(this);
  player2 = maxim.loadFile("abelmadrona__water-tunnel." + suffix);
  player2.setLooping(true);
  player = maxim.loadFile("erokia__elementary-synth-16-2." + suffix);
  player.setLooping(true);
  player.volume(0.25);
  background(0);
  rectMode(CENTER);
  
  anchorPoints[0] = 80;
  anchorPoints[1] = 75;
  anchorPoints[2] = 480;
  anchorPoints[3] = 280;
  anchorPoints[4] = 180;
  anchorPoints[5] = 40;
}

void draw()
{
  counter++;
  if (counter > 500) {
    for (int i = 0; i < anchorPoints.length; i++) {
      anchorPoints[i] = (int)random(height);
    }
    counter = 0;
  }
}

void mouseDragged()
{
  player.play();
  player2.play();
  float red = map(mouseX, 0, width, 0, 255);
  float blue = map(mouseY, 0, width, 0, 255);
  float green = dist(mouseX,mouseY,width/2,height/2);
  
  float speed = dist(pmouseX, pmouseY, mouseX, mouseY);
  float alpha = map(speed, 0, 20, 0, 10);
  //println(alpha);
  float lineWidth = map(speed, 0, 10, 10, 1);
  lineWidth = constrain(lineWidth, 0, 10);
  
  noStroke();
  fill(0, alpha);
  rect(width/2, height/2, width, height);
  
  stroke(red, green, blue, 255);
  
  quadbrush(pmouseX, pmouseY,mouseX, mouseY, lineWidth);
  //brokenLineBrush(pmouseX, pmouseY,mouseX, mouseY, lineWidth);
  
  reflectBrokenBrush(pmouseX, pmouseY,mouseX, mouseY, lineWidth);
  
  boolean curve = true;
  if (curve) {
    bezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[5], anchorPoints[5]);
    bezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[3], anchorPoints[4]);
    bezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[4], anchorPoints[3]);
    bezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[2], anchorPoints[4]);
    bezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[1], anchorPoints[5]);
  
    reflectBezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[0], anchorPoints[1]);
    reflectBezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[1], anchorPoints[2]);
    reflectBezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[2], anchorPoints[3]);
    reflectBezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[4], anchorPoints[5]);
    reflectBezier1(pmouseX, pmouseY,mouseX, mouseY, lineWidth, anchorPoints[3], anchorPoints[5]);
  }

  player.setFilter((float) mouseY/height*5000, mouseX / width);
  player2.setFilter((float) mouseY/height*5000,mouseX / width);
  
  player2.ramp(1.,1000);
  player2.speed((float) mouseX/width/2);
}

void mouseReleased()
{
  //println("rel");
  player2.ramp(0.,1000);
}

boolean isHorizontalish(float x,float y, float px, float py) {
  float diffx = abs(x - px);
  float diffy = abs(y - py);
  boolean horizontalish = (diffx > diffy);
  return horizontalish;
}


// Add random multiples in the surrounding area
void bezier1(float x,float y, float px, float py, float lineWidth, float bx, float by) {
    if (x == 0 && y == 0) {
      return;
    }

  //strokeWeight(lineWidth);
  //ellipse(x,y,px,py);
  float diffx = abs(x - px);
  float diffy = abs(y - py);
  
  boolean faraway = (diffx > 3 || diffy > 3);
  if (faraway) {
    float barLength = lineWidth * 4 + 10;
    float midx = (x+px)/2;
    float midy = (y+py)/2;

    strokeWeight(lineWidth);

    boolean horizontalish = isHorizontalish(x, y, px, py);
    if (horizontalish) {
      quad(x, y, midx, midy+barLength, px, py, midx, midy-barLength);
    }
    else {
      quad(x, y, midx+barLength, midy, px, py, midx-barLength, midy);
      beginShape();
      vertex(x, y);
      strokeWeight(1);
      bezierVertex(bx, 30, bx, by, 30, by);
      bezierVertex(50, bx, 145, 25, x, y);
      endShape();
    }
  }
  return;
}

void reflectBezier1(float x,float y, float px, float py, float lineWidth, float bx, float by) {
  bezier1(width/2+((width/2)-px),py,width/2+((width/2)-x),y, lineWidth, bx, by);
}

void reflectBrokenBrush(float x, float y, float px, float py, float lineWidth) {

  brokenLineBrush(width/2+((width/2)-px),py,width/2+((width/2)-x),y, lineWidth);

}

// Add random multiples in the surrounding area
void brokenLineBrush(float x,float y, float px, float py, float lineWidth) {

    if (x == 0 && y == 0) {
      return;
    }

    float thickness = 10;
    float gap = -10;
    
    boolean horizontalish = isHorizontalish(x, y, px, py);
    if (horizontalish) {
      if (x < px) {
        gap = -gap;
      }
      quad(x+gap, y+thickness, px-gap, py+thickness, px-gap, py-thickness, x+gap, y - thickness);
    }
    else {
      if (y < py) {
        gap = -gap;
      }
      quad(x+thickness, y+gap, px+thickness, py-gap, px-thickness, py-gap, x - thickness, y+gap); 
    }
}

void quadbrush(float x,float y, float px, float py, float lineWidth) {
  //strokeWeight(lineWidth);
  //ellipse(x,y,px,py);
  float diffx = abs(x - px);
  float diffy = abs(y - py);
  
  if (diffx > 5 || diffy > 5) {
    float barLength = lineWidth * 4 + 10;
    float midx = (x+px)/2;
    float midy = (y+py)/2;
    
    boolean horizontalish = diffx > diffy;
    if (horizontalish) {
      quad(x, y, midx, midy+barLength, px, py, midx, midy-barLength);
    }
    else {
      quad(x, y, midx+barLength, midy, px, py, midx-barLength, midy);
    }
  }
  return;
}


