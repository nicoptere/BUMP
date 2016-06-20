PShader shader;
String name = "blocks_dark";

PImage logo;

void setup() {
  size( 1200, 500, P3D );
  noStroke();
  shader = loadShader( name + ".glsl");
  logo = loadImage("../logo.png");
}

void draw() {

  shader.set("u_resolution", float(width), float(height));
  shader.set("u_time", 1000 + millis() / 1000.0);

  shader(shader);
  rect(0,0,width,height);

  float n = norm( float( height ) / 2., 0., float( height ) );
  int w = int( logo.width  * n );
  int h = int( logo.height * n );

  image( logo, width/2-w/2,height/2-h/2,w,h );

}
void keyPressed(){
  shader = loadShader( name + ".glsl");
  saveFrame( name + ".png" );
}