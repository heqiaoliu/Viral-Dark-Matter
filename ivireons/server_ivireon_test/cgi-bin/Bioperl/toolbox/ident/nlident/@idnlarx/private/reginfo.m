function [maxidelay, regdim] = reginfo(na, nb, nk, custreg)
%REGINFO returns regressor information: maxidelay, regdim.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:53:24 $

% Author(s): Qinghua Zhang

ny = size(na,1);
maxidelay = zeros(ny,1);
regdim = zeros(ny,1);

if isempty(custreg)
    custreg = cell(ny,1);
elseif ~iscell(custreg)
    custreg = {custreg};
end

for ky=1:ny
    maxidelay(ky) = max([na(ky,:), nb(ky,:)+nk(ky,:)-1], [], 2);
    regdim(ky) = sum(na(ky,:),2) + sum(nb(ky,:),2);
    
    ncr = numel(custreg{ky});
    
    if ncr
        if ~isa(custreg{ky}, 'customreg')
            ctrlMsgUtils.error('Ident:idnlmodel:reginfo1')
        end
        maxidelay(ky) = max(maxidelay(ky), getmaxdelay(custreg{ky}));
        regdim(ky) = regdim(ky) + ncr;
    end
end

% FILE END

