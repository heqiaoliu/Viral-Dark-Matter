function pos = getpixelpos(this, field, varargin)
%GETPIXELPOS Get the position in pixel units.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:10:38 $

error(nargchk(2,inf,nargin,'struct'));

if ischar(field),
    field = this.Handles.(field);
    for indx = 1:length(varargin)
        if ischar(varargin{indx});
            field = field.(varargin{indx});
        else
            field = field(varargin{indx});
        end
    end
end

pos = getpixelposition(field);

% [EOF]
