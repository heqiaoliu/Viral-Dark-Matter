function p = propstosync(this)
%PROPSTOSYNC   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 19:02:34 $

p = get(classhandle(this), 'Properties');

p = find(p, 'AccessFlags.PublicSet', 'On', '-not', 'Name', 'Fs','-not','Name','NormalizedFrequency');

p = get(p, 'Name');

if ~iscellstr(p)
    p = {p};
end

p = thispropstosync(this,p);

% [EOF]
