function nlr = nlregsearch(sys, data)
%NLREGSEARCH NonlinearRegressors search

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2009/10/16 04:56:58 $

% Author(s): Qinghua Zhang

ny = size(sys, 'ny');
isso = (ny==1);

sys.Focus = 'Prediction';

algo = pvget(sys, 'Algorithm');
traceflag = any(strcmpi(algo.Display, {'on','full'}));

algo.Display = 'off';
sys = pvset(sys, 'Algorithm', algo);

nlobj = sys.Nonlinearity;
uselintermflag = false(ny,1);
for ky=1:ny
    uselintermflag(ky) = uselinearterm(nlobj(ky));
end

if ~any(uselintermflag)
    nlr = [];
    ctrlMsgUtils.warning('Ident:idnlmodel:idnlarxNlregSearchNotRequired')
    return
end

% xinit
maxidelay = reginfo(sys.na, sys.nb, sys.nk, sys.CustomRegressors);
maxd = max(maxidelay);
Nobs = size(data,1);
if min(Nobs)>=maxd
    xinit = data(1:maxd);
else
    xinit = [];
end

if isso
    nregs = length(getreg(sys));
else
    nregs = cellfun(@length, getreg(sys));
    nregs(~uselintermflag) = 0;
    %Treat channels not using LinearTerm as if they have zero regressors
end

nallregs = sum(nregs);
nallcomb = 2^nallregs;
losstrace = zeros(nallcomb,1);
nlrtrace = cell(nallcomb,1);
pt = 0;

if traceflag
    fprintf(' Searching for best nonlinear regressors\n Tested regressor combinations: ');
    fprintf(' %s', repmat(' ', 1, 2*length(int2str(nallcomb))));
end

for knl=0:nallregs
    nlrcomb = nchoosek(1:nallregs, knl);
    ncomb = size(nlrcomb,1);
    for kc=1:ncomb
        pt = pt + 1;
        if traceflag
            for kb=1:(length(int2str(pt))+length(int2str(nallcomb))+1)
                fprintf('\b');
            end
            fprintf('%d/%d', pt,nallcomb);
        end
        if isso
            nlr = nlrcomb(kc,:);
        else
            % Convert long vector nlrvec to cell array
            nlr = cell(ny,1);
            nlrvec = nlrcomb(kc,:);
            cumnregs = [0; cumsum(nregs(:))];
            for ky=1:ny
                nlr{ky} = nlrvec(cumnregs(ky)<nlrvec & nlrvec<=cumnregs(ky+1));
                if ~isempty(nlr{ky})
                    nlr{ky} = nlr{ky} - cumnregs(ky);
                end
            end
        end
        nlrtrace{pt} = nlr;
        
        sysk = sys; % Note: the original sys must be kept unchanged.
        sysk.NonlinearRegressors = nlr;
        sysk = pem(sysk, data);
        ys = sim(sysk, data, xinit, false);
        losstrace(pt) = norm(ys.y-data.y, 'fro');
    end
end
if traceflag
    fprintf('\n');
end
[~, ind] = min(losstrace);
nlr = nlrtrace{ind};

% FILE END