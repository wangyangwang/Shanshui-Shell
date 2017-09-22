 fogColor = loadShader("fogColor.glsl");
  fogColor.set("fogNear", 0.0); 
  fogColor.set("fogFar", 500.0);

  fogLines = loadShader("fogLines.glsl");
  fogLines.set("fogNear", 0.0); 
  fogLines.set("fogFar", 500.0);

  fogTex = loadShader("fogTex.glsl");
  fogTex.set("fogNear", 0.0); 
  fogTex.set("fogFar", 500.0);
  
  hint(DISABLE_DEPTH_TEST); 