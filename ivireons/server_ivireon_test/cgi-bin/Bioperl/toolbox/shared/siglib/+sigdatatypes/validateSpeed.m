function validateSpeed(x,funcname,varname,varargin)
%VALIDATESPEED Validate speed
%   validateSpeed(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid speed values. FUNC_NAME and VAR_NAME are used in
%   VALIDATEATTRIBUTES to come up with the error id and message.
%
%   validateSpeed(...,VARARGIN) specifies additional attributes supported
%   in VALIDATEATTRIBUTES, such as sizes and dimensions, in a cell array
%   VARARGIN.
%
%   Example:
%       % Validate whether 30 is a valid speed value.
%       sigdatatypes.validateSpeed(30,'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/04 16:31:43 $

validateattributes(x,{'double'},[{'finite','nonnan','nonempty'...
    'nonnegative','<=',3e8},varargin{:}],funcname,varname);


% [EOF]
