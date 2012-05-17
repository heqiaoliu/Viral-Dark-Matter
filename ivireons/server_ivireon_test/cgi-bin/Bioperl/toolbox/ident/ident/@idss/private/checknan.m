function [ms,status] = checknan(mt,ms)
% FINDNAN  finds the parameters that correspond to NaN's

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $  $Date: 2008/10/02 18:49:40 $

status = 0;
names = fieldnames(mt);
namess = fieldnames(ms);
mt = struct2cell(mt);
ms = struct2cell(ms);
for kk=1:length(mt)
    mtr = mt{kk}.';
    msr = ms{kk}.';
    msr = msr(:);
    mtr = mtr(:);
    %nr  = find(isnan(msr));
    nri = find(~isnan(msr));
    dnr = find(abs(mtr(nri)-msr(nri))>1e4*eps);
    if ~isempty(dnr)
        status = 1;
        msr(nri(dnr)) = NaN*ones(length(dnr),1);
        ms{kk} = reshape(msr,size(ms{kk},2),size(ms{kk},1)).';
        ctrlMsgUtils.warning('Ident:utility:IncompatibleStructureMatrix',upper(names{kk}),upper(names{kk}))
    end
end
ms = cell2struct(ms,namess);
