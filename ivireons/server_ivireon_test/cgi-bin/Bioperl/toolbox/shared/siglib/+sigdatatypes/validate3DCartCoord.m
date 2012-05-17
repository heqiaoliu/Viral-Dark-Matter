function validate3DCartCoord(x, funcname, varname, varargin)
%VALIDATE3DCARTCOORD Validate 3D coordinates
%   validate3DCartCoord(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid 3D coordinates. FUNC_NAME and VAR_NAME are used
%   in VALIDATEATTRIBUTES to come up with the error id and message.
%
%   validate3DCartCoord(...,VARARGIN) specifies additional attributes
%   supported in VALIDATEATTRIBUTES, such as sizes and dimensions, in a
%   cell array VARARGIN.
%
%   Example:
%       % Validate whether [1,1,1] is a valid 3D coordinates.
%       sigdatatypes.validate3DCartCoord([1 1 1],'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/04 16:31:34 $

validateattributes(x,{'double'},[{'finite','nonnan','nonempty','real',...
    '2d'},varargin{:}],funcname,varname);

if size(x,2) ~= 3
    error('MATLAB:expectedThreeColumn', 'Expected %s to have 3 columns.', varname);
end


% [EOF]
