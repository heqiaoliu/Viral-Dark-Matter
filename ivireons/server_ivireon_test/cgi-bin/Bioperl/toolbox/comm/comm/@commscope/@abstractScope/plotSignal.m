function plotSignal(this, data, varargin)
%PLOTSIGNAL 	Plot the data

%   @commscope\@abstractScope
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:17:55 $

% Check if there is a scope
if ~(this.isScopeAvailable)
    this.createScope;
end

% If ColorMap is in varargin, then set
isColorMap = strcmp(varargin, 'ColorMap');
if ( any(isColorMap) )
    % Set ColorMap
    cMapIdx = find(isColorMap);
    set(this.PrivScopeHandle, 'ColorMap', varargin{cMapIdx(1)+1});

    % Remove ColorMap from the list
    isColorMap(cMapIdx+(0:1)) = 1;
    varargin = varargin(~isColorMap);
end

% Plot data
feval(this.PrivPlotFunction, this, data, varargin{:});

% Force the figure to update
drawnow;

%-------------------------------------------------------------------------------
% [EOF]
