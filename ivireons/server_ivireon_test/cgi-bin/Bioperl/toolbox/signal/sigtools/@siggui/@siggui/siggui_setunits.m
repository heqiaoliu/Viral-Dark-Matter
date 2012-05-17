function siggui_setunits(this, units)
%SIGGUI_SETUNITS Sets all units in the frame

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.2.4.5 $  $Date: 2009/01/05 18:01:19 $

error(nargchk(2,2,nargin,'struct'));

if isempty(this.Container) || ~ishghandle(this.Container)

    hvec = handles2vector(this);

    if ~isempty(hvec)
        % Remove all objects that do not have a Units property.
        hvec(~isprop(hvec, 'units')) = [];
        
        % Remove Text objects.  Do not set their units.
        hvec(ishghandle(hvec, 'text')) = [];
        
        set(hvec,'units',units);
    end
else
    set(this.Container, 'Units', units)
end

% [EOF]
