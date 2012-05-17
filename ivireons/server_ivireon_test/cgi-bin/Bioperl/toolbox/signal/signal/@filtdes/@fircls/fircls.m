function h = fircls
%FIRCLS Construct a FIRCLS design object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:06:27 $

h = filtdes.fircls;

singleOrder_construct(h);

set(h, 'Tag', 'FIR constrained least-squares');

% [EOF]
