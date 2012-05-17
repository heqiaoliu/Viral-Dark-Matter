function varargout = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN   Design the maximally flat lowpass IIR filter

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:31:26 $

[b,a] = lpprototypedesign(this, hspecs, varargin{:});
[sos, g] = tf2sos(b,a);
varargout = {{sos, g}};

% [EOF]

