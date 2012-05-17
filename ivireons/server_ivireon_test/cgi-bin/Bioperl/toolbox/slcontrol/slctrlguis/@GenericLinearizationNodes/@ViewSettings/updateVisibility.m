function updateVisibility(this)
% UPDATEVISIBILITY  Update the visibility of all the plots in the
% ltiviewer.
%
 
% Author(s): John W. Glass 18-Jul-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/08/20 16:43:25 $

% Get the indices for the plots that are visible
plotconfigs = this.PlotConfigurations(:,2);
ind_config = find(~strcmp(plotconfigs,'None'));
vis_td = this.VisibleResultTableData;

for ct = 1:size(this.VisibleResultTableData,1)
    % Find the systems that are visible
    cellrow = cell(vis_td(ct,2:7));

    % Get the current plot cells
    PlotCells = this.LTIViewer.PlotCells;
    for ct2 = 1:numel(ind_config)
        Cell = PlotCells{ct2}(end);
        if ~cellrow{ind_config(ct2)}
            Cell.Responses(ct).Visible = 'off';
        else
            Cell.Responses(ct).Visible = 'on';
        end
    end
end