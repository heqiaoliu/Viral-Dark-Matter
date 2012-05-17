function varargout = sldvshareprivate(function_name, varargin)
%   Copyright 1994-2006 The MathWorks, Inc.
  
   [varargout{1:nargout}] = feval(function_name, varargin{1:end});
