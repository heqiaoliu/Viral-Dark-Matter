function result = get_safehouse(varargin)
%
%
%

% Copyright 2005 The MathWorks, Inc.

showHHState = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');
safeHouse = double(findobj('type','figure','tag','SF_SAFEHOUSE'));
set(0,'showhiddenhandles', showHHState);

if isempty(safeHouse),
    safeHouse = sf_figure('vis','off','numbertitle','off','pos',[-1000 1000 100 100],'handlevis','off','tag','SF_SAFEHOUSE','CloseRequestFcn','','IntegerHandle','off');
end

if (nargin > 0)

    textobj = double(findobj(safeHouse, 'type', 'text', 'tag', 'EXTENT_CACHE'));
    
    if (isempty(textobj))
        
        chartid = sf('get', 'default', 'chart.id');
        chartaxes = sf ('get', chartid, '.hg.axes');
        newaxes = double(copyobj(chartaxes, safeHouse));
        textobj = double(text('parent', newaxes, 'tag', 'EXTENT_CACHE', 'Interp', 'none', 'DeleteFcn', 'sf(''ClearTextExtentCache'')'));
    end
    result = textobj;
else
   result = safeHouse; 
end
   
