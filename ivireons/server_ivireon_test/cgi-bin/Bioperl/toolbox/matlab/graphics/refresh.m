function refresh(h)
%REFRESH Refresh figure.
%   REFRESH causes the current figure window to be redrawn. 
%   REFRESH(FIG) causes the figure FIG to be redrawn.

%   D. Thomas   5/26/93
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.11.4.6 $  $Date: 2009/02/18 02:18:36 $

if nargin==1,
    if ~any(ishghandle(h, 'figure'))
        error('MATLAB:refresh:InvalidHandle', ...
              'Handle does not refer to a figure object')
    end
else
    h = gcf;
end

% The following toggle of the figure color property is
% only to set the 'dirty' flag to trigger a redraw.
color = get(h,'color');
if ~ischar(color) && all(color == [0 0 0])
    tmpcolor = [1 1 1];
else
    tmpcolor = [0 0 0];
end
set(h,'color',tmpcolor,'color',color);
