PShader shader;
String name = "chladni";

void setup() {
  size( 1200, 500, P3D );
  noStroke();
  shader = loadShader( name + ".glsl");
}

void draw() {

  shader.set("u_resolution", float(width), float(height));
  shader.set("u_time", 1000 + millis() / 1000.0);

  shader(shader);
  rect(0,0,width,height);

}
void keyPressed(){
  shader = loadShader( name + ".glsl");
  saveFrame( name + ".png" );
}