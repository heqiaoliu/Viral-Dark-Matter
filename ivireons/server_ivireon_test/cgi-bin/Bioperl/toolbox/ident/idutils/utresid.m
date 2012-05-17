function [e1, r1, adv] = utresid(varargin)
%UTRESID  Utility code used by idmodel and idnlmodel RESID methods.

%   L. Ljung 10-1-86,1-25-92
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.13 $  $Date: 2010/04/21 21:26:13 $

% Basic checking.
ni = nargin;
error(nargchk(3,5,ni,'struct'))
no = nargout;
inpn = varargin{end}; %Input model name from the primary call.
varargin = varargin(1:end-1);
ni = ni - 1;

% Get and check various input arguments.
M = 25;
mode = 'corr';
freqflag = false; % Time-data by default.

z = varargin{2};
th = varargin{1};
if ni>2
    mode = varargin{3};
    if ~ischar(mode) || isempty(mode) || ~any(strncmpi(mode,{'corr','ir','fr'},length(mode)))
        ctrlMsgUtils.error('Ident:analysis:residCheck3')
    end
end

if ni>3
    M = varargin{4};
    if ~isscalar(M) || ~isa(M,'double') || ~isreal(M) || ~isfinite(M) || M<=0
        ctrlMsgUtils.error('Ident:analysis:residCheck4')
    end
end

% forgive data/model order mix
if isa(z,'idmodel') || isa(z,'idnlmodel')
    if isa(th,'iddata') || isa(th,'double') || isa(th,'frd') || isa(th,'idfrd')
        temp = z;
        z = th;
        th = temp;
    else
        ctrlMsgUtils.error('Ident:general:InvalidSyntax','resid','resid')
    end
end

% data preparation
if isa(z,'frd') || isa(z,'idfrd')
    z = iddata(idfrd(z));
end

if isa(z,'iddata') && strcmpi(pvget(z, 'Domain'), 'Frequency')
    freqflag = true;
end

if ~isa(z,'iddata') && ~isa(z,'double')
    ctrlMsgUtils.error('Ident:analysis:residCheck2')
end

% Check input parameters for frequency data.
if (strncmpi(mode, 'corr',1) && freqflag)
    mode = 'fr';
    if ni>2 %mode was specified as an input
        ctrlMsgUtils.warning('Ident:analysis:residWrongMode1')
    end
end

% Handle the number of lags.
M = floor(M);
if (M <= 0)
    ctrlMsgUtils.error('Ident:analysis:residInvalidHorizon')
end

% Set up the default values for data.
if ~isa(z, 'iddata')
    iddatflag = false;
    ny = size(th, 'ny');
    Tsdat = th.Ts;
    if Tsdat==0 %CT model
        Tsdat = 1;
    end
    z = iddata(z(:, 1:ny), z(:, ny+1:end), Tsdat);
else
    iddatflag = true;
    if (freqflag && isa(th, 'idnlmodel'))
        ctrlMsgUtils.error('Ident:analysis:residFreqDataNLModel')
    end
end
plotflag = true;

% Get MaxSize.
Ncaps = size(z, 'N');
if isa(th, 'idnlgrey')
    maxsize = [];
else
    maxsize = th.Algorithm.MaxSize;
end
if (ischar(maxsize) || isempty(maxsize))
    maxsize = idmsize(max(Ncaps));
end

if (ni == 1)
    [nz2, M1] = size(z);
    nz = sqrt(nz2);
    M = M1-2;
    ny = z(1, M1);
    nu = nz-ny;
    r = z(:, 1:M);
else
    % Compute the residuals and the covariance functions.
    [ny, nu]= size(th);
    [Ncap, nyd, nud] = size(z);
    if ((nyd ~= ny) || (nud ~= nu))
        ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
    end
    nz = ny+nu;
    if (freqflag && (nu == 0))
        ctrlMsgUtils.error('Ident:analysis:residInvalidResidCase')
    end
    
    % Compute prediction error(s).
    was = warning('off'); [lw,lwid]=lastwarn;
    e = pe(z, th);
    warning(was); lastwarn(lw,lwid)
    
    % It may happen that frequency 0 is omitted in e, due to integration.
    if (size(e, 1) < size(z, 1))
        z = z(2:end);
    end
    try
        e = pvset(e, 'InputData', pvget(z, 'InputData'));
    catch
        ctrlMsgUtils.error('Ident:analysis:residIntegratorProblem')
    end
    if ~freqflag
        r = covf(e, M, maxsize);
    else
        r = [];
    end
end

if (no)
    if ~iddatflag % To honor old syntax.
        e1 = pvget(e, 'OutputData');
        e1 = e1{1};
    else
        e1 = e;
    end
    r1 = r;
    r1(1, M+1:M+2) = [Ncaps(1) ny]; % To honor old syntax.
    
    if iddatflag
        plotflag = false;
        if ~freqflag
            mode = 'corr';
        end
    end
end

% First figure out the number of degrees of freedom for chi2tests.
if isa(th, 'idmodel')
    adm = getadv(th);
    modid = -1;
    if isfield(adm,'estimation') && isfield(adm.estimation,'DataId')
        modid = adm.estimation.DataId;
    end
    
    utd = pvget(z, 'Utility');
    if isfield(utd,'last')
        adv.DataId = datenum(utd.last);
    else
        adv.DataId = 0;
    end
    
    if (modid == adv.DataId)
        % Same validation and estimation data.
        xiextrauy = 0;
        xiextrae = 0;
    else
        % Find the number of par.
        [Nm, npar] = getncap(th);
        if isempty(Nm)
            Nm = inf;
        end
        [Ncap, ny, nu] = size(e);
        N = sum(Ncap);
        if (nu > 0)
            xiextrauy = floor(npar/ny/nu*N/Nm);
            xiextrae = floor(xiextrauy*nu);
        else
            xiextrae = 0;
        end
    end
    
    [ny, nu] = size(th);
    if ((nu > 0) && ~freqflag)
        test = chi(e, M, xiextrauy);
    end
end

% Handle the different mode cases.
if (strcmpi(mode(1), 'f') && plotflag)
    % Frequency respose.
    if isa(e,'iddata') && any(cell2mat(pvget(e,'Ts'))==0)
        ctrlMsgUtils.error('Ident:general:CTData','resid')
    end
    if (nu == 0)
        ctrlMsgUtils.error('Ident:analysis:residWrongMode2')
    end
    N = sum(size(e, 'N'));
    firorder =  floor(min([N/3/nu, 70/nu, 25]));
    for ky = 1:ny
        WarnSt = ctrlMsgUtils.SuspendWarnings;
        m1 = arx(e(:, ky), [0 firorder*ones(1, nu) zeros(1, nu)]);
        delete(WarnSt)
        bode(m1, 'sd', 2.58, 'fill', 'ap', 'a', 'resid');
        if (ky < ny)
            pause;
        end
    end
elseif (strcmpi(mode(1), 'i') && plotflag)
    % Impulse response.
    if (nu == 0)
        ctrlMsgUtils.error('Ident:analysis:residWrongMode2')
    end
    Ts = pvget(e, 'Ts');
    Ts = Ts{1};
    wst = ctrlMsgUtils.SuspendWarnings('Ident:analysis:ImpulseStepLargeTFinal');
    impulse(e, 'sd', 2.58, 'fill', M*Ts);
    delete(wst)
elseif (lower(mode(1)) == 'c')
    % Correlation case.
    if plotflag
        figh = gcf;
        set(figh, 'Name', 'Correlation analysis', 'NextPlot', 'replacechildren');
        set(0, 'CurrentFigure', figh);
        clf(figh)
    end
    nr = 0:M-1;
    plotind = 0;
    oname = pvget(z, 'OutputName');
    iname = pvget(z, 'InputName');
    N = sum(Ncaps);
    chiteste = NaN(1, ny);
    outteste = NaN(1, ny);
    for ky = 1:ny
        % Compute confidence interval for the autocovariance function.
        ind = ky+(ky-1)*nz;
        sdre = 2.58*(r(ind, 1))/sqrt(N)*ones(M, 1);
        if (nz == 1)
            spin = 111;
        else
            spin = 210+plotind+1;
        end
        if plotflag
            subplot(spin)
            xax = [nr(1); nr(end); nr(end); nr(1)];
            yax = [sdre(1); sdre(1); -sdre(1); -sdre(1)]/r(ind, 1);
            fill(xax, yax, 'y');
            hold on;
            stem(nr, r(ind, :)'/r(ind, 1));
            hold off;
            title(['Correlation function of residuals. Output ' oname{ky}]);
            xlabel('lag');
            plotind = rem(plotind+1, 2);
            if (plotind == 0)
                %                 figure('Name', 'Correlation analysis');
                pause;
                newplot;
            end
        end
        if isa(th, 'idmodel')
            % Advice handling.
            chiteste(ky) = 100*idchi2(real(r(ind, 2:end)*r(ind, 2:end)')/(r(ind, 1)'*r(ind, 1))*sum(Ncaps), ...
                M-1+xiextrae);
            outteste(ky) = sum(abs(r(ind, 2:end)) > 1.5*sdre(1));
        end
    end
    
    % Compute confidence lines for the cross-covariance functions.
    nr = -M+1:M-1;
    outtestue =zeros(ny, nu, M);
    for ky = 1:ny
        for ku = 1:nu
            ind1 = ky+(ny+ku-1)*nz;
            ind2 = ny+ku+(ky-1)*nz;
            indy = ky+(ky-1)*nz;
            indu = (ny+ku)+(ny+ku-1)*nz;
            sdreu = 2.58*sqrt(r(indy, 1)*r(indu, 1)+2*(r(indy, 2:M)*r(indu, 2:M)'))/sqrt(N)*ones(2*M-1, 1); % corr 890927.
            if plotflag
                spin = 210+plotind+1;
                subplot(spin);
                xax = [nr(1); nr(end); nr(end); nr(1)];
                yax = [sdreu(1); sdreu(1); -sdreu(1); -sdreu(1)]/(sqrt(r(indy, 1)*r(indu, 1)));
                fill(xax, yax, 'y');
                hold on;
                stem(nr, [r(ind1, M:-1:1) r(ind2, 2:M) ]'/(sqrt(r(indy, 1)*r(indu, 1))));
                hold off;
                title(['Cross corr. function between input ' iname{ku} ...
                    ' and residuals from output ' oname{ky}]);
                xlabel('lag');
                plotind = rem(plotind+1, 2);
                if ((ky+ku < nz) && (plotind == 0))
                    %                     figure('Name', 'Correlation analysis');
                    pause;
                    newplot;
                end
            end
            outtestue(ky, ku, :) = abs(r(ind2, 1:M)/sdreu(1));
        end
    end
    r(1, M+1:M+2) = [N ny];
    if plotflag
        set(gcf, 'NextPlot', 'replacechildren');
    end
end

% Update advice.
if isa(th, 'idmodel')
    ut = pvget(th, 'Utility');
    try
        adv = ut.advice.resid;
    catch
        adv.chitestue = [];
        adv.chitestuefb = [];
        adv.chiteste = [];
        adv.outtestue = [];
        adv.outteste = [];
    end
    if ((nu > 0) && ~freqflag)
        adv.chitestue = test.chidyn;
        adv.chitestuefb = test.chifb;
    end
    adv.r = r;
    if strcmp(mode, 'corr');
        adv.chiteste = chiteste;
        adv.outtestue = outtestue;
        adv.outteste = outteste;
    end
    utd = pvget(z, 'Utility');
    if isfield(utd,'last')
        adv.DataId = datenum(utd.last);
    else
        adv.DataId = 0;
    end
    ut.advice.resid = adv;
    th = uset(th, ut);
    
    try
        assignin('caller', inpn, th);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local function.                                                                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test = chi(e, M, plus)
% Computes the chi^2 tests for Reu.

[Ncap, ny, nu] = size(e);
N = sum(Ncap);
chitestfb = NaN(ny, nu);
chitestdyn = NaN(ny, nu);
for ky = 1:ny
    % me = ar(e(:, ky, []), 10); % Carry out prewhitening if necessary.
    % a = pvget(me, 'a');
    for ku = 1:nu
        et = e(:, ky, ku);
        r = covf(et, M);
        re0 = r(1, 1); % The variance of e.
        Ru = toeplitz(r(4, :));
        %% r(3,1) = r(2,1) could be attributed either to forward or
        %% feebdack path. Now ignored.
        %% direct = inlcudes direct term. nodir excludes it.
        %% direct = 1:size(r, 2);
        nodir = 2:size(r, 2);
        chitestfb(ky, ku) = ...
            100*idchi2(real(r(3, nodir)*inv(Ru(nodir, nodir))*r(3, nodir)')*N/re0, M+plus);
        chitestdyn(ky, ku) = ...
            100*idchi2(real(r(2, nodir)*inv(Ru(nodir, nodir))*r(2, nodir)')*N/re0, M+plus);
    end
end
test.chifb = chitestfb;
test.chidyn = chitestdyn;
