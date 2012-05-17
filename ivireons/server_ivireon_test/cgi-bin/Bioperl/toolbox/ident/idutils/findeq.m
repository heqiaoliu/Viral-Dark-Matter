function [xs, ylev] = findeq(model, ulev, Ts)
%FINDEQ finds equilibrium point (used by step).
%
%    XS = FINDEQ(MODEL, ULEV);
%
%    XS: The initial state that is the equilibrium for input level(s) ULEV.
%    ULEV is a row vector.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2008/07/14 17:07:29 $

[ny, nu] = size(model);
ulev = ulev(1:nu);
ulev = ulev(:).';
if isa(model, 'idmodel')
    model = pvset(model, 'CovarianceMatrix', []);
    ms = idss(model);
    [nx] = size(ms, 'nx');
    ssg = freqresp(ms, 0);
    if (any(any(isnan(ssg)))) || (any(any(isinf(ssg))))
        ylev = zeros(1, ny);
    else
        ylev = (ssg * ulev(:)).';
    end
    nx = max(2, nx); % To have more data than the prediction horizon.
    was = warning('off', 'all'); % Avoid warnings about channel numbers.
    ssd = iddata(ones(nx, 1)*ylev,ones(nx, 1)*ulev, Ts);
    [dum,xs] = pe(model, ssd, 'e');
    warning(was);
elseif isa(model, 'idnlarx')
    nlobj = pvget(model, 'Nonlinearity');
    opt = [];
    % ny = size(model, 'ny');
    z0 = [zeros(1, ny) ulev];
    y0 = zeros(1, ny);
    cusreg = get(model, 'CustomRegressor');
    na = pvget(model, 'na');
    nb = pvget(model, 'nb');
    nk = pvget(model, 'nk');
    [maxidelay, nregs] = reginfo(na, nb, nk, cusreg); %%na nb nk  LLL.
    maxdp1 = max(maxidelay)+1; % maxd plus 1.

    if (ischar(opt) && (opt(1) == 'n'))  % No search, use the given point.
        %ybar = y0;
        %equierr = [];
    else  % Search for the equilibrium point.
        if (ny == 1)
            [yvec, regmat] = makeregmat(model, z0(ones(maxdp1, 1), :));
            x0 = regmat{1}(1,:); % Take the first row only if more rows are generated.
            xu0 = x0(1, (na+1):end);
            [ylev, equierr] = fzero(@SubEqmSO, y0, opt, xu0, nlobj, na);
        else % ny > 1!
            xu0 = cell(ny, 1);
            was = warning('off', 'all'); % Avoid warnings about channel numbers.
            [yvec, regmat] = makeregmat(model, z0(ones(maxdp1, 1), :));
            warning(was);
            for kk = 1:ny
                x0 = regmat{kk};
                xu0{kk} = x0(1, (sum(na(kk, :), 2)+1):end);
            end
            if isempty(opt) % Modify default opt.
                opt = optimset('fminsearch');
                opt = optimset(opt, 'TolFun', 1e-10, 'TolX', 1e-10);
            end
            ylev = fminsearch(@SubSqfv, y0, opt, xu0, nlobj, na);
            %equierr = SubEqmMO(ylev, xu0, nlobj, na);
        end
    end
    was = warning('off', 'all');
    xs = iddata(ones(max(maxidelay), 1)*ylev, ones(max(maxidelay), 1)*ulev);
    warning(was);
elseif isa(model, 'idnlhw')
    linm = getlinmod(model);
    linm = idss(linm); % Added by QZ on 11/12/2006
    [ny, nu, npar, nx] = size(linm);
    nx = max(2, nx); % To have more data than the prediction horizon
    staticgain = freqresp(linm, 0);
    unl = get(model, 'InputNonLinearity');
    uulev = evaluate(unl, num2cell(ulev));
    ylev = staticgain*uulev(:);
    ssd = iddata(ones(nx, 1)*ylev.', ones(nx, 1)*uulev, pvget(model, 'Ts'));
    [dum, xs] = pe(linm,ssd);
elseif isa(model, 'idnlgrey')
    %nx = max(size(model, 'nx'), 1); % To handle also static models.
    for ku = 1:nu
        uu(:, ku) = ones(100, 1)*ulev(ku);
    end
    was = warning('off', 'all'); % Avoid warnings about channel numbers.
    [dum, dum, xs] = sim(model, iddata([], uu, Ts));
    warning(was);
end


%--------------------------------------------------------------------------
function [maxidelay, regdim] = reginfo(na, nb, nk, custreg)
%REGINFO returns regressor information: maxidelay, regdim.
ny = size(na, 1);
maxidelay = zeros(ny, 1);
regdim = zeros(ny, 1);

if isempty(custreg)
    custreg = cell(ny, 1);
elseif ~iscell(custreg)
    custreg = {custreg};
end

for ky = 1:ny
    maxidelay(ky) = max([na(ky, :), nb(ky, :)+nk(ky, :)-1], [], 2);
    regdim(ky) = sum(na(ky, :),2) + sum(nb(ky, :),2);

    %   if isempty(custreg)
    %     ncr = 0;
    %   else
    ncr = numel(custreg{ky});
    %   end
    if ncr
        %{
        if ~isa(custreg{ky}, 'customreg')
            erro('Ident:step', 'Custom regressor must be a CUSTOMREG object.');
        end
        %}
        maxidelay(ky) = max(maxidelay(ky), getmaxdelay(custreg{ky}));
        regdim(ky) = regdim(ky) + ncr;
    end
end

%--------------------------------------------------------------------------
function fv = SubEqmSO(y, xu0, nlobj, na)
%SUBEQMSO equilibrium equation function, single output.
fv = y - evaluate(nlobj, [y(ones(1,na)), xu0]);

%--------------------------------------------------------------------------
function fv = SubEqmMO(y, xu0, nlobj, na)
%SUBEQMMO equilibrium equation function, multi-output.
ny = size(na, 1);
fv = zeros(ny, 1);

for kk = 1:ny
    xyu = zeros(sum(na(kk, :))+length(xu0{kk}), 1);
    pt = 0;
    for jj = 1:ny
        xyu(pt+(1:na(kk,jj))) = y(jj)*ones(1, na(kk, jj));
        pt = pt + na(kk, jj);
    end
    xyu(pt+1:end) = xu0{kk};
    fv(kk) = y(kk) - evaluate(nlobj(kk), xyu(:)');
end

%--------------------------------------------------------------------------
function s = SubSqfv(y, xu0, nlobj, na)
%SUBSQFV square of SubEqmMO.
fv = SubEqmMO(y, xu0, nlobj, na);
fv = fv(:);
s = fv'*fv;

%{
%--------------------------------------------------------------------------
function msg = SubValidopt(opt)
%SUBVALIDOPT test optimization option validity.
if ~isstruct(opt) || ~isequal(opt, optimset(opt))
    msg = 'Invalid optimization options structure.';
else
    msg = [];
end
%}