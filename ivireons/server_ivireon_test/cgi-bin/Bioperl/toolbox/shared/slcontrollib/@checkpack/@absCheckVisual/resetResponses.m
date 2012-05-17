function resetResponses(this) 
%
 
% Author(s): A. Stothert 10-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:35 $

% RESETRESPONSES  Clear the stored responses on the ltiplot
%

%Disable limit manager to prevent axes resizing when removing responses
this.hPlot.AxesGrid.LimitManager = 'off';
for ct = numel(this.hPlot.Responses):-1:1;
   this.hPlot.rmresponse(this.hPlot.Responses(ct));
end
this.hPlot.AxesGrid.LimitManager = 'on';
end