PrintWriter output;
int paintTime=2;
int pauseTime=10;
int printSpeed=500;
int jogSpeed=3000;
boolean firstPoint=true;

void setup()
{
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
  sphere(25,20);
      
  output.println("G28");  //home all axes again when we're done
  output.flush();
  output.close();
  exit();
}

void sphere(float centerZ, float radius)
{
  float z=centerZ-radius;
  float stretch=radius/15;  //should take ten circles to draw a full sphere
  moveTo(0,0,z);
  float rad;
  float points=20;  //ten points/circle;
  while(z<centerZ+radius)
  {
     for(int p=0;p<points;p++)
       {
         rad=sqrt(pow(radius,2)-pow(z-centerZ,2));
         moveTo(rad*cos(2*PI*p/points),rad*sin(2*PI*p/points),z);
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
   for(int i=0;i<revolutions;i++)
     for(int p=0;p<points;p++)
       {
         moveTo(radius*cos(2*PI*p/points),radius*sin(2*PI*p/points),z);
         dot();
         z+=stretch/points;
       }
}

void purge()
{
  moveTo(67,67);  //move to the purge position
  output.println("M106");  //turn on the pressure to the syringe
  output.println("G4 P500"); //keep the pressure on for half a second to purge the needle
  output.println("M107");  //turn off pressure to the syringe  
}

void moveTo(float x, float y)
{
        if(firstPoint)
        {
          output.println("G1 F"+jogSpeed);
          firstPoint=false;
        }
        else
          output.println("G1 F"+printSpeed); //set the feedrate to 3000mm/min
        output.println("G1 X"+x+" Y"+y);  
}

void moveTo(float x, float y, float z)
{
        if(firstPoint)
        {
          output.println("G1 F"+jogSpeed);
          firstPoint=false;
        }
        else
          output.println("G1 F"+printSpeed); //set the feedrate to 3000mm/min
        output.println("G1 X"+x+" Y"+y+" Z"+z);  
}

void grid()
{
  boolean firstPoint=true;
 for(int z=5;z<=30;z+=10)
  for(int x=-10;x<=10;x+=5)
    for(int y=-10;y<=10;y+=5)
      {
        if(firstPoint)
        {
          output.println("G1 F"+jogSpeed);
          firstPoint=false;
        }
        else
          output.println("G1 F"+printSpeed); //set the feedrate to 3000mm/min
          moveTo(x,y,z);
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

