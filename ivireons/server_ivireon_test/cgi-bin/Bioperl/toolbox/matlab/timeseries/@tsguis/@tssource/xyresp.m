function xyresp(src, r)
%XYRESP  Updates @xydata objects.
%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2005/07/14 15:27:26 $
    
   
%% Look for visible+cleared responses in response array
if isempty(r.Data.Xdata) && strcmp(r.View.Visible,'on') && ...
        size(src.Timeseries.Data,1)==size(src.Timeseries2.Data,1)     
  
  %% TO DO: Allow X axes to have different foci
  % Update the data with the xy plot
  xData = src.Timeseries.Data;
  yData = src.Timeseries2.Data;
  
  set(r.Data,'XData',xData,'YData',yData)
  
end
