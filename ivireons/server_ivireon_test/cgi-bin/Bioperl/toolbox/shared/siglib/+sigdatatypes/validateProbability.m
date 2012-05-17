function x = validateProbability(x, funcname, varname, varargin)
%VALIDATEPROBABILITY Validate probability value
%   validateProbability(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid probability values. FUNC_NAME and VAR_NAME are 
%   used in VALIDATEATTRIBUTES to come up with the error id and message.
%
%   validateProbability(...,VARARGIN) specifies additional attributes
%   supported in VALIDATEATTRIBUTES, such as sizes and dimensions, in a
%   cell array VARARGIN.
%
%   Example:
%       % Validate whether 0.5 is a valid probability value.
%       sigdatatypes.validateProbability(0.5,'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/20 03:06:08 $

validateattributes(x,{'double'},[{'finite','nonnan','nonempty',...
    '>=',0,'<=',1,'real'}, varargin{:}],funcname,varname);



% [EOF]
