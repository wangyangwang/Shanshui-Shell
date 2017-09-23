import SimpleOpenNI.*;
import processing.opengl.*;
import toxi.physics.*;
import toxi.physics.behaviors.*;
import toxi.physics.constraints.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import toxi.math.noise.*;
import toxi.volume.*;
import java.util.*;
import controlP5.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import java.awt.Dimension;
import glitchP5.*;
import codeanticode.syphon.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;


//注意：
//请在运行前安装字体Pixel.ttf  文件就在跟这个文件的同级的文件夹里面，不然找不到字体会显示默认的丑丑字体


boolean useSyphon = false;
GlitchP5 glitchP5; // declare an instance of GlitchP5. only one is needed


VerletPhysics physics;
ParticleConstraint boundingSphere;
ParticleConstraint boundingSphereOutside;
GravityBehavior gravity;
VolumetricSpaceArray volume;
IsoSurface isosurface;
TriangleMesh mesh = new TriangleMesh("fluid");
Vec3D colAmp = new Vec3D(400, 200, 200);
int NUM_FLOATING_PARTICLES = 250;
int NUM_PARTICLES = 50;
/// Resolution
int DIM = 500;
/// Numer of grid
int GRID = 30;
Vec3D SCALE = new Vec3D(DIM, DIM, DIM).scale(2);
float isoThreshold = 3;
float isoThresholdMultiplyer = 0.001;
int numP;
float volMultiplier = 1.0;
float centerSphereSizeMul = 0.3;
color backgroundColor;

boolean showPhysics=false;
boolean isWireFrame=false;
boolean isClosed=true;
boolean useBoundary=false;
boolean drawCoordinate = false;

float nx, ny, nz;
Vec3D sceneRotation = new Vec3D(0, 0, 0);

float BGNoiseIndex, ns02, ns03;

PShader fogColor; 

float fognear;
float fogfar = 1413;

//SOUND
Minim minim;
AudioPlayer player;
FFT fft;


//OPENNI
SimpleOpenNI context;
boolean kinectNotConnected;
//Kinect alternative: web cam
Capture video;
OpenCV opencv;
int faceN;
int preFaceN;

//SYPHON
SyphonServer server;

void settings() {
  size(1280, 720, P3D);
}

void setup() {

  //OPENNI
  context = new SimpleOpenNI(this);

  if (!context.isInit()) {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    //exit();
    //return;
    kinectNotConnected = true;
    video = new Capture(this, 640/2, 480/2);
    opencv = new OpenCV(this, 640/2, 480/2);
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
    video.start();
  }

  context.enableUser();

  //VISUAL
  fogColor = loadShader("fogColor.glsl");
  fogColor.set("fogNear", 0.0);
  fogColor.set("fogFar", fogfar);

  physics = new VerletPhysics();


  physics.setWorldBounds(new AABB(
    new Vec3D(), new Vec3D(DIM, DIM, DIM)
    )); //world bound

  if (isosurface!=null) {
    isosurface.reset();
    mesh.clear();
  }

  //initialise physics
  boundingSphere = new SphereConstraint(new Sphere(new Vec3D(), DIM * centerSphereSizeMul), SphereConstraint.INSIDE); //sphere bound
  boundingSphereOutside = new SphereConstraint(new Sphere(new Vec3D(), DIM * centerSphereSizeMul), SphereConstraint.OUTSIDE);
  gravity = new GravityBehavior(new Vec3D(0, 0, 0));

  //volume of each cell
  volume = new VolumetricSpaceArray(SCALE, GRID, GRID, GRID);


  // isosurface is more like a isosurface generator than isosurface itself.
  isosurface = new ArrayIsoSurface(volume);


  initGUI();

  //SOUND STUFF
  minim = new Minim(this);
  player = minim.loadFile("Neptune+NeilPostman.mp3");
  player.loop();
  fft = new FFT(player.bufferSize(), player.sampleRate());

  //glitch
  glitchP5 = new GlitchP5(this); // initiate the glitchP5 instance;



  //CONSOLE
  String[] args = {"Console"};
  Console console = new Console();
  PApplet.runSketch(args, console);


  //SYPHON
  if (useSyphon) {
    server = new SyphonServer(this, "Shell Main");
  }
}


void draw() {


  //OPENNI
  context.update();

  if (kinectNotConnected) {
    opencv.loadImage(video);
    Rectangle[] faces = opencv.detect();
    faceN = faces.length;
    if (faceN != preFaceN) {
      triggerInteraction();
      Console.logln("total face number changed....");
    }
    preFaceN = faceN;
  }


  fogColor.set("_Time", (float)millis()/10000.0);


  fft.forward(player.mix);

  fftSpectrum2 = (fft.getBand(20) - fftSpectrum2pre) * 0.01 + fftSpectrum2pre;
  fftSpectrum2pre = fftSpectrum2;

  //println(fftSpectrum2*100);
  //fogfar = fftSpectrum2 * 100000;
  fogfar = map(fftSpectrum2 * 100, 50, 80, 1200, 0);
  fogColor.set("fogNear", fognear); 
  fogColor.set("fogFar", fogfar);

  float cellSize = (float)DIM * 2 / GRID;
  int index = 0;
  //ADD PARTICLE TO FLOATING PHYSICS
  if (physics.particles.size()==0) {
    for (int i=0; i<NUM_PARTICLES; i++) {
      float centerSphereDIM = DIM * centerSphereSizeMul;
      MyVerletParticle p = new MyVerletParticle(new Vec3D(random(-centerSphereDIM, centerSphereDIM), random(-centerSphereDIM, centerSphereDIM), random(-centerSphereDIM, centerSphereDIM)));
      p.inCenterSphere = true;
      p.addConstraint(boundingSphere);
      physics.addParticle(p);
    }
    for (int i=0; i<NUM_FLOATING_PARTICLES; i++) {
      MyVerletParticle p = new MyVerletParticle(new Vec3D(random(-DIM, DIM), random(-DIM, DIM), random(-DIM, DIM)));
      p.inCenterSphere = false;
      p.addConstraint(boundingSphereOutside);
      physics.addParticle(p);
    }
  } else {
    for (int i=0; i < physics.particles.size (); i++) {
      MyVerletParticle p = (MyVerletParticle)physics.particles.get(i);
      if (p.inCenterSphere) {
        p.addForce(new Vec3D(random(-0.05, 0.05), random(-0.05, 0.05), random(-0.05, 0.05)) );
      } else {
        p.addForce(new Vec3D(random(-0.02, 0.02), random(-0.02, 0.02), random(-0.02, 0.02)) );
      }
    }
  }

  numP=physics.particles.size();

  physics.update();

  //comput volume
  Vec3D pos = new Vec3D();
  Vec3D offset = physics.getWorldBounds().getMin();
  float[] volumeData = volume.getData();
  index = 0;

  for (int z = 0; z < GRID; z++) {
    pos.z = z * cellSize + offset.z;
    for (int x = 0; x < GRID; x++) {
      pos.x = x * cellSize + offset.x;
      for (int y = 0; y < GRID; y++) {
        pos.y = y * cellSize + offset.y;
        float val = 0;
        for (int i=0; i < numP; i++) {
          MyVerletParticle pp = (MyVerletParticle)physics.particles.get(i);
          if (!pp.inCenterSphere) {
            float magnitude = pos.distanceToSquared(pp) + 0.0009;

            val += 1/magnitude;
          } else {
            float magnitude = pos.distanceToSquared(pp) + 0.00001;
            val += 1/magnitude;
          }
        }
        volumeData[index++] = val;
      }
    }
  }


  volume.closeSides();

  isosurface.reset();

  isoThreshold = map(sin(isoThreshold_index), -1, 1, 0.001, 0.007);

  if (frameCount % 60 == 0) {
    Console.log("new iso threshold: " + isoThreshold);
  }
  //println(isoThreshold);

  isoThreshold_index+=0.05/frameRate;
  //println(isoThreshold_index);
  isosurface.computeSurfaceMesh(mesh, isoThreshold);


  //----------------draw---------------------------
  pushMatrix();


  float ztranslate = 0;
  //  if (!Float.isNaN(zdist)) {
  //    ztranslate = map(zdist, 0, 1, 150, -150);
  //  }

  translate(width/2, height/2, ztranslate);

  shader(fogColor);
  lights();  
  noStroke();
  colorMode(HSB, 255);

  backgroundColor = color( map(sin(BGNoiseIndex), -1, 1, 0, 1) * 255, map(sin(bg_b_noise_index), -1, 1, 0, 70), map(sin(bg_b_noise_index), -1, 1, 0, 210) );
  BGNoiseIndex += 0.03/frameRate;

  bg_b_noise_index += 0.01/frameRate;

  background(backgroundColor);

  fill(backgroundColor);
  sphere(1300);
  noLights();


  resetShader();

  colorMode(RGB, 255);

  rotateX(sceneRotation.x);
  rotateY(sceneRotation.y);
  rotateZ(sceneRotation.z);


  float n1 = noise(sceneRotationXNoiseIndex);
  float n2 = noise(sceneRotationYNoiseIndex);
  float n3 = noise(sceneRotationZNoiseIndex);



  float xincre = map(n1, 0, 1, 0.0007, 0.0015);
  float yincre = map(n2, 0, 1, 0.0007, 0.0015);
  float zincre = map(n3, 0, 1, 0.0007, 0.0015);

  sceneRotation.addSelf(new Vec3D(xincre, yincre, zincre));

  sceneRotationXNoiseIndex+=0.01;
  sceneRotationYNoiseIndex+=0.01;
  sceneRotationZNoiseIndex+=0.01;


  if (drawCoordinate) {
    int xyzlineLength = 1000;
    stroke(255, 0, 0);
    strokeWeight(1);
    line(0, 0, 0, xyzlineLength, 0, 0);
    stroke(0, 255, 0);
    line(0, 0, 0, 0, xyzlineLength, 0);
    stroke(0, 0, 255);
    line(0, 0, 0, 0, 0, xyzlineLength);
  }

  strokeWeight(1);
  stroke(255);

  //DRAW MESH01 WIREFRAME
  float strokeAlp=0;
  strokeAlp = (sin(ni_wireframe_alp)+1)/2 * 100;
  stroke(255, strokeAlp);
  ni_wireframe_alp+=0.01;

  resetShader();
  //DRAW MESH01 COORDINATES
  if (noise(showCoordinateNoiseIndex) > 0.8) {
    for (Iterator i = physics.particles.iterator (); i.hasNext(); ) {
      VerletParticle p = (VerletParticle)i.next();
      fill(255);
      String coordinateText = (int)p.x +"/" +(int)p.y + "/" +(int)p.z;
      text(coordinateText, p.x, p.y, p.z);
    }
  }

  showCoordinateNoiseIndex+=0.01;
  shader(fogColor);
  drawVolumeMesh(mesh);
  popMatrix();

  resetShader();
  fill(255);
  text(frameRate, width-50, 20);
  glitchP5.run();
  if (useSyphon)server.sendScreen();
  //ui.draw();
}

void normal(Vec3D v) {
  normal(v.x, v.y, v.z);
}

void vertex(Vec3D v) {
  vertex(v.x, v.y, v.z);
}

void keyPressed() {
  if (key=='h') {
    ui.hide();
  }
  if (key=='s') {
    ui.show();
  }

  if (key=='t') {
    triggerInteraction();
  }
}