%   Copyright 2009 The MathWorks, Inc.

function varargout = vnvprivate(function_name, varargin)
  
   [varargout{1:nargout}] = feval(function_name, varargin{1:end});
