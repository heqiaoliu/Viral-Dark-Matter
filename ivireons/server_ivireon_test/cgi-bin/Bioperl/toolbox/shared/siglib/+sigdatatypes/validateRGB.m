function x = validateRGB(x,funcname,varname)
%validateRGB Validate RGB values
%   X = sigdatatypes.validateRGB(X,FUNC_NAME,VAR_NAME) validates whether the
%   input, X, represents a valid RGB value represented as a double 1x3 row
%   vector with values between 0 and 1, and returns X. FUNC_NAME and
%   VAR_NAME are used in VALIDATEATTRIBUTES to come up with the error id and
%   message.
%
%   When used for checking method arguments, FUNC_NAME, must be the method
%   name in "package.class.method" format, and VAR_NAME must be the argument
%   name.
%
%   When used for checking property values, FUNC_NAME, must be the property
%   name in "package.class.property" format, and VAR_NAME must be the
%   property name.
%
%   % Example: Validate whether [0.5 0.5 0.5] is a valid RGB value to be
%   %          used in the Background property of pck.MyObject class. 
%     a = [0.5 0.5 0.5];
%     sigdatatypes.validateRGB(a,'pck.MyObject.Background','Background');

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/26 17:50:32 $

validateattributes(x,{'double'}, ...
  {'<=',1,'>=',0,'nonempty','real', 'size', [1 3]}, ...
  funcname, varname);

% [EOF]