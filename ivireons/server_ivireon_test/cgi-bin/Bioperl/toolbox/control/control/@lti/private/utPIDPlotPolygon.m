function utPIDPlotPolygon(fHandle,Vertices,Polygon,i,r1,T)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:22:10 $

% plot stable polygons
ind = Polygon{i};
figure(fHandle)
for j = 1:length(ind)-1
    cStart = T*[Vertices(ind(j),1);r1;Vertices(ind(j),2)];
    cEnd = T*[Vertices(ind(j+1),1);r1;Vertices(ind(j+1),2)];
    plot3([cStart(1) cEnd(1)],[cStart(3) cEnd(3)],[cStart(2) cEnd(2)]);
    hold on
end
cStart = T*[Vertices(ind(end),1);r1;Vertices(ind(end),2)];
cEnd = T*[Vertices(ind(1),1);r1;Vertices(ind(1),2)];
plot3([cStart(1) cEnd(1)],[cStart(3) cEnd(3)],[cStart(2) cEnd(2)]);
xlabel('Ki/r0');ylabel('Kd/r2');zlabel('Kp/r1');title('stable regions');                    

