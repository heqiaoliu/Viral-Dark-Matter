function [IntArray,varargout] = fi2sim(A)
%FI2SIM Simulink integer array to FI object
%   [IntArray, NumericType]                                              = FI2SIM(A)
%   [IntArray, Signed, WordLength, FractionLength]                       = FI2SIM(A)
%   [IntArray, Signed, WordLength, Slope, Bias]                          = FI2SIM(A)
%   [IntArray, Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias] = FI2SIM(A)
%
%   Returs stored-integer data in integer array IntArray and numeric
%   attributes from FI object A.
%
%   FI2SIM is the inverse of SIM2FI.
%
%   See also FI, EMBEDDED.FI/SIM2FI

%   Copyright 2003-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/12/10 21:33:01 $

error(nargoutchk(0,6,nargout,'struct'));

if A.WordLength > 128
  error('fi:fi2sim:SimulinkData128Bits',...
        ['Simulink fixed-point data types must have word lengths less ' ...
         'than or equal to 128 bits.']);
end

IntArray = simulinkarray(A);

switch nargout
  case 2
    % [IntArray, NumericType] = FI2SIM(A)
    varargout{1} = numerictype(A);
  case 3
    % [IntArray, Signed, WordLength] = FI2SIM(A)
    varargout{1} = A.signed;
    varargout{2} = A.wordlength;
  case 4
    % [IntArray, Signed, WordLength, FractionLength] = FI2SIM(A)
    varargout{1} = A.signed;
    varargout{2} = A.wordlength;
    varargout{3} = A.fractionlength;
  case 5
    % [IntArray, Signed, WordLength, Slope, Bias] = FI2SIM(A)
    varargout{1} = A.signed;
    varargout{2} = A.wordlength;
    varargout{3} = A.slope;
    varargout{4} = A.bias;
  case 6
    % [IntArray, Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias] = FI2SIM(A)
    varargout{1} = A.Signed;
    varargout{2} = A.WordLength;
    varargout{3} = A.SlopeAdjustmentFactor;
    varargout{4} = A.FixedExponent;
    varargout{5} = A.Bias;
end
