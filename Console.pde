public static class Console extends PApplet {

  static String content = "";
  PFont Inconsolata;
  int maxLength = 8000;

  //SYPHON
  SyphonServer server;


  public void settings() {
    size(540, 960, P3D);
    smooth();
  }

  public void setup() {
    frameRate(10);
    surface.setResizable(true);


    //SYPHON
    server = new SyphonServer(this, "Console");
  }

  public void draw() {
    fill(0, 100);
    noStroke();
    rect(0, 0, width, height);
    textSize(10);
    fill(255);
    stroke(255);
    //textAlign(LEFT, BOTTOM);
    text(content, 0, 0, width, height);

    if (content.length() > maxLength) {
      content = content.substring(content.length()-maxLength);
    }

    //server.sendScreen();
  }

  public static void log(String s) {
    content += s;
  }

  public static void logln(String s) {
    content += s + "\n";
  }
}