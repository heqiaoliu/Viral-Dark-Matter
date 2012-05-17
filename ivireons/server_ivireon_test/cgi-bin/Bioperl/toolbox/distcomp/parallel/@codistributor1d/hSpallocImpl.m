function [LP, codistr] = hSpallocImpl(codistr, m, n, nzmx)
; %#ok<NOSEM> % Undocumented

%   Implementation of hSpallocImpl for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/29 08:23:24 $

% We need to get a codistributor that is based on the correct global size.
codistr = codistr.hGetCompleteForSize([m, n]);

% Divide the non-zeros proportionally to the number of elements in the local
% part.
if sum(codistr.Partition) > 0
    weights = codistr.Partition;
else
    weights = ones(1, numlabs);
end

locNzmx = AbstractCodistributor.pWeightedSplit(nzmx, weights);
nzmx = locNzmx(labindex);
locsz = codistr.hLocalSize();
LP = spalloc(locsz(1), locsz(2), nzmx);

end % End of hSpallocImpl.
