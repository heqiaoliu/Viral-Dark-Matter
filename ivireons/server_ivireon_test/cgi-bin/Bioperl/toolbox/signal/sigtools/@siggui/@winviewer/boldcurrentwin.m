function boldcurrentwin(hView, index)
%BOLDCURRENTWIN Bold the current window

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/12/14 15:20:19 $

if ~isrendered(hView),
    return
end

% Get the line handles
hndls = get(hView, 'Handles');
haxtd = hndls.axes.td;
haxfd = hndls.axes.fd;
htline = findobj(haxtd, 'Tag' , 'tline');
hfline = findobj(haxfd, 'Tag' , 'fline');

if index > length(htline),
    error(generatemsgid('IdxOutOfBound'),'Index exceeds the number of windows.');
end

% Unbold all
set(htline, 'LineWidth', 1);
set(hfline, 'LineWidth', 1);

if ~isempty(index),
    
    % Bold the current window
    if index>0 & length(htline) > 1,
        set(htline(index), 'LineWidth', 2);
        set(hfline(index), 'LineWidth', 2);
    end
end

% [EOF]
