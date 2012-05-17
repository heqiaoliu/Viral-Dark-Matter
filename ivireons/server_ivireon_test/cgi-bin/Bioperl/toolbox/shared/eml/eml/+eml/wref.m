function wref(varargin)
%EML.WREF Pass a parameter by reference to an external C function as a write-only input.
% 
%  Usage:
% 
%  EML.CEVAL('FCN', EML.WREF(u)...)
%    Passes parameter u by reference as a write-only input to the C function 'FCN'.
%    EML.WREF can be used only within a call to EML.CEVAL. 
%
%  The following conditions apply: 
%
%  - Function FCN must fully initialize u by assigning a value to every element of u.
%  - Function FCN may not read u prior to writing to it because the initial value 
%    of u is undefined.
%  - If there are prior assignments to u, the compiler is allowed to remove them.
%
%  Example:
%
%    Consider the following C function init:
%        
%      void init(double* array, int numel) { 
%        for(int i = 0; i < numel; i++) {
%          array[i] = 42;
%        }
%      }
% 
%    To invoke init with a write-only input from Embedded MATLAB, 
%    use the following source code:
% 
%      % Constrain output to an int8 matrix.
%      % This assignment can be removed by the compiler,
%      % because init is expected to fully define y.
%      y = zeros(5, 10, 'double');     
%      eml.ceval('init', eml.wref(y), numel(y));
%      % Now all elements of y equal 42
% 
%  See also eml.ceval, eml.rref, and eml.ref.
%
%  This function can not be used in MATLAB; it applies to Embedded MATLAB only.

%   Copyright 2006-2010 The MathWorks, Inc.
error('eml:wref:NotSupported',...
      'The eml.wref function is not supported in MATLAB');

