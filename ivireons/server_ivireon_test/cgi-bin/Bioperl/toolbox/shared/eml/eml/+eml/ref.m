function ref(varargin)
%EML.REF Pass a parameter by reference to an external C function as a read/write input.
% 
%  Usage:
%
%  EML.CEVAL('FCN', EML.REF(u)...)
%    Passes parameter u by reference as a read/write input to the C function FCN.
%    EML.REF can be used only within a call to EML.CEVAL.  
% 
%  To pass a read-only parameter to a C function, use EML.RREF; to pass a 
%  write-only parameter, use EML.WREF.
% 
%  Example:
%    Consider the following C function foo:
%
%      void foo(double* p) { 
%        *p = *p + 1; 
%      }
% 
%    To invoke foo with a read/write input from Embedded MATLAB, use the 
%    following source code:
%   
%      u = 42.0;
%      y = eml.ceval('foo', eml.ref(u));
%      % Now y equals 43
% 
%  See also eml.ceval, eml.wref, eml.rref.
%
%  This function can not be used in MATLAB; it applies to Embedded MATLAB only.

%   Copyright 2006-2010 The MathWorks, Inc.
error('eml:ref:NotSupported','The eml.ref function is not supported in MATLAB');

