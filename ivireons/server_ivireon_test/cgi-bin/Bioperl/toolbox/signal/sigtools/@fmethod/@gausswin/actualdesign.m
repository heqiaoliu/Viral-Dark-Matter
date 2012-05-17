function b = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN <short description>
%   OUT = ACTUALDESIGN(ARGS) <long description>

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:04:41 $

args = designargs(this, hspecs);

N = args{1};
BT = args{2};
sps = args{3};

b = {gaussfir(BT,N/(2*sps),sps)};

% [EOF]
