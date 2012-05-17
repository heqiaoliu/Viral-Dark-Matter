function options = parseParameterValuePairs(funcName, knownParams, varargin)
%parseParameterValuePairs   Get user-provided and default options.
%    OPTIONS = parseParameterValuePairs(FUNCNAME, DETAILS, PARAM1, VALUE1, ...)
%    parses and validates a set of parameter-value pairs.  FUNCNAME is a
%    character array containing the name of the function that accepts
%    various parameters (PARAM1, etc.) and values (VALUE1, etc.).  DETAILS
%    is a cell array with one row per known parameter and has the following
%    columns:
%
%        1 - Parameter name  (character array)
%        2 - Output field name  (character array)
%        3 - Default parameter value  (any value)
%        4 - Acceptable value type  (cell array of MATLAB types)
%        5 - Value parameters  (cell array of iptcheckinput values)
%
%    The output value OPTIONS is a structure array whose field names are
%    the parameters and whose values are the corresponding values.  The 
%    field names of OPTIONS may not actually match the parameter names
%    expected by FUNCNAME, depending on the values in the second column of
%    DETAILS.  This allows convenient field names for internal use.
%
%    See also IPTCHECKINPUT, IPTCHECKSTRS.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:22:59 $

% Create a structure with default values, and map actual param-value pair
% names to convenient names for internal use.

options = cell2struct(knownParams(:,3), knownParams(:,2), 1);

if (rem(nargin, 2) ~= 0)
    error(['Images:' funcName ':paramValuePairs'], ...
          'Named parameters must have a corresponding value.')
end

% Loop over the P-V pairs.
for p = 1:2:numel(varargin)
    % Get the parameter name.
    paramName = varargin{p};
    if (~ischar(paramName))
        error(['Images:' funcName ':badParamName'], ...
              'Parameter names must be character arrays.')
    end
    
    % Look for the parameter amongst the possible values.
    idx = strmatch(lower(paramName), lower(knownParams(:,1)));
    if (isempty(idx))
        error(['Images:' funcName ':unknownParamName'], ...
              'Unknown parameter "%s".', paramName);
    elseif (numel(idx) > 1)
        error(['Images:' funcName ':ambiguousParamName'], ...
              'Ambiguous parameter "%s".', paramName);
    end

    % Validate the value.
    options.(knownParams{idx, 2}) = varargin{p+1};
    iptcheckinput(varargin{p+1}, ...
                  knownParams{idx,4}, ...
                  knownParams{idx,5}, ...
                  funcName, ...
                  knownParams{idx,1}, ...
                  p+2);  % p+2 = Param name + 1 + offset to first arg
end
