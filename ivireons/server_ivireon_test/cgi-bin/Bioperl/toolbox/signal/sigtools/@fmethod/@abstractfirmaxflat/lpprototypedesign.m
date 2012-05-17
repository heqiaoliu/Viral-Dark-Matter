function b = lpprototypedesign(this, hspecs, varargin)
%LPPROTOTYPEDESIGN   Design the prototype lowpass maximally flat FIR which
%   will used for frequency transformation.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:31:14 $

args = designargs(this, hspecs);

% Calculate the coefficients using the MAXFLAT function.
b  = {maxflat(args{1}, 'sym', args{2})};

% [EOF]
