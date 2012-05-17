function h = iircomb
%IIRCOMB Construct an IIRCOMB object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:21:10 $

h = filtdes.iircomb;

set(h, 'Tag', 'IIR Comb');

singleOrder_construct(h);

% [EOF]
