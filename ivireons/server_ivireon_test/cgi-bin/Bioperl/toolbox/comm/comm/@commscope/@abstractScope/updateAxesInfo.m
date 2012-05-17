function updateAxesInfo(this, hAxesRe, hAxesIm)
%UPDATEAXESUINFO Update the information of the axes of the scope

%   @commscope/@abstractScope
%
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:11:07 $

if ( this.isScopeAvailable )
    axesInfo = this.PrivAxesInfo;
    
    % Update labels
    updateLabels(hAxesRe, ...
        axesInfo.Title{1}, axesInfo.XLabel{1}, axesInfo.YLabel{1});
    
    % Update grid
    updateGrid(hAxesRe, ...
        axesInfo.XGrid{1}, axesInfo.YGrid{1}, ...
        axesInfo.XColor{1}, axesInfo.YColor{1}, axesInfo.ZColor{1});
    
    % Update tags
    set(hAxesRe, 'Tag', axesInfo.Tag{1});
    
    % If we have an imaginary axes
    if ~isempty(hAxesIm)
        % Update labels
        updateLabels(hAxesIm, ...
            axesInfo.Title{2}, axesInfo.XLabel{2}, axesInfo.YLabel{2});
        
        % Update grid
        updateGrid(hAxesIm, ...
            axesInfo.XGrid{2}, axesInfo.YGrid{2}, ...
            axesInfo.XColor{2}, axesInfo.YColor{2}, axesInfo.ZColor{2});
        
        % Update tags
        set(hAxesIm, 'Tag', axesInfo.Tag{2});
        
    end
    
    this.PrivUpdateAxes = 0;
end

%-------------------------------------------------------------------------------
function updateLabels(ha, t, xLabel, yLabel)
% Subfunction to update axes labels

% Set the title
hTitle = get(ha, 'Title');
set(hTitle, 'String', t);

% Set x and y labels
hLabel = get(ha, 'XLabel');
set(hLabel, 'String', xLabel);
hLabel = get(ha, 'YLabel');
set(hLabel, 'String', yLabel);

%-------------------------------------------------------------------------------
function updateGrid(ha, xGrid, yGrid, xColor, yColor, zColor)
% Update grid.  Do not store Z-grid since it is handled by the
% type of the plot.
set(ha, 'XGrid', xGrid, ...
    'YGrid', yGrid, ...
    'XColor', xColor, ...
    'YColor', yColor, ...
    'ZColor', zColor)

%-------------------------------------------------------------------------------
% [EOF]
