public static class Console extends PApplet {

  static String content = "";
  PFont font;
  int maxLength = 1000;
  int maxline = 30;

  boolean useSyphon = false;

  //SYPHON
  SyphonServer server;


  public void settings() {
    //size(1920, 1080, P3D);
    fullScreen(P3D,1);
    //smooth();
  }

  public void setup() {
    //frameRate(10);
    //surface.setResizable(true);

    font = createFont("Pixel", 50);

    //SYPHON
    if (useSyphon)server = new SyphonServer(this, "Console");
  }

  public void draw() {
    resetShader();
    background(0, 0, 255);
    textFont(font);
    textSize(25);
    fill(255);
    noStroke();
    text(content, 0, 0, width, height);

    if (content.length() > maxLength) {
      content = content.substring(content.length()-maxLength);
    }

    if (useSyphon)server.sendScreen();
  }

  public static void log(String s) {
    content += s;
  }

  public static void logln(String s) {
    content += s + "\n";
  }
}