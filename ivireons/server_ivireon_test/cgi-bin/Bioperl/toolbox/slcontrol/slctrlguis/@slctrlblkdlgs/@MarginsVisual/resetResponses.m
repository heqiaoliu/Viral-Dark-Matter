function resetResponses(this) 
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:52 $

% RESETRESPONSES  Clear the stored responses on the ltiplot
%

if strcmp(this.PlotType,'table')
  this.hPlot.reset;
else
   %Disable limit manager to prevent axes resizing when removing responses
   this.hPlot.AxesGrid.LimitManager = 'off';
   for ct = numel(this.hPlot.Responses):-1:1;
      this.hPlot.rmresponse(this.hPlot.Responses(ct));
   end
   this.hPlot.AxesGrid.LimitManager = 'on';
end
end