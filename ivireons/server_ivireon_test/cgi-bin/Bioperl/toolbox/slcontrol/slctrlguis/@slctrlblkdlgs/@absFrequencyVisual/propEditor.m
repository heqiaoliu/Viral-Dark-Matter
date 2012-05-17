function hEdit = propEditor(this) 
% PROPEDITOR Returns singleton instance of Property Editor for the visual
 
% Author(s): A. Stothert 10-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:48 $

hEdit = PropEditor(this.hPlot);
hEdit.setTarget(this.hPlot);
end
