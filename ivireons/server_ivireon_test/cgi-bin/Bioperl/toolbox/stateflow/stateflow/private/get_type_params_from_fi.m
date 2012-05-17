function [bias,exponent,isSigned,slope,wordLength] = get_type_params_from_fi(fiObject)

%   Copyright 2006 The MathWorks, Inc.

% Used by prs_compile_data_types.cpp to inherit types
% from fi objects
bias = fiObject.Bias;
exponent = -fiObject.FractionLength;
isSigned = fiObject.Signed;
slope = fiObject.SlopeAdjustmentFactor;
wordLength = fiObject.WordLength;

