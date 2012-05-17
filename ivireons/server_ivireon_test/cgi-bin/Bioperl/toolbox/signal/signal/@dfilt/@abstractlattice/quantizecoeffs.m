function quantizecoeffs(Hd,eventData)
%QUANTIZECOEFFS Quantize coefficients

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/20 23:21:01 $

% Quantize the coefficients
Hd.privlattice = quantizecoeffs(Hd.filterquantizer,Hd.reflattice);
Hd.privconjlattice = quantizecoeffs(Hd.filterquantizer,conj(Hd.reflattice));

