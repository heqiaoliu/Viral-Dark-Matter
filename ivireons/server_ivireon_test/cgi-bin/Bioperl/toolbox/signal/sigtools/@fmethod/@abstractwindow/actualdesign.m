function b = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN   Design the lowpass kaiser window.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:27:50 $

args = designargs(this, hspecs);

% Calculate the coefficients using the FIR1 function.
b  = {fir1(args{:})};

% [EOF]
