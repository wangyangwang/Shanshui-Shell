class MyVerletParticle extends VerletParticle {
  boolean inCenterSphere;

  float xnoiseIndex;
  float ynoiseIndex;
  float znoiseIndex;

  float xnoiseIndexAcc;
  float ynoiseIndexAcc;
  float znoiseIndexAcc;

  MyVerletParticle(Vec3D pos) {
    super(pos);

    //xnoiseIndex = random(0, 10);
    //ynoiseIndex = random(0, 10);
    //znoiseIndex = random(0, 10);

    //xnoiseIndexAcc = random(0, 0.01);
    //ynoiseIndexAcc = random(0, 0.01);
    //znoiseIndexAcc = random(0, 0.01);
  }

  void move() {
    this.addForce(new Vec3D());

    //xnoiseIndex += xnoiseIndexAcc;
    //ynoiseIndex += ynoiseIndexAcc;
    //znoiseIndex += znoiseIndexAcc;
  }
}