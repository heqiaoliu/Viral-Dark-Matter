%TRAININV
% Data generation script for the inverse kinematics demo
% - Data generation through direct kinematics
% - Data generation through inverse kinematics
%
% Code is written in unvectorized form for understandability. Refer the
% demo for the vectorized version of the code.
%
%   J.-S. Roger Jang, 6-28-94.
%   Madan Bharadwaj, 6-20-05
%   Copyright 1994-2005 The MathWorks, Inc. 
%   $Revision: 1.8.2.2 $  $Date: 2005/11/15 00:57:20 $



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIRECT KINEMATICS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deducing x and y coordinates using direct kinematics formulae
% x = f(theta1, theta2)
% y = g(theta1, theta2)

l1 = 10; % length of first arm
l2 = 7; % length of second arm

theta1 = 0:0.1:pi/2; % some first angle
theta2 = 0:0.1:pi; % some second angle

data1 = [];
data2 = [];

for i=1:1:length(theta1)
    for j=1:1:length(theta2)

        x = l1 * cos(theta1(i)) + l2 * cos(theta1(i)+theta2(j)); % x coordinate
        y = l1 * sin(theta1(i)) + l2 * sin(theta1(i)+theta2(j)); % y coordinate
        
        data2 = [data1; x y theta1(i)];
        data2 = [data2; x y theta2(j)];
       
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVERSE KINEMATICS
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deducing theta1 and theta2 from x and y coordinates using inverse
% kinematics formulae 
% theta1 = f(x, y)
% theta2 = g(x, y)

l1 = 10; % length of first arm
l2 = 7; % length of second arm

X = 0:0.1:2; % x coordinates for validation
Y = 8:0.1:10; % y coordinates for validation

theta1D = [];
theta2D = [];

xy = [];

for i = 1:1:length(X)
    for j = 1:1:length(Y)

        x = X(i);
        y = Y(j);
        c2 = (x^2 + y^2 - l1^2 - l2^2)/(2*l1*l2);
        s2 = sqrt(1 - c2^2);
        theta2 = atan2(s2, c2); % theta2 is deduced

        k1 = l1 + l2*c2;
        k2 = l2*s2;
        theta1 = atan2(y, x) - atan2(k2, k1); % theta1 is deduced

        theta1D = [theta1D; theta1]; % save theta1
        theta2D = [theta2D; theta2]; % save theta2
        
        xy = [xy; x y]; % save x-y coordinates
        
    end        
end

