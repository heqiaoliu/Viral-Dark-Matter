function [Dila, Tran] = reducemultgrid(Dila, Tran, xnl, maxcells)
%reducemultgrid: last multgrid reduction, based on distance between cell center and data points.
%This function is used when too many cells have been built with only one level.
%Then the cells with data points the most close to cell centers are kept.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:02:58 $

% Author(s): Qinghua Zhang

nc = size(Dila,1);
mindist = zeros(nc,1);
onesxcol = ones(size(xnl,1),1);
for kc=1:nc
  trankc = Tran(kc,:);
  mindist(kc) = min(sum((trankc(onesxcol,:)-xnl).^2, 2));
end
[dum, ind] = sort(mindist);

ind = ind(1:maxcells);
Dila = Dila(ind,:);
Tran = Tran(ind,:);

% FILE END