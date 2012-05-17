function setpixelpos(this, field, varargin)
%SETPIXELPOS Set a handle's position in pixels.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:19:48 $

error(nargchk(3,inf,nargin,'struct'));

% Get the handle if we are passed a field
if ischar(field),
    field = this.Handles.(field);
    for indx = 1:length(varargin)-1
        if ischar(varargin{indx});
            field = field.(varargin{indx});
        else
            field = field(varargin{indx});
        end
    end
    pos = varargin{end};
else
    pos = varargin{1};    
end

origUnits = get(field, 'Units');
set(field, 'Units', 'Pixels');
set(field, 'Position', pos);
if ~iscell(origUnits), origUnits = {origUnits}; end
for indx = 1:length(origUnits),
    set(field(indx), 'Units', origUnits{indx});
end

% [EOF]
