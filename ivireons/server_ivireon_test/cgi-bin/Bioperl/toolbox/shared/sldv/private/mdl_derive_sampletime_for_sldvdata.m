function ts = mdl_derive_sampletime_for_sldvdata(mdlSampleTimes)

% Copyright 2005-2007 The MathWorks, Inc.

    if mdlSampleTimes(1)~=0     
        ts = mdlSampleTimes(1);
    else
        sampleTimes = mdlSampleTimes(2:end);
        [a,b] = rat(sampleTimes);
        L = prod(b)/recursiveGCD(b);
        c = L*(a./b);
        D = recursiveGCD(c);
        ts = D/L;
    end

function out = recursiveGCD(data)     

    if length(data)==1,
        out = data;
    elseif length(data)==2,
        out = gcd(data(1),data(2));
    else
        out = gcd(data(1),recursiveGCD(data(2:end)));
    end