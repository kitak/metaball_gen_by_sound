import ddf.minim.*;
Minim minim;
AudioInput in;
ArrayList particles;
PGraphics pg;

int mr[][], mg[][], mb[][];
float simplify = 2;

void setup() {
  size(600, 600, P2D);
  
  minim = new Minim(this);
  minim.debugOn();
  in = minim.getLineIn(Minim.MONO, 512);
  
  pg = createGraphics((int)(width/simplify), (int)(height/simplify), P2D);
  mr = new int[(int)(width/simplify)][(int)(height/simplify)];
  mg = new int[(int)(width/simplify)][(int)(height/simplify)];
  mb = new int[(int)(width/simplify)][(int)(height/simplify)];
  particles = new ArrayList();
}

void draw() {
  println(in.mix.level()*1000);
  
  if(canCreateNew()) {
    PVector position = new PVector(height/simplify/2, 30);
    float theta = random(PI/6*2, PI/6*4);
    float r = random(0.0, 5.0);
    PVector velocity = new PVector(r*cos(theta), r*sin(theta));
    particles.add(new Particle(position, velocity, int(random(120, 150))));
  }
    
  // draw metaballs
  for(int i=0; i<particles.size(); i++) {
    Particle p = (Particle)this.particles.get(i);
    int px = (int)p.position.x;
    int py = (int)p.position.y;
    for(int y=(py-50 >= 0) ? py-50 : 0; y<py+50 && y<pg.height; y++) {
      for(int x=(px-50 >= 0) ? px-50 : 0; x<px+50 && x<pg.width; x++) {
        p.drawMetaball(x, y);
      }
    }
  }
  pg.beginDraw();
  pg.loadPixels();
  for(int y=0; y<pg.height; y++) {
    for(int x=0; x<pg.width; x++) {
      int opacity = 191;
      pg.pixels[x+y*pg.width] = color(mr[x][y], mg[x][y], mb[x][y], opacity);
      // bokasu
      mr[x][y] = int(sqrt(mr[x][y]))*2;
      mg[x][y] = int(sqrt(mg[x][y]))*2;
      mb[x][y] = int(sqrt(mb[x][y]))*2;
    }
  }
  pg.updatePixels();
  pg.endDraw();
  
  image(pg, 0, 0, width, height);
  
  // proc
  for(int i=0; i<particles.size(); i++) {
    Particle p = (Particle)this.particles.get(i);
    p.tick();
    if(p.dead()) {
      this.particles.remove(i);
      i--;
    }
  }
}

Boolean canCreateNew() {
  return particles.size() < 15 && in.mix.level()*1000 > 170;
}

class Particle {
  public PVector position;
  PVector velocity;
  PVector accele;
  float r_ratio = 1, g_ratio = 1, b_ratio = 1;
  float ratio = 1;
  
  public Particle(PVector initPos, PVector initVel, int life) {
    this.position = initPos;
    this.velocity = initVel;
    
    this.accele = new PVector(random(-0.02,0.02), 0.04);
    
    this.r_ratio = random(0.5, 1);
    this.g_ratio = random(0.5, 1);
    this.b_ratio = random(0.5, 1);
    this.ratio = random(0.5, 1.0);
  }
  
  public void drawMetaball(int x, int y) {
    // metaball calc
    float p = 10000 / ((x-position.x)*(x-position.x) + (y-position.y)*(y-position.y) + 1);
    mr[x][y] += p * r_ratio * ratio;
    mg[x][y] += p * g_ratio * ratio;
    mb[x][y] += p * b_ratio * ratio;
  }
  
  public void tick() {
    // vector + vector
    this.velocity.add(this.accele);
    this.position.add(this.velocity);
  }
  
  public boolean dead() {
    if(position.y > height/simplify) {
      return true;
    } else {
      return false;
    }
  }
  
}

void stop() {
  in.close();
  minim.stop();
  super.stop();
}
