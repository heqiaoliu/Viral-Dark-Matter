function initialize(this,Axes)
%INITIALIZE  Initialization for @tsCharLineView class

%  Author(s):  
%  Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 21:41:50 $

[s1,s2] = size(Axes(:,:,1)); 
Lines = zeros([s1 s2]);

%% Hittest must be on for characteristic data tip to work
for ct=1:s1*s2
   % RE: Set Z=-10 to make sure char lines don't obscure response lines
   Lines(ct) = line(NaN,NaN,-10,...
      'Parent',Axes(ct),...
      'Visible','off',...
      'LineStyle',':',...
      'Selected','off',...
      'XlimInclude','off', 'YlimInclude','off',...
      'HandleVisibility','off',...
      'Color','k');
end
this.Lines = handle(Lines);
this.LineTips = cell([s1 s2]);