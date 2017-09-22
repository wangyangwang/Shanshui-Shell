ControlP5 ui;

int ypos = 10;

void initGUI() {
  
  ui = new ControlP5(this);
  
  ui.addToggle("drawCoordinate").setPosition(20, ypos+=10).setSize(14, 14);
  ui.addSlider("fognear").setRange(-2000, 2000).setSize(300, 10).setPosition(20, 270).setValue(0);
  ui.addSlider("fogfar").setRange(-2000, 2000).setSize(300, 10).setPosition(20, 290).setValue(1413);
  ui.setAutoDraw(false);
  
  
  ui.hide();
}
