function validateFrequency(x,funcname,varname,varargin)
%VALIDATEFREQUENCY Validate frequency
%   validateFrequency(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid frequency. FUNC_NAME and VAR_NAME are what used in
%   VALIDATEATTRIBUTES to come up error id and messages.
%
%   validateFrequency(...,VARARGIN) specifies additional attributes
%   supported in VALIDATEATTRIBUTES, such as sizes and dimensions, in a
%   cell array VARARGIN.
%
%   Example:
%       % Validate whether 30 is a valid frequency value.
%       sigdatatypes.validateFrequency(30,'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/04 16:31:39 $

validateattributes(x,{'double'},[{'finite','nonempty',...
    'positive'},varargin{:}],funcname,varname);


% [EOF]
