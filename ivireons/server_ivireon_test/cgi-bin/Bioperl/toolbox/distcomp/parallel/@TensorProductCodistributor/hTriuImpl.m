function [LP, codistr] = hTriuImpl(codistr, LP, k)
%hTriuImpl  Implementation for TensorProductCodistributor.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/08 13:25:27 $

% Create a function handle for comparison so we only need one 
% generic implementation function for both lower and upper triangular
% pGenericTriLowerUpperImpl

if ~isempty(LP) % required to handle 1d codistributors partitioned with dim > 2
    markLowerFcn = @(row, col) gt(row, col);  
    [LP, codistr] = codistr.pGenericTriLowerUpperImpl(LP, k, markLowerFcn);
end

end % End of hTriuImpl.
