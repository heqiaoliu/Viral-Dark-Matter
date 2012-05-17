function loadmetadata(this, s)
%LOADMETADATA   Load the meta data.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:33:41 $

if isstruct(s)
    hfd = s.fdesign;
    designMethodStr = '';
    if s.version.number > 0
        if s.version.number > 2 && isfield(s, 'measurements')
            setmeasurements(this, s.measurements);
            if isfield(s, 'privdesignmethod')
                designMethodStr = s.designmethod;
            end
        end
        hfm = s.fmethod;
    else
        hfm = [];
    end
else
    hfd = getfdesign(s);
    hfm = getfmethod(s);
    designMethodStr = s.privdesignmethod;
end

setfdesign(this, hfd);
setfmethod(this, hfm);
set(this, 'privdesignmethod', designMethodStr);

% [EOF]
