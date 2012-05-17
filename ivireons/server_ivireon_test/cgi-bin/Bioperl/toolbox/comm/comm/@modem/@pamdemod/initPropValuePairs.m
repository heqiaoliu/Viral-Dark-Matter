function h = initPropValuePairs(h, varargin)
%INITPROPVALUEPAIRS Initialize/set property-value pairs stored in VARARGIN
%   for the object H. Odd elements of VARARGIN are property names; even
%	elements are property values. Also, set read-only properties.

%	@modem\@pamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:05 $

% list of read only properties
readOnlyProperties = {'Type', 'Constellation'};

baseInitPropValuePairs(h, readOnlyProperties, varargin{:});
%-------------------------------------------------------------------------------

% [EOF]
    
    







