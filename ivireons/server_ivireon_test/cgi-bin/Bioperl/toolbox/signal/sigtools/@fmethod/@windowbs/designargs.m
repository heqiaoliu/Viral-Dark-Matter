function args = designargs(this, hspecs)
%DESIGNARGS   Return the arguments for FIR1

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:27:55 $

N = get(hspecs, 'FilterOrder');

% If we are passed a window function, use it to calculate the window vector
win = calculatewin(this, N);

% Add scaling flag to the inputs
flag = getscalingflag(this);

args = {N, [hspecs.Fcutoff1 hspecs.Fcutoff2], 'stop', win{:}, flag};

if rem(N, 2)
    args{end+1} = 'h';
end

% [EOF]
