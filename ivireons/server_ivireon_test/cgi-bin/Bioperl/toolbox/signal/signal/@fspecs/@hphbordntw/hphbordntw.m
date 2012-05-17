function h = hphbordntw
%HPHBORDNTW   Construct a HPHBORDNTW object.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:14:10 $

h = fspecs.hphbordntw;

h.ResponseType = 'Highpass halfband with filter order and transition width';
% [EOF]
