function this = UserDefinedVectorVisual(varargin)
%VECTORVISUAL Construct a VECTORVISUAL object

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/09/09 21:29:38 $

this = scopeextensions.UserDefinedVectorVisual;

this.initVectorVisual(varargin{:});

this.InheritSampleRate = getPropValue(this, 'InheritSampleIncrement');
this.DisplayBuffer = getPropValue(this, 'DisplayBuffer');
this.XLabel        = getPropValue(this, 'XLabel');
this.YLabel        = getPropValue(this, 'YLabel');
this.UsesEngineeringUnits = false;

% [EOF]
