import processing.serial.*;

Serial myPort;
PVector currentWaypoint;


void setup()
{  
  //initialize the serial port to talk to the printer
  myPort=new Serial(this, Serial.list()[0], 115200);
}

void loop()
{
}

void moveTo(PVector destination)
{
}

void dottingMove(PVector destination)
{
}


