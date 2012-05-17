function sout = convertstatestruct(hObj, sin)
%CONVERTSTATESTRUCT Convert the state structure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/11/21 15:29:17 $

sout = [];

if isfield(sin.mag, 'rcos'),
    sout.Tag       = class(hObj);
    sout.Version   = 0;
    
    switch lower(sin.mag.rcos.designtype)
        case 'sqrt'
            sout.DesignType = 'square root';
        otherwise
            sout.DesignType = sin.mag.rcos.designtype;
    end
end

% [EOF]
