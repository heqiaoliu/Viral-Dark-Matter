function initialize(this,Axes)
%  INITIALIZE  Initializes @freqview objects.

%  Author(s):  
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:56:51 $


% Get axes in which responses are plotted
[s1,s2] = size(Axes); 
Axes = reshape(Axes,[s1*s2 1]);

% Create curves
Curves = zeros([s1 s2]);
for ct=1:s1*s2
   Curves(ct) = line('XData',NaN,'YData',NaN, ...
      'Parent',Axes(ct,1), 'Visible', 'off','Marker','x','Linestyle','None');
end
this.Curves = handle(Curves);
