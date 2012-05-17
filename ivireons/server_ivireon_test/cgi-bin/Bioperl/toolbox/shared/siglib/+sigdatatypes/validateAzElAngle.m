function validateAzElAngle(x, funcname, varname, varargin)
%VALIDATEAZELANGLE Validate azimuth and elevation angle matrix
%   validateAzElAngle(X,FUNC_NAME,VAR_NAME) validates whether the input X
%   represents valid [azimuth;elevation] angle matrix. FUNC_NAME and
%   VAR_NAME are used in VALIDATEATTRIBUTES to come up with the error id
%   and message.
%
%   validateAzElAngle(...,VARARGIN) specifies additional attributes
%   supported in VALIDATEATTRIBUTES, such as sizes and dimensions, in a
%   cell array VARARGIN.
%
%   Example:
%       % Validate whether [0;0] is a valid azimuth and elevation angle 
%       % pair.
%       sigdatatypes.validateAzElAngle([0 0],'foo','bar');

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/04 16:31:36 $

validateattributes(x,{'double'},[{'finite','nonnan','nonempty','real',...
    '2d'},varargin{:}],funcname,varname);

if size(x,2) ~= 2
    error('MATLAB:expectedTwoColumns', 'Expected %s to have 2 columns.', varname);
end

validateattributes(x(:,1),{'double'},{'<=',180,'>=',-180},funcname,...
    'Azimuth angles');

validateattributes(x(:,2),{'double'},{'<=',90,'>=',-90},funcname,...
    'Elevation angles');


% [EOF]
