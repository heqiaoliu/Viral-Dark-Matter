function haveNewData(this,hSrc) 
% HAVENEWDATA process data changed events on data source object
%
 
% Author(s): A. Stothert 19-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/04/21 21:47:37 $

%Helper to push new data to any visualizations
if this.ActiveSource
   %Update visual
   this.Data.Data = struct('LoggedData', hSrc.NewData, 'time', hSrc.NewTime);
   this.NewData   = true;
   this.updateVisual;
   %Update playback display time
   this.updateSimTimeReadout;
   this.updateTimeStatus;
end
end
