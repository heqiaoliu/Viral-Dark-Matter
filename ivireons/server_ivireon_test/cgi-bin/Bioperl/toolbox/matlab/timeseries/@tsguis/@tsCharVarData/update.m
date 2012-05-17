function update(cd,r)
%UPDATE  Data update method for @tsMeanData class.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $  $Date: 2005/12/15 20:57:19 $

%% Compute variance for each of the data objects in the response
%% for the defined freq interval

if isempty(cd.StartFreq)
    cd.StartFreq = r.Data.Frequency(1);
end
if isempty(cd.EndFreq)
    cd.EndFreq = r.Data.Frequency(end);
end

%% Find the frequency subinterval
I = find(r.Data.Frequency>=cd.StartFreq & r.Data.Frequency<=cd.EndFreq);
Lind = min(I);
Rind = max(I);

%% Compute char data from the periodogram data
for k=1:size(r.Data.Response,2)
    cd.Value(k) = mean(r.Data.Response(I,k));
    if strcmp(r.Data.Accumulate,'off')
        allVariance = mean(r.Data.Response(:,k));
        cd.Variance(k) = allVariance;
        if allVariance>eps
            cd.LVariance(k) = allVariance*sum(r.Data.Response(1:Lind,k))/...
                sum(r.Data.Response(:,k));
            cd.RVariance(k) = allVariance*sum(r.Data.Response(1:Rind,k))/...
                sum(r.Data.Response(:,k));
        else
            cd.LVariance(k) = 0;
            cd.RVariance(k) = 0;
        end
    else
        cd.LVariance(k) = r.Data.Response(Lind,k);
        cd.RVariance(k) = r.Data.Response(Rind,k);
        cd.Variance(k) = r.Data.Response(end,k);
    end
end
 
