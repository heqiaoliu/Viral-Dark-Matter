function [SYS, varargout] = linearize(this, varargin)
% LINEARIZE Linearizes the model at the specified operating point.
%
% SYS = this.linearize(oppts, linearizationios, linoptions)
% SYS = this.linearize(times, linearizationios, linoptions)
%
% SYS is linear time-invariant state-space model.
% LINEARIZATIONIOS is an array of LINEARIZATIONIO objects.
% LINOPTIONS is a linearization options object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:53:38 $

SYS = [];

nout = max(nargout,1) - 1;
if nout > 0
  varargout(1:nout) = {[]};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
