function this = initPropValuePairs(this, varargin)
%INITPROPVALUEPAIRS Initialize/set property-value pairs stored in VARARGIN
%   for the object THIS. Odd elements of VARARGIN are property names; even
%	elements are property values. Set which properties are read only.

%	@commscope\@eyediagram

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/07 18:18:33 $

% list of read only properties
readOnlyProperties = {'SamplesProcessed'};

scopeInitPropValuePairs(this, readOnlyProperties, varargin{:});
%-------------------------------------------------------------------------------
% [EOF]
