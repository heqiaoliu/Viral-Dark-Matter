% GenericStudioPrivate is a gateway for internal support functions used by 
%           the Generic M3I studio.
%   VARARGOUT = GenericStudioPrivate('FUNCTION_NAME', VARARGIN) 
%   
%  
%   Copyright 2007-2008 The MathWorks, Inc.

function varargout = GenericStudioPrivate(function_name, varargin)
   [varargout{1:nargout}] = feval(function_name, varargin{1:end});