#!/usr/bin/python

import sys
import os
import math

class Point:
    x=0
    y=0
    z=0

    def __init__(self, x, y, z):
        self.x=x
        self.y=y
        self.z=z

    def __str__(self):
        return "(%f, %f, %f)" % (self.x, self.y, self.z)

    def distance(self, a):
        return math.sqrt(math.pow(self.x-a.x,2)+math.pow(self.y-a.y,2)+math.pow(self.z-a.z,2))

cupSize=Point(45,45,70)  #largest rectangular prism we can inscribe inside the cup (in mm)

needleSize=0.5
zoffset=10

if needleSize==0.5:    
    minDistance=1  #minimum distance between points, in mm
    paintTime=1000
    pauseTime=10
    printSpeed=2000
    jogSpeed=3000
    offset=0  #distance to move up when moving between points

if needleSize==1.2:    
    minDistance=1  #minimum distance between points, in mm
    paintTime=10
    pauseTime=20
    printSpeed=2000
    jogSpeed=3000
    offset=0  #distance to move up when moving between points

if needleSize==2:    
    minDistance=3  #minimum distance between points, in mm
    paintTime=5
    pauseTime=10
    printSpeed=2000
    jogSpeed=3000
    offset=15  #distance to move up when moving between points

filename=sys.argv[1]
print filename
f=open(filename, 'r')
gcodeFile=open(filename+".gcode", 'w')
lines=f.readlines()
points=[]
max=Point(0,0,0)
min=Point(1000,1000,1000)
for line in lines:
    parts=line.split()
    if parts[0].lower()=="vertex":
        point=Point(float(parts[1]), float(parts[2]), float(parts[3]))
        if point.x>max.x:
            max.x=point.x
        if point.y>max.y:
            max.y=point.y
        if point.z>max.z:
            max.z=point.z

        if point.x<min.x:
            min.x=point.x
        if point.y<min.y:
            min.y=point.y
        if point.z<min.z:
            min.z=point.z

        points.append(point)
        
points=sorted(points, key=lambda point: point.z)

scalingFactors=[cupSize.x/(max.x-min.x), cupSize.y/(max.y-min.y),cupSize.z/(max.z-min.z)]
scalingFactors.sort()
scalingFactor=scalingFactors[0]
#center the corner of the shape at (-width/2,-height/2,0) and scale the points
for point in points:
    point.x-=min.x
    point.y-=min.y
    point.z-=min.z
    point.x-=(max.x-min.x)/2
    point.y-=(max.y-min.y)/2
    point.x*=scalingFactor
    point.y*=scalingFactor
    point.z*=scalingFactor
    point.z+=zoffset

print "starting with %d points, pruning all points closer than %f mm " % (len(points), minDistance)

for index, point in enumerate(points):
    for trialPoint in points[index:]:
        if point.distance(trialPoint)<minDistance:
            print "removed point %s, distance from %s is %f" % (trialPoint, point, point.distance(trialPoint))
            points.remove(trialPoint)

print "ended up with %d points" % len(points)

#now we write the gcode to dot every pruned point
lastPoint=points[0]
gcodeFile.write("G28\n") #home all axes
gcodeFile.write("G90\n") #absolute positioning.  I start at (0,0,80)
for point in points:
    gcodeFile.write("G1 F%d\n" % printSpeed) #set the feedrate to 3000mm/min          
    gcodeFile.write("G1 X%f Y%f Z%f\n" % (lastPoint.x, lastPoint.y, lastPoint.z+offset))  #move straight up
    gcodeFile.write("G1 X%f Y%f Z%f\n" % (point.x, point.y, point.z+offset))  #move straight up
    gcodeFile.write("G1 X%f Y%f Z%f\n" % (point.x, point.y, point.z))  #move straight up
    gcodeFile.write("M106\n")  #turn on the pressure to the syringe
    gcodeFile.write("G4 P%d\n" % paintTime) #keep the pressure on for paintTime milliseconds
    gcodeFile.write("M107\n")  #turn off pressure to the syringe
    gcodeFile.write("G4 P%d\n" %pauseTime) #pause for pauseTime to let the fluid stop flowing out
    lastPoint=point

gcodeFile.write("G28")  #home all axes again when we're done

preview=open("%s-preview.ply" % filename,'w')
preview.write("ply\n")
preview.write("format ascii 1.0\n")
preview.write("element vertex %d\n" % len(points))
preview.write("property float x\n")
preview.write("property float y\n")
preview.write("property float z\n")
preview.write("end_header\n")
for point in points:
    preview.write("%f %f %f\n" % (point.x, point.y, point.z))
