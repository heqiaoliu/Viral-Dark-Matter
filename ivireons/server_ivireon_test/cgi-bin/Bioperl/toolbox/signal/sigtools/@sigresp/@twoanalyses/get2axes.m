function get2axes(hObj)
%GET2AXES Returns a vector of 2 axes

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:30:11 $

h = get(hObj, 'Handles');
hax = h.axes;

if length(hax) == 1,
    hFig = get(hax, 'Parent');
    
    % Find all axes on the figure
    allhax = findall(hFig, 'Type', 'Axes');
    
    % Remove the input axes
    allhax(allhax == hax) = [];
    
    % See if any axes have the same position as the input axes
    if ~isempty(allhax),
        pos = get(hax, 'Position');
        if ~iscell(pos), pos = {pos}; end
        
        match = zeros(length(pos), 1);
        for indx = 1:length(pos)
            match(indx) = all(pos{indx} - get(hax, 'Position') < sqrt(eps));
        end
        allhax = allhax(match);
    end
    
    % If no axes match the input, create a new one.
    if length(allhax) == 0,
        hax(2) = axes('Parent', hFig, ...
            'Units', get(hax, 'Units'), ...
            'Position', get(hax, 'Position'));
    else
        hax(2) = allhax(1);
    end
    set(hFig, 'CurrentAxes', hax(1));
end

h.axes = hax;
set(hObj, 'Handles', h);

% [EOF]
