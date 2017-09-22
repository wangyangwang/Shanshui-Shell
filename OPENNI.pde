void onNewUser(SimpleOpenNI curContext, int userId)
{
  Console.log("onNewUser - userId: " + userId);
  Console.log("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);

  glitchP5.glitch(width/2, height/2, 100, 100, width, height, 2, 1.0f, 0, 10);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  Console.log("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  Console.log("onVisibleUser - userId: " + userId);
}