function ci = statnormci(parmhat,cv,alpha,x,cens,freq)
%STATNORMCI Confidence intervals for normal distribution

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:19 $


if isvector(parmhat)
    parmhat = parmhat(:);
end
muhat = parmhat(1,:);
sigmahat = parmhat(2,:);

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

% Get confidence intervals for each parameter
if (isempty(cens) || ~any(cens(:))) && ~isequal(cv,zeros(2,2))
    % Use exact formulas
    tcrit = tinv([alpha/2 1-alpha/2],n-1);
    muci = [muhat + tcrit(1)*sigmahat/sqrt(n); ...
        muhat + tcrit(2)*sigmahat/sqrt(n)];
    chi2crit = chi2inv([alpha/2 1-alpha/2],n-1);
    sigmaci = [sigmahat*sqrt((n-1)./chi2crit(2)); ...
        sigmahat*sqrt((n-1)./chi2crit(1))];
else
    probs = [alpha/2; 1-alpha/2];
    se = sqrt(diag(cv))';
    z = norminv(probs);

    % Compute the CI for mu using a normal distribution for muhat.
    muci = muhat + se(1).*z;

    % Compute the CI for sigma using a normal approximation for
    % log(sigmahat), and transform back to the original scale.
    % se(log(sigmahat)) is se(sigmahat) / sigmahat.
    logsigci = log(sigmahat) + (se(2)./sigmahat) .* z;
    sigmaci = exp(logsigci);
end

% Return as a single array
ci = cat(3,muci,sigmaci);
