function resizefcn(this, varargin)
%RESIZEFCN   Resize the gui.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/01 16:21:01 $

siggui_resizefcn(this, varargin{:});

% Get the children (if any), ignore dialogs
hC = find(allchild(this), '-depth', 0, '-not', '-isa', 'siggui.dialog');

for indx = 1:length(hC),
    if isrendered(hC(indx))
        resizefcn(hC(indx), varargin{:});
    end
end

if length(varargin{1}) == 2
    idealw = varargin{1}(1);
    idealh = varargin{1}(2);
else
    idealw = varargin{1};
    idealh = varargin{2};
end

% Get the handle to the figure
hFig = get(this, 'FigureHandle');

% Store the figure units for later restoration
FigureUnits = get(hFig,'Units');

% Determine the figure's current size
set(hFig,'Units','Pixels');
FigureSize = get(hFig,'position');
set(hFig,'Units',FigureUnits);

ratW = FigureSize(3)./(idealw);
ratH = FigureSize(4)./(idealh);

SizeRatio = [ratW ratH ratW ratH];

% Get the handles of the object
h = convert2vector(this.TabHandles);

for indx = 1:length(h)
    set(h(indx), 'Position', get(h(indx), 'Position').*SizeRatio);
end

% [EOF]
