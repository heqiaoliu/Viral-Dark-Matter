function frequnits = setfrequnits(this, frequnits)
%SETFREQUNITS   Set the frequnits parameter.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:59 $

if strcmpi(get(this, 'NormalizedFrequency'), 'Off'),

    hPrm = getparameter(this, 'frequnits');
    if ~isempty(hPrm), setvalue(hPrm, frequnits); end
else
    set(this, 'CachedFrequencyUnits', frequnits);
end

% [EOF]
