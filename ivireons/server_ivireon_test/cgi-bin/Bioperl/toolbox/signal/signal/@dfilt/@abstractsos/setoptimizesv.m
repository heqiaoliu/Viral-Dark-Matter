function OptimizeScaleValues = setoptimizesv(this, OptimizeScaleValues)
%SETOPTIMIZESV   PreSet function for the 'OptimizeScaleValues' property.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:35:46 $

this.privOptimizeScaleValues = OptimizeScaleValues;

% Quantize the coefficients
quantizecoeffs(this);

% [EOF]
