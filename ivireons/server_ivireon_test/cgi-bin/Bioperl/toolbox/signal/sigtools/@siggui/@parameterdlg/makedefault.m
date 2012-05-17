function makedefault(this)
%MAKEDEFAULT   Make these parameters the defaults.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:24:47 $

hPrm = get(this, 'Parameters');

% We do not save disabled or static parameters.
for indx = 1:length(this.DisabledParameters)
    hPrm = find(hPrm, '-not', 'tag', this.DisabledParameters{indx});
end

for indx = 1:length(this.StaticParameters)
    hPrm = find(hPrm, '-not', 'tag', this.StaticParameters{indx});
end

if isempty(hPrm), return; end

values = getvaluesfromgui(this, hPrm);

makedefault(hPrm, this.Tool, values);

% [EOF]
