function h = initPropValuePairs(h, varargin)
%INITPROPVALUEPAIRS Initialize/set property-value pairs stored in VARARGIN
% for the object H. Odd elements of VARARGIN are property names; even
% elements are property values.

% @doppler\@baseclass

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:36:43 $

nPropValue = length(varargin);
if floor(nPropValue/2) ~= nPropValue/2
    error([getErrorId(h) ':InvalidParamValue'], ['Number of values must be ' ...
                        'same as number of properties.']);
end

for k=1:2:nPropValue
    % set the property
    set(h, varargin{k}, varargin{k+1});
end
%-------------------------------------------------------------------------------

% [EOF]
