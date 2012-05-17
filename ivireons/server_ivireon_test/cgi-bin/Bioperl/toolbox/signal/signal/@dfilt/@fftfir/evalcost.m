function c = evalcost(this)
%EVALCOST   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/10/14 16:25:58 $

error(generatemsgid('InvalidStructure'),...
    'The FFTFIR structure does not support the cost method.');

% [EOF]
