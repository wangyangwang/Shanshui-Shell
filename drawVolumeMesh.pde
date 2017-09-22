void drawVolumeMesh(TriangleMesh m) {
  beginShape(TRIANGLES);
  int num = m.getNumFaces();
  for (int i=0; i<num; i++) {
    Face f = m.faces.get(i);

    Vec3D col = f.a.add(colAmp).scaleSelf(0.5);

    color ca = color(col.x, col.y, col.z);
    col = f.b.add(colAmp).scaleSelf(0.5);
    color cb = color(col.x, col.y, col.z);
    col = f.c.add(colAmp).scaleSelf(0.5);
    color cc = color(col.x, col.y, col.z);

    fill(ca);
    normal(f.a.normal);
    vertex(f.a);

    fill(cb);
    normal(f.b.normal);
    vertex(f.b);

    fill(cc);
    normal(f.c.normal);
    vertex(f.c);
  }
  endShape();
}