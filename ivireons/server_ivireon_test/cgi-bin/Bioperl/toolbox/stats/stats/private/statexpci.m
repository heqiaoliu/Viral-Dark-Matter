function parmci=statexpci(parmhat,cv,alpha,x,cens,freq)
%STATSEXPCI Exponential parameter confidence interval.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:10 $

% Number of observations
if isempty(freq) || isequal(freq,1)
    if isvector(x)
        n = length(x);
    else
        n = size(x,1);
    end
else
    n = sum(freq);
end

% Number not censored
nunc = n - sum(freq.*cens);

% Confidence interval
if nunc > 0
    gamcrit = gaminv([alpha/2 1-alpha/2], nunc, 1);
    parmci = [nunc.*parmhat ./ gamcrit(2);
              nunc.*parmhat./ gamcrit(1)];
else
    parmci = NaN(2,numel(parmhat),class(x));
end
