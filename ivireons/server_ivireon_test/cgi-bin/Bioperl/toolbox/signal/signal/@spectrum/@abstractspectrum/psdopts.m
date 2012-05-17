function hopts = psdopts(this,x)
%PSDOPTS   Create an options object for a spectrum object.
%

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/06/13 15:29:45 $

% Construct default opts object
hopts = dspopts.spectrum;

% Defaults.
isrealX = true;

% Parse input.
if nargin == 2,
    isrealX = isreal(x);
end

if ~isrealX,
    hopts.SpectrumType = 'twosided';
end

% [EOF]
