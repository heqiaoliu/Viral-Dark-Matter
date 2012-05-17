function this = FrequencyVectorVisual(varargin)
%FREQUENCYVECTORVISUAL Construct a FREQUENCYVECTORVISUAL object

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:29:15 $

this = scopeextensions.FrequencyVectorVisual;

this.initVectorVisual(varargin{:});

propertyChanged(this, 'NormalizedFrequencyUnits');
propertyChanged(this, 'YAxisScaling');
setupRange(this);
this.YLabel = getPropValue(this, 'YLabel');

% [EOF]
