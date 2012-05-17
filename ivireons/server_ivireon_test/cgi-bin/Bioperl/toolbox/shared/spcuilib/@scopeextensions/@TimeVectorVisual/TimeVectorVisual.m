function this = TimeVectorVisual(varargin)
%TIMEVECTORVISUAL Construct a TIMEVECTORVISUAL object

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:29:36 $

this = scopeextensions.TimeVectorVisual;

this.initVectorVisual(varargin{:});

this.DisplayBuffer = getPropValue(this, 'DisplayBuffer');
this.YLabel        = getPropValue(this, 'YLabel');
this.XLabel        = 'Time (<units>s)';

% [EOF]
