function [LP, codistr] = hSpallocImpl(codistr, m, n, nzmx)
; %#ok<NOSEM> % Undocumented

%   Implementation of hSpallocImpl for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 03:53:46 $

% We need to get a codistributor that is based on the correct global size.
codistr = codistr.hGetCompleteForSize([m, n]);

% Divide the non-zeros proportionally to the number of elements stored on each
% lab.
weights = zeros(1, numlabs);
for labidx = 1:numlabs
    weights(labidx) = prod(codistr.hLocalSize(labidx));
end

if sum(weights) == 0
    weights = ones(1, numlabs);
end

locNzmx = AbstractCodistributor.pWeightedSplit(nzmx, weights);
nzmx = locNzmx(labindex);
locsz = codistr.hLocalSize();
LP = spalloc(locsz(1), locsz(2), nzmx);

end % End of hSpallocImpl.
