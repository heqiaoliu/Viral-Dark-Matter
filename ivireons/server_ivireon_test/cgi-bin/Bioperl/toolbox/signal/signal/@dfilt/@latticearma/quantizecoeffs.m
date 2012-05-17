function quantizecoeffs(Hd,eventData)
% Quantize coefficients

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/06/06 16:55:08 $

if isempty(Hd.refladder)
    return;
end

q = Hd.filterquantizer;
[latq, conjlatq, ladq] = quantizecoeffs(q,Hd.reflattice,conj(Hd.reflattice),Hd.refladder);
Hd.privlattice = latq;
Hd.privconjlattice = conjlatq;
Hd.privladder = ladq;


