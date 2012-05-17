function setdatamarkers(hcbo,eventStruct,dataMarkerFcn)
%SETDATAMARKERS Set interactive data markers. 
%   SETDATAMARKERS is used as the 'ButtonDownFcn' of a line
%   in order to enable Data Markers.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2008/12/04 23:24:04 $ 

hFig = ancestor(hcbo, 'figure');

if isappdata(hFig, 'DataCursorManager')
    hDCM = getappdata(hFig, 'DataCursorManager');
else
    hDCM = graphics.datacursormanager(hFig);
    setappdata(hFig, 'DataCursorManager', hDCM);
end

% This is a workaround to resolve the datacursor bug in pole/zero plots.
set(hDCM, 'EnableZStacking', 0);

hB = hgbehaviorfactory('datacursor');

if nargin < 3,
    hB.UpdateFcn = @stringFcn;
else
    hB.UpdateFcn = dataMarkerFcn;
end

hgaddbehavior(hcbo,hB);

h = hDCM.createDatatip(hcbo);

% Build uicontextmenu handle for marker text
h.UIContextMenu = uicontextmenu('Parent',ancestor(hcbo,'hg.figure'));
datacursormenus(hDCM,'alignment','fontsize','movable','interpolation', 'export','delete','deleteall');

% -------------------------------------------------------------------------
function dataTip = stringFcn(hLine, eventData)
hAx  = ancestor(hLine, 'axes');

hxlbl = get(hAx,'Xlabel'); xlbl = get(hxlbl,'String'); 
hylbl = get(hAx,'Ylabel'); ylbl = get(hylbl,'String'); 

%trim the brackets part to get the shorter version label
xlbl = localTrimBrackets(xlbl);
ylbl = localTrimBrackets(ylbl);

dataTip = sprintf('%s: %.7g\n%s: %.7g', xlbl, eventData.Position(1), ...
    ylbl, eventData.Position(2));

function output = localTrimBrackets(input)
idx = findstr(input, '(');
if ~isempty(idx)
    output = strtrim(input(1:idx-1));
else
    output = strtrim(input);
end
% [EOF] 