function legend(this, varargin)
%LEGEND   Turn on the legend

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/10/18 21:11:01 $

Hd   = get(this, 'Filters');

% If the 2nd to last input is "location" we assume this is not a filter
% name as long as the next input matches one of the valid "locations".
if nargin > 2 & strcmpi(varargin{end-1}, 'location') & ...
        any(strncmpi(varargin{end}, {'North', 'South', 'East', 'West', ...
        'NorthEast', 'NorthWest', 'SouthEast', 'SouthWest', ...
        'NorthOutside', 'SouthOutside', 'EastOutside', 'WestOutside', ...
        'NorthEastOutside', 'NorthWestOutside', 'SouthEastOutside', ...
        'SouthWestOutside', 'Best', 'BestOutside'}, length(varargin{end}))) %#ok
    set(this, 'LegendPosition', varargin{end});
    varargin(end-1:end) = [];
elseif nargin > 1 & isnumeric(varargin{end}) %#ok
    
    % If the last input is a # it must be the old style legend location.
    set(this, 'LegendPosition', varargin{end});
    varargin(end) = [];
else
    
    % If we dont have any of these special cases, put the legend in the
    % "best" location given the plots.
    set(this, 'LegendPosition', 'Best');
end

strs = varargin;

% Warn if more strings are given than there are filters.
nstr = length(strs);
if nstr > length(Hd),
    warning(generatemsgid('TooManyStrings'), ...
        'More strings were provided than filters, ignoring extra strings.');
end

% Assign the strings to the names of the filters.
for indx = 1:min(nstr,length(Hd))
    set(Hd(indx), 'Name', strs{indx});
end

% Turn the legend on.
if strcmpi(this.Legend, 'Off'),
    set(this, 'Legend', 'On');
else
    
    % If it is already on, delete it to force it to refresh.
    deletehandle(this, 'legend');
    updatelegend(this);
end

% [EOF]
