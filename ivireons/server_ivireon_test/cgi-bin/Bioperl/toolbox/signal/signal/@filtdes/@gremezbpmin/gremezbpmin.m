function h = gremezlpmin
%GREMEZLP Construct a GREMEZLP object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:07:36 $

h = filtdes.gremezbpmin;

filterType_construct(h);

% [EOF]
