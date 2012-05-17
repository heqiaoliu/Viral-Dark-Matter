function [F, A] = getmask(this, varargin)
%GETMASK  Get the mask.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/04 23:21:12 $

[F, A] = getmask(this.PulseShapeObj, varargin{:});

% [EOF]
