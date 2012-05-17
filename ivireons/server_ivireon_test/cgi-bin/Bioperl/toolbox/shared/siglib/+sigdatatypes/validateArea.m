function x = validateArea(x,funcname,varname,varargin)
%VALIDATEAREA Validate area values
%   validateArea(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid area. FUNC_NAME and VAR_NAME are used in
%   VALIDATEATTRIBUTES to come up with the error id and message.
%
%   validateArea(...,VARARGIN) specifies additional attributes supported in
%   VALIDATEATTRIBUTES, such as sizes and dimensions, in a cell array
%   VARARGIN.
%
%   Example:
%       % Validate whether 30 is a valid area.
%       sigdatatypes.validateArea(30,'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:06:06 $

validateattributes(x,{'double'},[{'nonnan','nonempty','nonnegative'},...
    varargin{:}],funcname,varname);

% [EOF]
