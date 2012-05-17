function conformalShowCircles(axIn, axOut, t1, t2)
% conformalShowCircles Plot packed circles before/after transformation.
%
% Supports conformal transformation demo, ipexconformal.m
% ("Exploring a Conformal Mapping").

% Copyright 2005-2009 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $  $Date: 2009/11/09 16:24:51 $

sep = 0.002;   % Separation between circles
d = 1/8;       % Center-to-center distance
radius = (d - sep)/2;   % Radius of circles
for u = -(5/4 - d/2) : d : (5/4 - d/2)
    for v = -(3/4 - d/2) : d : (3/4 - d/2)
        % Draw circle on input axes
        [uc,vc] = Circle(u,v,radius);
        line(uc,vc,'Parent',axIn,'Color',[0.3 0.3 0.3]);

        % Apply z = w + sqrt(w^2-1), draw circle on output axes
        [xc,yc] = tformfwd(t1,uc,vc);
        line(xc,yc,'Parent',axOut,'Color',[0 0.8 0]);
        
        % Apply z = w - sqrt(w^2-1), draw circle on output axes
        [xc,yc] = tformfwd(t2,uc,vc);
        line(xc,yc,'Parent',axOut,'Color',[0 0 0.9]);
    end
end

%-------------------------------------------------------------

function [x, y] = Circle(xCenter, yCenter, radius)
% Returns vectors containing the coordinates of a circle
% with the specified center and radius.

n = 32;
theta = (0 : n)' * (2 * pi / n);
x = xCenter + radius * cos(theta);
y = yCenter + radius * sin(theta);
