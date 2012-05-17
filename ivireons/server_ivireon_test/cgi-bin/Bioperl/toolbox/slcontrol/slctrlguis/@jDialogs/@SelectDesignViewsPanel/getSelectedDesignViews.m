function DesignViews = getSelectedDesignViews(this)
% GETVIEWTABLEDATA  Get the selected graphical editor data.
%
 
% Author(s): John W. Glass 12-Oct-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:28:46 $

% Get the SISOTOOL Design View table data
TablePanel = this.Handles.SelectSISOTOOLViews.TablePanel;
DesignViews = cell(TablePanel.getViewTableData);

% Remove the first column 
DesignViews = DesignViews(:,2:3);
% Remove the plots that are set to None
DesignViews = DesignViews(~strcmp(DesignViews(:,2),'None'),:);