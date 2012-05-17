function h = initPropValuePairs(h, varargin)
%INITPROPVALUEPAIRS Initialize/set property-value pairs stored in VARARGIN
%   for the object H. Odd elements of VARARGIN are property names; even
%	elements are property values. Set which properties are read only.

%	@modem\@genqammod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:47 $

% list of read only properties
readOnlyProperties = {'Type', 'M'};

baseInitPropValuePairs(h, readOnlyProperties, varargin{:});
%-------------------------------------------------------------------------------

% [EOF]
    
    







