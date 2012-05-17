function rref(varargin)
%EML.RREF Pass a parameter by reference to an external C function as a read-only input.
% 
%  Usage:
%  
%  EML.CEVAL('FCN', EML.RREF(u)...)
%    Passes parameter u by reference as a read-only input to the C function 'FCN'.
%    EML.RREF can be used only within a call to EML.CEVAL. 
%
%  To pass a read/write parameter to a C function, use EML.REF; 
%  to pass a write-only parameter, use EML.WREF.
% 
%  Example:
%
%    Consider the following C function foo:
%        
%      double foo(const double* p) { 
%        return *p + 1; 
%      }
% 
%    To invoke foo with a read-only input from Embedded MATLAB, 
%    use the following source code:
%   
%      u = 42.0;
%      y = 0.0; % Constrain return type to double
%      y = eml.ceval('foo', eml.rref(u));
%      % Now y equals 43
% 
%  See also eml.ceval, eml.ref, eml.wref.
%
%  This function can not be used in MATLAB; it applies to Embedded MATLAB only.

%   Copyright 2006-2010 The MathWorks, Inc.
error('eml:rref:NotSupported',...
      'The eml.rref function is not supported in MATLAB');

