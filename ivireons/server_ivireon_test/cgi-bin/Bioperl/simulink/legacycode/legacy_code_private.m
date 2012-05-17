function varargout = legacy_code_private(varargin)
%LEGACY_CODE_PRIVATE is a gateway for internal support functions used by 
%   LEGACY CODE TOOL.
%
%   VARARGOUT = LEGACY_CODE_PRIVATE('FUNCTION_NAME', VARARGIN) 
%

%   Copyright 2005-2007 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.6.2 $
%   $Date: 2007/11/17 23:33:26 $

[varargout{1:nargout}] = slprivate(varargin{:});
