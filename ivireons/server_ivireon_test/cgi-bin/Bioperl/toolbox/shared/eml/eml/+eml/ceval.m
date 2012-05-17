function ceval(varargin)
%EML.CEVAL Call external C functions from Embedded MATLAB code.
% 
%  Usage:
%
%  EML.CEVAL('FCN') 
%    Calls the external C function FCN.
% 
%  EML.CEVAL('FCN',X1,...XN) 
%    Calls the external C function FCN, passing input parameters X1 through XN.
%   
%  Y = EML.CEVAL('FCN') 
%    Calls the external C function FCN and assigns the return value to the variable Y.
% 
%  Y = EML.CEVAL('FCN',X1,..XN) 
%    Calls the external C function FCN, passing input parameters X1,..XN, 
%    and assigning the return value to the variable Y.
%    
%  By default, eml.ceval passes input parameters and return values by value. 
%  To pass the address of a MATLAB entity X to an external C function, use the 
%  following operators:
%
%    eml.ref(X) to pass X as a read/write input parameter
%    eml.rref(X) to pass X as a read-only input parameter
%    eml.wref(X) to pass X as a write-only input parameter
%  
%  For example, to call a C function fcn that returns array A, use the following code:
% 
%    eml.ceval('fcn',eml.wref(A));
% 
%  To call a C function fcn that returns two outputs, A and B 
%  (even if they are not arrays), use the following code:
% 
%    eml.ceval('fcn',eml.wref(A),eml.wref(B));
% 
%  When the address of a global entity is passed via eml.ref, eml.rref or eml.wref 
%  and stored inside the custom code, use the '-global' flag to specify that the 
%  address has escaped. This enables synchronization for globals accessed indirectly 
%  inside the custom code.
%
%    eml.ceval('-global','fcn',eml.ref(globalVar));
%
%  See also eml.ref, eml.rref, eml.wref.
%
%  This function can not be used in MATLAB; it applies to Embedded MATLAB only.

%   Copyright 2006-2010 The MathWorks, Inc.
error('eml:ceval:NotSupported', ...
      'The eml.ceval function is not supported in MATLAB');
