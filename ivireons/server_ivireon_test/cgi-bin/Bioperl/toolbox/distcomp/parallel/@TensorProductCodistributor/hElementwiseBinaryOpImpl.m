function [LP, codistr] = hElementwiseBinaryOpImpl(codistr, fcn, codistrA, LPA, codistrB, LPB)
; %#ok<NOSEM> %Undocumented
%hElementwiseUnaryOpImpl Implementation for TensorProductCodistributor.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:40:21 $

if (isempty(codistrA) && ~isscalar(LPA)) || ...
        (isempty(codistrB) && ~isscalar(LPB))
    error('distcomp:TensorProductCodistributor:BinaryOp:ANotScalar', ...
           'When input is replicated, it must be a scalar.');
end
if isempty(codistrA) && isempty(codistrB)
    error('distcomp:TensorProductCodistributor:BinaryOp:AtLeastOneCodistributor', ...
          'At least one of the codistributors must be specified.');
end

% In all the cases that this method can be invoked, LPA stores data (replicated
% scalar or a local part), so does LPB, and we can always perform the binary
% operation in the same way:
LP = fcn(LPA, LPB);

% In all the cases that this method can be invoked (codistributed inputs or
% replicated inputs), the input and the output have the same distribution
% schemes, so the input value of codistr is the same as the output value.

end % End of hElementwiseBinaryOpImpl.
