function hopts = pseudospectrumopts(this,x)
%PSEUDOSPECTRUMOPTS   Create an options object for music and eigenvector
%spectrum objects.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/08/11 15:48:30 $

% Construct default opts object
hopts = dspopts.pseudospectrum;

% Defaults.
isrealX = true;

% Parse input.
if nargin == 2,
    isrealX = isreal(x);
end

if ~isrealX,
    hopts.SpectrumRange = 'whole';
end

% [EOF]
