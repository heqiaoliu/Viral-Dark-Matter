function conformOutputs(this)
% make settings for all outputs same as that for the current one

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:13:05 $

if this.isSingleOutput
    return
end

Ind = this.getCurrentOutputIndex;
m = this.NlhwModel;
%m0 = m; %cache model
[ny,nu] = size(m);

% update orders
m.nf = repmat(m.nf(Ind,:),ny,1);
m.nb = repmat(m.nb(Ind,:),ny,1);
m.nk = repmat(m.nk(Ind,:),ny,1);

this.updateModel(m);