function this = sos(sosMatrix, scales)
%SOS   Construct a SOS object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:20:17 $

this = lwdfilt.sos;

if nargin > 0
    set(this, 'sosMatrix', sosMatrix);
    set(this, 'refsosMatrix', sosMatrix);
    if nargin > 1
        set(this, 'ScaleValues', scales);
        set(this, 'refScaleValues', scales);
    end
end

% [EOF]
