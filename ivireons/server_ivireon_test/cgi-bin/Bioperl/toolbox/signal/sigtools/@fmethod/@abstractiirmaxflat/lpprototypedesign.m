function [b, a] = lpprototypedesign(this, hspecs, varargin)
%LPPROTOTYPEACTUALDESIGN   Design the prototype lowpass IIR filter which
%   will be used for maxflat design of highpass, bandpass and bandstop
%   filters by frequency transformation.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:31:19 $

% Calculate the coefficients using the MAXFLAT function. 
args = designargs(this, hspecs);
[b,a] = maxflat(args{:}, varargin{:});

% [EOF]
