function hh=gtext(string,varargin)
%GTEXT  Place text with mouse.
%   GTEXT('string') displays the graph window, puts up a
%   cross-hair, and waits for a mouse button or keyboard key to be
%   pressed.  The cross-hair can be positioned with the mouse (or
%   with the arrow keys on some computers).  Pressing a mouse button
%   or any key writes the text string onto the graph at the selected
%   location.
%
%   GTEXT(C) places the multi-line strings defined by each row
%   of the cell array of strings C.
%
%   GTEXT(...,'PropertyName',PropertyValue,...) sets the value of
%   the specified text property.  Multiple property values can be set
%   with a single statement.
%
%   Example
%      gtext({'This is the first line','This is the second line'})
%      gtext({'First line','Second line'},'FontName','Times','Fontsize',12)
%
%   See also TEXT, GINPUT.

%   L. Shure, 12-01-88.
%   Revised: Charles D. Packard 3-8-89
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.14.4.5 $  $Date: 2009/10/24 19:17:53 $

if nargin == 0
    error('MATLAB:gtext:TooFewArguments', 'Not enough input arguments.');
end
if rem(nargin,2)~=1,
    error('MATLAB:gtext:ValueExpected', 'Property value pairs expected.')
end
if ~ischar(string) && ~iscellstr(string)
    error('MATLAB:gtext:InvalidArgument', 'Argument must be a string.')
end
[az el] = view;
if az ~= 0 || el ~= 90
    error('MATLAB:gtext:InvalidView', 'View must be two-dimensional.')
end

h = [];
try
    for rows=1:size(string, 1)
        [x,y] = ginput(1);

        % Create a blank text object with correct properties
        ht = text('VerticalAlignment','baseline', varargin{:});
        
        % Set the position in data units and then restore units afterwards
        units = get(ht, 'Units');
        set(ht, 'String', string(rows,:), 'Units', 'data', 'Position', [x y 0]);
        set(ht, 'Units', units);
        
        h = [ht; h]; %#ok<AGROW>
    end
catch err
    if (findstr(err.identifier, 'FigureDeletion'))
        error('MATLAB:gtext:FigureDeletionPause', 'Interrupted by figure deletion');
    elseif (findstr(err.identifier, 'Interrupted'))
        error('MATLAB:gtext:Interrupted', 'Interrupted');
    else
        rethrow(err);
    end
end
if nargout > 0
    hh = h;
end
