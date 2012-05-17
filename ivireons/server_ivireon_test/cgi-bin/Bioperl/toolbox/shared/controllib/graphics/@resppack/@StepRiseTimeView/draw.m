function draw(cv,cd,NormalRefresh)
%DRAW  Draws peak response characteristic.

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:35 $
for ct=1:numel(cv.Points)
   set(double(cv.Points(ct)),'XData',NaN,'YData',NaN)
end