function conformOutputs(this)
% make settings for all outputs same as that for the current one

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/31 06:12:45 $

if this.isSingleOutput
    return
end

Ind = this.getCurrentOutputIndex;
m = this.NlarxModel;
m0 = m; %cache model
[ny,nu] = size(m);

% update orders
m.na = repmat(m.na(Ind,:),ny,1);
m.nb = repmat(m.nb(Ind,:),ny,1);
m.nk = repmat(m.nk(Ind,:),ny,1);

% custom regressors
cust = m0.CustomRegressors{Ind};
for k = 1:ny
    m.CustomRegressors{k} = cust;
end

was = warning('off','Ident:idnlmodel:idnlarxUselessNlreg');
% regressor selection
for k = 1:ny
    % this will be valid because the orders have already been updated
    m.NonlinearRegressors{k} = m0.NonlinearRegressors{Ind};
end

warning(was)

%thisNLname = char(this.jMainPanel.getCurrentNonlinID);

% nonlinearity
NL = m0.Nonlinearity(Ind);
for k = 1:ny
    if k==Ind
        continue;
    end
    m.Nonlinearity(k) = NL;
    %{
    try
        m.Nonlinearity(k) = NL;
    catch
        nl = initreset(nl);
        this.NonlinOptionsPanels.(thisNLname).Object = nl;
        m.Nonlinearity(Ind) = nl;
    end
    %}
end

this.updateModel(m);
