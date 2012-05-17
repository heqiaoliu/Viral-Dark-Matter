function b = rcoswindesign(this, hspecs, shape)
%RCOSWINDESIGN Design a raised cosine filter

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:04:38 $

args = designargs(this, hspecs);

N = args{1};
beta = args{2};
sps = args{3};

b = {firrcos(N, 0.5, beta, sps, 'rolloff', shape)};

% [EOF]
