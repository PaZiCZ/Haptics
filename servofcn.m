function [ servoL, servoR ] = servofcn( x )
%SERVOFCN Summary of this function goes here
%   Detailed explanation goes here
aL= 0.0024;
bL= 0.0048;
cL= 0.2359;
aR= -0.0024;
bR= -0.0048;
cR= 0.7641;
servoL=(aL*(x*x))+(bL*x)+cL;
servoR=(aR*(x*x))+(bR*x)+cR;
end

