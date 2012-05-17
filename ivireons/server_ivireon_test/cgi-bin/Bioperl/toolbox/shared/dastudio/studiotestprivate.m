%STUDIOTESTPRIVATE is a gateway for internal support functions used by 
%           Simulink Studio test cases.
%   VARARGOUT = STUDIOTESTPRIVATE('FUNCTION_NAME', VARARGIN) 
%   
%   

%   Copyright 2009 The MathWorks, Inc.

function varargout = studiotestprivate(function_name, varargin)
  
   [varargout{1:nargout}] = feval(function_name, varargin{1:end});

