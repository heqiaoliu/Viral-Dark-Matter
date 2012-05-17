function varargout = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN   Design the maximally flat lowpass FIR filter

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:31:21 $

[varargout{1:nargout}] = lpprototypedesign(this, hspecs, varargin{:});

% [EOF]
