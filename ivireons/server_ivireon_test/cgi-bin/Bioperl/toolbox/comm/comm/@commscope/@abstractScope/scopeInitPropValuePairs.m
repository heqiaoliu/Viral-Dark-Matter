function this = scopeInitPropValuePairs(this, readOnlyProperties, varargin)
%SCOPEINITPROPVALUEPAIRS Initialize/set property-value pairs stored in VARARGIN
%   for the object THIS. Odd elements of VARARGIN are property names; even
%	elements are property values. Set which properties are read only.

%	@commscope\@abstractScope

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:17:58 $

% Update list of read only properties
readOnlyProperties = [readOnlyProperties, 'SymbolRate'];

baseInitPropValuePairs(this, readOnlyProperties, varargin{:});
%-------------------------------------------------------------------------------
% [EOF]
