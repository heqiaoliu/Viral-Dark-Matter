function validateIndex(x,funcname,varname,varargin)
%VALIDATEINDEX Validate index value
%   validateIndex(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid index values. FUNC_NAME and VAR_NAME are used in
%   VALIDATEATTRIBUTES to come up with the error id and message.
%
%   validateIndex(...,VARARGIN) specifies additional attributes supported
%   in VALIDATEATTRIBUTES, such as sizes and dimensions, in a cell array
%   VARARGIN.
%
%   Example:
%       % Validate whether 30 is a valid index value.
%       sigdatatypes.validateIndex(30,'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/04 16:31:40 $

validateattributes(x,{'double'},[{'finite','nonnan','nonempty',...
    'positive','integer'}, varargin{:}],funcname,varname);

%targetEcho

% [EOF]
