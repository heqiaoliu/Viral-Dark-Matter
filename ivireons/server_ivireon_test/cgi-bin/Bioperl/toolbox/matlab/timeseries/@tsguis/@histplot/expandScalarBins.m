function binvec = expandScalarBins(this)

% Copyright 2005 The MathWorks, Inc.

%% Method to expand a scalar bin count to a valid bin vector
if isscalar(this.bins)
    numbins = this.bins;
else
    binvec = this.bins;
    return;
end

L = inf;
U = -inf;
for k=1:length(this.Waves)
    thisdata = this.Waves(k).DataSrc.Timeseries.Data;
    if ~isempty(thisdata)
        ind = find(~isnan(thisdata(:)));
        if ~isempty(ind)
            L = min(L,min(thisdata(ind)));
            U = max(U,max(thisdata(ind)));
        end
    end
end
if isfinite(L) && isfinite(U)
    binvec = linspace(L,U,numbins);
else
    binvec = [0 1];
end