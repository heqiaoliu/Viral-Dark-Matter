function adjustview(this,Event)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(R,'prelim') is invoked before updating the limits.
%  ADJUSTVIEW(R,'postlim') is invoked in response to a LimitChanged event.

%  Author(s): P. Gahinet
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:47 $

% Adjust HSV chart
if ~this.Data.Exception
   % Proceed only if data is valid and view is visible
   adjustview(this.View,this.Data,Event,strcmp(this.RefreshMode,'normal'))
end
