function [varargout] = private_sl_release_system(varargin)
%Private function used by Simulink.

% Copyright 2005 The MathWorks, Inc.
  
%   Built-in function.

[varargout{1:nargout}] = builtin('private_sl_release_system', varargin{:});
