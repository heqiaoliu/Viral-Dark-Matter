function updateLegend(this) 
% UPDATELEGEND method to display/hide a legend on the visualization
%
 
% Author(s): A. Stothert 16-Apr-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/04/30 00:44:02 $

hAx = this.hPlot.getaxes;
hAx = hAx(1);  %Bode magnitude;
if this.ShowLegend
   if ~isempty(this.hPlot.Responses)
      legend(hAx,'show');
   end
else
   legax = findobj(get(this.hPlot.AxesGrid.Parent,'Children'),'flat','Type','axes','Tag','legend');
   if ~isempty(legax)
      set(legax,'Visible','off')
   end
end
end