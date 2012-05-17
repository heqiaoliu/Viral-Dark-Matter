function hEdit = propEditor(this) 
% PROPEDITOR Returns singleton instance of Property Editor for the visual
 
 
% Author(s): A. Stothert 08-Jun-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.12.1 $ $Date: 2010/06/24 19:45:31 $

if ~strcmp(this.PlotType,'table')
   %Only show property editor if we have a visual with an axis
   hEdit = PropEditor(this.hPlot);
   hEdit.setTarget(this.hPlot);
end
end