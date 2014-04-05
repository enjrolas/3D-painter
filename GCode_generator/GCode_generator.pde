PrintWriter output;
int paintTime=5;
int pauseTime=10;
int printSpeed=2000;
int jogSpeed=3000;
float offset=5;  //distance to move up when moving between points
boolean firstPoint=true;
PVector currentPoint, lastPoint;

void setup()
{
  currentPoint=new PVector(0,0,40);
  lastPoint=currentPoint;
  output=createWriter("paint.gcode");    
  noLoop();
}

void draw()
{
  println("round "+frameCount);
  output.println("G28"); //home all axes;
  output.println("G90"); //absolute positioning.  I start at (0,0,80)
  //purge();
  //grid();
  //  helix();
    sphere(45,20);
  //cube(40, 10);    
  output.println("G28");  //home all axes again when we're done
  output.flush();
  output.close();
  exit();
}

void cube(float centerZ, float sideLength)
{
  PVector [] bottomPoints=new PVector[4];
  PVector [] topPoints=new PVector[4];
  bottomPoints[0]=new PVector(-sideLength, -sideLength, centerZ-sideLength);
  bottomPoints[1]=new PVector(sideLength, -sideLength, centerZ-sideLength);
  bottomPoints[2]=new PVector(-sideLength, sideLength, centerZ-sideLength);
  bottomPoints[3]=new PVector(sideLength, sideLength, centerZ-sideLength);
  topPoints[0]=new PVector(-sideLength, -sideLength, centerZ+sideLength);
  topPoints[1]=new PVector(sideLength, -sideLength, centerZ+sideLength);
  topPoints[2]=new PVector(-sideLength, sideLength, centerZ+sideLength);
  topPoints[3]=new PVector(sideLength, sideLength, centerZ+sideLength);
  for(int i=0;i<4;i++)
    dotLine(bottomPoints[i], bottomPoints[(i+1)%4],4);
  for(int i=0;i<4;i++)
    dotLine(bottomPoints[i], topPoints[i],4);
  for(int i=0;i<4;i++)
    dotLine(topPoints[i], topPoints[(i+1)%4],4);
}

void dotLine(PVector from, PVector to, float points)
{
  PVector p=from;
  for (float i=0;i<points;i++)
  {
    moveTo(p);
    dot();
    p.x+=(to.x-from.x)/points;
    p.y+=(to.y-from.y)/points;
    p.z+=(to.z-from.z)/points;
  }
}

void sphere(float centerZ, float radius)
{
  float z=centerZ-radius;
  float stretch=radius/5;  //should take ten circles to draw a full sphere
  moveTo(new PVector(0,0,z));
  float rad;
  float points=10;  //ten points/circle;
  while (z<centerZ+radius)
  {
    for (int p=0;p<points;p++)
    {
      rad=sqrt(pow(radius, 2)-pow(z-centerZ, 2));
      PVector a=new PVector(rad*cos(2*PI*p/points), rad*sin(2*PI*p/points), z);
      moveTo(a);
      dot();
      z+=stretch/points;
    }
  }
}

void helix()
{
  float radius=15;
  float stretch=5;  //5mm per every revolution
  float points=10;  //ten points per revolution;
  int revolutions=3;
  float z=10;
  for (int i=0;i<revolutions;i++)
    for (int p=0;p<points;p++)
    {
      PVector a=new PVector(radius*cos(2*PI*p/points), radius*sin(2*PI*p/points), z);
      moveTo(a);
      dot();
      z+=stretch/points;
    }
}

void purge()
{
  moveTo(67, 67);  //move to the purge position
  output.println("M106");  //turn on the pressure to the syringe
  output.println("G4 P500"); //keep the pressure on for half a second to purge the needle
  output.println("M107");  //turn off pressure to the syringe
}

void moveTo(float x, float y)
{
  if (firstPoint)
  {
    output.println("G1 F"+jogSpeed);
    firstPoint=false;
  }
  else
    output.println("G1 F"+printSpeed); //set the feedrate to 3000mm/min
  output.println("G1 X"+x+" Y"+y);
}

void moveTo(PVector point)
{
  if (firstPoint)
  {
    output.println("G1 F"+jogSpeed);
    firstPoint=false;
  }
  else
    output.println("G1 F"+printSpeed); //set the feedrate to 3000mm/min          
  output.println("G1 X"+lastPoint.x+" Y"+lastPoint.y+" Z"+(lastPoint.z+offset));  //move straight up
  output.println("G1 X"+point.x+" Y"+point.y+" Z"+(point.z+offset));  //move over, still out of plane
  output.println("G1 X"+point.x+" Y"+point.y+" Z"+point.z);  //now move to our target point
  lastPoint=point;
}

void grid()
{
  boolean firstPoint=true;
  for (int z=5;z<=30;z+=10)
    for (int x=-10;x<=10;x+=5)
      for (int y=-10;y<=10;y+=5)
      {
        if (firstPoint)
        {
          output.println("G1 F"+jogSpeed);
          firstPoint=false;
        }
        else
          output.println("G1 F"+printSpeed); //set the feedrate to 3000mm/min
        moveTo(new PVector(x, y, z));
        //output.println("G1 Z"+(z+5));  //zip up 20mm
        dot();
      }
}
void dot()
{
  output.println("M106");  //turn on the pressure to the syringe
  output.println("G4 P"+paintTime); //keep the pressure on for paintTime milliseconds
  output.println("M107");  //turn off pressure to the syringe
  output.println("G4 P"+pauseTime); //pause for pauseTime to let the fluid stop flowing out
}

