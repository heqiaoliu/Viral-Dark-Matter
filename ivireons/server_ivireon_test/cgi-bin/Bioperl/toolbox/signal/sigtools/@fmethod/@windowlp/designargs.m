function args = designargs(this, hspecs)
%DESIGNARGS   Return the arguments for FIR1

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:27:57 $


% If we are passed a window function, use it to calculate the window vector
win = calculatewin(this, hspecs.FilterOrder);

% Add scaling flag to the inputs
flag = getscalingflag(this);

args = {hspecs.FilterOrder, hspecs.Fc, win{:}, flag};

% [EOF]
