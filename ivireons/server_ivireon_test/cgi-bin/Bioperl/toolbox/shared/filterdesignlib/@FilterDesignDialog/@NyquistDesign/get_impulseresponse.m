function impulseresponse = get_impulseresponse(this, impulseresponse)
%GET_IMPULSERESPONSE   PreGet function for the 'impulseresponse' property.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:24:38 $

try
    bandvalue = evaluatevars(this.Band);
catch e %#ok<NASGU>
    bandvalue = 3;
end

if bandvalue == 2
    if isempty(impulseresponse)
        impulseresponse = 'FIR';
    end
else
    impulseresponse = 'FIR';
end

% [EOF]
