function initialize(this)
%initialize object

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/03/13 17:24:10 $

model = this.Model;
ny = size(model,1);
this.Algorithm = model.Algorithm;

op = this.OperPoint;
u0 = op.Input;
%y0 = op.Output;
this.Data.nufree = sum(~u0.Known);
%this.Data.nyfree = sum(~y0.Known);

Delays = getDelayInfo(model);
this.Data.Delays = Delays;
this.Data.Nx = sum(Delays); % number of states
cumDel = cumsum(Delays)+1;
CumInd = [1,cumDel(1:end-1)];
this.Data.CumInd = CumInd;

LenCust = zeros(1,ny);
cust = model.CustomRegressors;
if ~isempty(cust)
    if ny==1
        LenCust = numel(cust);
    else
        for ky = 1:ny
            LenCust(ky) = numel(cust{ky});
        end
    end
end
this.Data.LenCust = LenCust;
