function h = hphbordastop
%HPHBORDASTOP   Construct a HPHBORDASTOP object.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:14:07 $

h = fspecs.hphbordastop;

h.ResponseType = 'Highpass halfband with filter order and stopband attenuation';
% [EOF]
