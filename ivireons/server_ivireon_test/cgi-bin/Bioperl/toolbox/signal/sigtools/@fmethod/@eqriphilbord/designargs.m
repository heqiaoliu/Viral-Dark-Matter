function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:43:58 $


TWn = hs.TransitionWidth/2;

args = {hs.FilterOrder, [TWn 1-TWn], [1 1],'hilbert'};

% [EOF]
