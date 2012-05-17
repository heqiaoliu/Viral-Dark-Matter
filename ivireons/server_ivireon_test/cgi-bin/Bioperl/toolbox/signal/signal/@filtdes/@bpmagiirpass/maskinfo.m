function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/06/25 13:17:50 $

mu = get(d, 'magUnits');
if strcmpi(mu, 'db'),
    apass = get(d, 'Apass');
else
    apass = get(d, 'Epass');
end

cmd{1} = [];

cmd{2}.magfcn     = 'cpass';
cmd{2}.amplitude  = apass;
cmd{2}.filtertype = 'bandpass';
cmd{2}.magunits   = mu;

cmd{3} = [];

% [EOF]
