function validateAngle(x,funcname,varname,varargin)
%VALIDATEANGLE Validate angle values
%   validateAngle(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid angles. FUNC_NAME and VAR_NAME are used in
%   VALIDATEATTRIBUTES to come up with the error id and message.
%
%   validateAngle(...,VARARGIN) specifies additional attributes supported
%   in VALIDATEATTRIBUTES, such as sizes and dimensions, in a cell array
%   VARARGIN.
%
%   Example:
%       % Validate whether 30 is a valid angle value.
%       sigdatatypes.validateAngle(30,'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/04 16:31:35 $

validateattributes(x,{'double'},[{'finite','nonnan','nonempty','real'},...
    varargin{:}],funcname,varname);


% [EOF]
