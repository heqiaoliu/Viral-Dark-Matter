function [LP, codistr] = hBuildFromFcnImpl(codistr, fun, sizesDvec, className)
; %#ok<NOSEM> % Undocumented

%   Implementation of hBuildFromFcnImpl for TensorProductCodistributor.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:40:20 $


% We need to work with a completely specified codistributor with the correct
% global size.
codistr = codistr.hGetCompleteForSize(sizesDvec);

% Get the required size of the local part.
locSize = codistr.hLocalSize();

% We have to pass the sizes in as multiple arguments because of sparse.  We want
% to call sparse(m, n) to create an m-by-n sparse array -- this is not the same
% as sparse([m, n]);
locSize = num2cell(locSize);
if ~isempty(className)
    LP = fun(locSize{:}, className);
else
    LP = fun(locSize{:});
end

end % End of hBuildFromFcnImpl.
