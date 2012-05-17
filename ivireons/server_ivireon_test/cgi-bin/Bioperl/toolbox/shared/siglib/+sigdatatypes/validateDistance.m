function x = validateDistance(x,funcname,varname,varargin)
%VALIDATEDISTANCE Validate distance values
%   validateDistance(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid distances. FUNC_NAME and VAR_NAME are used in
%   VALIDATEATTRIBUTES to come up with the error id and message.
%
%   validateDistance(...,VARARGIN) specifies additional attributes
%   supported in VALIDATEATTRIBUTES, such as sizes and dimensions, in a
%   cell array VARARGIN.
%
%   Example:
%       % Validate whether 30 is a valid distance.
%       sigdatatypes.validateDistance(30,'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/20 03:06:07 $

validateattributes(x,{'double'},[{'nonnan','nonempty','nonnegative'},...
    varargin{:}],funcname,varname);

% [EOF]
