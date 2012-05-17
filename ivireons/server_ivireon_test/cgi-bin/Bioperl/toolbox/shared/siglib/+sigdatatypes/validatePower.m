function validatePower(x,funcname,varname,varargin)
%VALIDATEPOWER Validate power values
%   validatePower(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid power. FUNC_NAME and VAR_NAME are used in
%   VALIDATEATTRIBUTES to come up with the error id and message.
%
%   validatePower(...,VARARGIN) specifies additional attributes
%   supported in VALIDATEATTRIBUTES, such as sizes and dimensions, in a
%   cell array VARARGIN.
%
%   Example:
%       % Validate whether 30 is a valid power.
%       sigdatatypes.validatePower(30,'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/04 16:31:41 $

validateattributes(x,{'double'},[{'finite','nonnan','nonempty',...
    'nonnegative'},varargin{:}],funcname,varname);

% [EOF]
