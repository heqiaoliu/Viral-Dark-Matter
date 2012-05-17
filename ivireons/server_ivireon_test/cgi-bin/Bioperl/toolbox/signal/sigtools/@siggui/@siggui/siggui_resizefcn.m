function siggui_resizefcn(this, IdealSizeW, IdealSizeH)
% Layout the uis if figure is different from default
% this - Input is the handle to the object after all children have been added
% IdealSize - Size at which the figure would ideally have been created

%   Author(s): Z. Mecklai, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2007/12/14 15:19:55 $

if nargin == 2,
    if length(IdealSizeW) == 2,
        IdealSizeH = IdealSizeW(2);
        IdealSizeW = IdealSizeW(1);
    else 
        error(generatemsgid('GUIErr'),'Need figure Width and Height')
    end
    
end

% Get the handle to the figure
hFig = get(this, 'FigureHandle');

% Store the figure units for later restoration
FigureUnits = get(hFig,'Units');

% Determine the figure's current size
set(hFig,'Units','Pixels');
FigureSize = get(hFig,'position');
set(hFig,'Units',FigureUnits);

ratW = FigureSize(3)./(IdealSizeW);
ratH = FigureSize(4)./(IdealSizeH);

SizeRatio = [ratW ratH ratW ratH];

% Get the handles of the object
h = handles2vector(this);
h = unique(h);
h(strcmpi('uimenu', get(h, 'Type'))) = [];
h(strcmpi('text', get(h, 'Type'))) = [];
h(strcmpi('uicontextmenu', get(h, 'Type'))) = [];

if isempty(h), return; end

h = h(isprop(h, 'Position'));

if isempty(h), return; end

for indx = 1:length(h)
    set(h(indx), 'Position', get(h(indx), 'Position').*SizeRatio);
end

% [EOF]
