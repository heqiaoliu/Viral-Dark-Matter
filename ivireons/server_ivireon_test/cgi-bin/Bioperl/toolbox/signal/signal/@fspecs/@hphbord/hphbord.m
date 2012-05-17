function h = hphbord
%HPHBORD   Construct a HPHBORD object.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:14:04 $

h = fspecs.hphbord;

h.ResponseType = 'Highpass halfband with filter order';
% [EOF]
