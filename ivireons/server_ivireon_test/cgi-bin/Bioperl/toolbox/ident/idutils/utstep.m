function [you, tou, ysdou] = utstep(varargin)
%UTSTEP  Utility code used by idmodel and idnlmodel STEP methods.

%   L. Ljung 10-2-90,1-9-93
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.17 $  $Date: 2009/11/09 16:23:51 $

% Retrieve the number of inputs and outputs.
%nin = length(varargin);
nout = nargout;

% Basic checking and initializations.
NA = 10;
sd = 0;
ulevel = [];

% Check fill input.
varargin = low(varargin);
fillnr = find(strcmp(varargin, 'fill'));
if ~isempty(fillnr)
    fillsd = true;
    varargin(fillnr) = [];
else
    fillsd = false;
end

% Check stem input.
fillnr = find(strcmpi(varargin, 'stem'));
if ~isempty(fillnr)
    stempl = true;
    varargin(fillnr) = [];
else
    stempl = false;
end

% Check pw input.
kpf = find(strcmp(varargin, 'pw'));
if ~isempty(kpf)
    if (kpf == length(varargin))
        ctrlMsgUtils.error('Ident:analysis:stepCheck3')
    end
    NA = varargin{kpf+1};
    if isempty(NA)
        NA = 10;
    elseif (~isa(NA, 'double') || ~isscalar(NA))
        ctrlMsgUtils.error('Ident:general:PosIntOptionValue','PW','step','idmodel/step')
    end

    if (length(varargin) < kpf+2)
        varargin = varargin(1:kpf-1);
    else
        varargin = varargin([1:kpf-1 kpf+2:end]);
    end
end

% Check sd input.
kpf = find(strcmp(varargin, 'sd'));
if ~isempty(kpf)
    if (kpf == length(varargin))
        ctrlMsgUtils.error('Ident:analysis:stepInvalidSD')
    end
    sd = varargin{kpf+1};
    if (~isa(sd, 'double') || ~isscalar(sd) || ~isreal(sd) || ~isfinite(sd) || (sd<0))
        ctrlMsgUtils.error('Ident:general:PosNumOptionValue','SD','step','idmodel/step')
    end
    if (length(varargin) < kpf+2)
        varargin = varargin(1:kpf-1);
    else
        varargin = varargin([1:kpf-1 kpf+2:end]);
    end
end

% Check InputLevels.
kpf = find(strncmpi(varargin, 'in', 2) | strncmpi(varargin, 'ul', 2));
if ~isempty(kpf)
    if (kpf == length(varargin))
        ctrlMsgUtils.error('Ident:analysis:stepMissingInputLevelsValue')
    end
    ulevel = varargin{kpf+1};
    if any(~isfinite(ulevel(:))) || ~isa(ulevel,'double') || ndims(ulevel)~=2
        ctrlMsgUtils.error('Ident:analysis:stepInvalidInputLevels')
    end

    if (length(varargin) < kpf+2)
        varargin = varargin(1:kpf-1);
    else
        varargin = varargin([1:kpf-1 kpf+2:end]);
    end
end

% Decode the remaining input list.
WarnSt = ctrlMsgUtils.SuspendWarnings('Ident:analysis:ImpulseFilterOrder');
[sys, sysname, PlotStyle, T, Tdata, Tsdemand] = sysirdec(NA,1,varargin{:});
delete(WarnSt)
if isempty(sys)
    % Quick return for empty systems.
    if nargout
        you = NaN;
        tou = NaN;
        ysdou = NaN;
    end
    ctrlMsgUtils.warning('Ident:analysis:emptyModelResponse','Step')
    return;
end

% Check T.
if (length(T) == 1)
    T = [-abs(T)/4 abs(T)];
elseif (length(T) == 2)
    T = [T(1) abs(T(2))];
end

% Check InputLevels.
nu = zeros(length(sys), 1);
nrtsnlarx = 0; %number of time series nlarx models
for ksys = 1:length(sys);
    nu(ksys) = size(sys{ksys}, 'nu');
    if (nu(ksys) == 0)
        nu(ksys) = size(sys{ksys}, 'ny');

        if isa(sys{ksys}, 'idmodel') || isa(sys{ksys}, 'idnlgrey')
            %% For time series look at response from e.
            sys{ksys} = noisecnv(sys{ksys});
        else % Convert the input "by hand", and have a special
            % solution for the handling of input names
            nrtsnlarx = nrtsnlarx +1;
        end
    end
end

nnm = max(nu);
if isempty(ulevel)
    ulevel = [0; 1];
end
[chk, nnu] = size(ulevel);
if ((nnu == 2) && (chk ~= 2))
    ulevel = ulevel.';
    [chk, nnu] = size(ulevel);
end
if (nnu == 1)
    ulevel = ulevel*ones(1, nnm);
    nnu = nnm;
end
if ((chk ~= 2) || (nnu ~= nnm))
    ctrlMsgUtils.error('Ident:analysis:stepInvalidInputLevels')
end

if isempty(T)
    if ~isempty(Tdata)
        T = [min(Tdata) max(Tdata)];
    else
        Tf = zeros(length(sys), 1);
        for ksys = 1:length(sys);
            if isa(sys{ksys}, 'idmodel')
                Tf(ksys) = iddeft(sys{ksys});
            elseif isa(sys{ksys}, 'idnlhw')
                Tf(ksys) = iddeft(getlinmod(sys{ksys}));
            elseif pvget(sys{ksys},'Ts')>0
                Tf(ksys)=100*pvget(sys{ksys},'Ts');
            else
                Tf(ksys) = 10;
            end
        end
        Tf = max(Tf);
        T = [-Tf/4 Tf];
    end
end


% Handle output (no plotting) case.
if nout
    if (length(sys) > 1)
        ctrlMsgUtils.error('Ident:analysis:RequiresSingleModelWithOutputArgs','step')
    end
    if (nout > 2)
        sd = 1;
    end
    sys1 = sys{1};
    [you, tou, ysdou, sys1, flag] = impres(sys1, T, sd, Tsdemand, ulevel);
    if flag
        try
            assignin('caller', sysname{1}, sys1)
        catch
        end
    end
    return;
end

% No output case, perform plotting.
[ynared, unared, yind, uind] = idnamede(sys);
NY = length(ynared);
NU = length(unared);

% If there is a mix of time series linear and idnlarx models,
% unared and uind need to be modified by hand:
if nrtsnlarx>0
    %reconstruct unared:
    for ksys=1:length(sys)
        [~,nuk]=size(sys{ksys});
        unak{ksys}=pvget(sys{ksys},'InputName');
        if nuk==0
            ynak=pvget(sys{ksys},'OutputName');
            unak{ksys} = {};
            for ky=1:length(ynak)
                unak{ksys} = [unak{ksys};['e@',ynak{ky}]];
            end
            unared = [unared;unak{ksys}];
        end
    end
    unared = unique(unared);
    NU = length(unared);
    % Now find the modified uind for the new unared:
    uind = zeros(length(sys),NU);
    for ksys=1:length(sys)
        for ky=1:length(unak{ksys})%size(sys{ksys},'ny')
            nr = strcmp(unared,unak{ksys}{ky});
            uind(ksys,nr)=ky;
        end
    end
end

cols = get(gca, 'colororder');
if (sum(cols(1, :)) > 1.5)
    % Dark background.
    colord = ['y' 'm' 'c' 'r' 'g' 'w' 'b'];
else
    % Light background
    colord=['b' 'g' 'r' 'c' 'm' 'y' 'k'];
end
Y = cell(1, length(sys));
YSD = cell(1, length(sys));
Tsa = cell(1, length(sys));
for ks = 1:length(sys)
    sys1 = sys{ks};
    [y, t, ysd] = impres(sys1, T, sd, Tsdemand, ulevel);
    Y{ks} = y;
    YSD{ks} = ysd;
    Tsa{ks} = t;
end

% Plotting.
%isHld = false;
isHld = ishold;
for yna = 1:length(ynared)
    for una = 1:length(unared)
        subplot(NY, NU, (yna-1)*NU+una);
        tu = cell(1, length(sys));
        for ks = 1:length(sys)
            if isempty(PlotStyle{ks})
                PStyle = [colord(mod(ks-1, 7)+1), '-'];
            else
                PStyle = PlotStyle{ks};
            end
            if uind(ks, una)
                if (yind(ks, yna) && uind(ks, una))
                    t = Tsa{ks};
                    y = Y{ks}(1:length(t), yind(ks, yna), uind(ks, una));
                    sd1 = 0;
                    if sd
                        if isempty(YSD{ks})
                            sd1 = 0;
                        else
                            ysd = YSD{ks}(1:length(t), yind(ks, yna), uind(ks, una));
                            if ~isreal(ysd)
                                ctrlMsgUtils.warning('Ident:analysis:stepUnreliableStd')
                                ysd = zeros(size(ysd));
                            end
                            sd1 = sd;
                        end
                    end

                    % Stem plot.
                    if stempl
                        stem(t, y, PStyle);
                        %isHld = ishold;
                        %hold on;
                    else
                        plot(t, y, PStyle);
                        %isHld = ishold;
                        %hold on;
                    end
                    hold on

                    % Standard deviation.
                    if sd1
                        yy = y;
                        if fillsd
                            fillcol = idutils.getPatchColor(PStyle(1));
                            t = t(:);
                            xax = [t; t(end:-1:1)];
                            ysd = ysd(:);
                            yax = [yy+sd*ysd; yy(end:-1:1)-sd*ysd(end:-1:1)];

                            Hp = fill(xax, yax, fillcol, 'EdgeColor','None');
                            uistack(Hp,'bottom'); set(gca,'Layer','top')
                            
                        else
                            plot(t, yy+sd*ysd, [PStyle(1), '-.']);
                            hold on;
                            plot(t, yy-ysd*sd, [PStyle(1), '-.']);
                            hold on;
                        end
                    end
                end
            end
            tu{ks} = pvget(sys{ks}, 'TimeUnit');
        end

        if ~isHld
            hold off;
        end
        if (yna == 1)
            title(['From ' unared{una}]);
        end
        if (una == 1)
            ylabel(['To ' ynared{yna}]);
        end
        if (length(setdiff(tu, {''})) > 1)
            ctrlMsgUtils.warning('Ident:plots:modelTimeUnitsMismatch')
        end
        if ~isempty(tu{1})
            tun = ['(' tu{1} ')'];
        else
            tun = '';
        end
        xlabel(['Time ' tun]);
        axis('tight');
    end
end

if ~isHld
    set(gcf, 'NextPlot', 'replacechildren');
else
    set(gcf, 'NextPlot', 'add');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y, t, ysd, sys1, flag] = impres(sys1, T, sd, Tsdemand, ulevel)
flag = 0;
[ny, nu] = size(sys1);
if ((sd > 0) && (isa(sys1, 'idnlmodel')))
    ctrlMsgUtils.warning('Ident:analysis:SDForNonlinearModel')
    sd = 0;
end
Ts  = sys1.Ts;
T1 = min(0, min(T));
T2 = max(T);
if (Ts == 0)
    if ~isempty(Tsdemand)
        Ts = Tsdemand;
    else
        if isa(sys1, 'idmodel')
            [~, Ts] = iddeft(sys1, T2);
        elseif isa(sys1, 'idnlhw')
            sys2 = getlinmod(sys1);
            [~, Ts] = iddeft(sys2, T2);
        else
            Ts = (T2-T1)/100;
        end
    end
end

if (isa(sys1, 'idmodel') && isaimp(sys1))

    ut = pvget(sys1, 'Utility');
    B = ut.impulse.B;
    ylevin = zeros(ny, nu);
    for ku = 1:nu
        for ky = 1:ny
            ylevin(ky, ku) = sum(sum(squeeze(B(ky, ku, :))));
        end
    end
    dBstep = ut.impulse.dBstep;
    time = ut.impulse.time;
    actime = find((time >= T1) & (time <= T2));
    Ndata = length(actime);
    y = zeros(Ndata, ny, nu);
    for ky = 1:ny
        for ku = 1:nu
            y(:, ky, ku) = ones(Ndata, 1)*ylevin(ky, ku)*ulevel(1, ku);
        end
    end
    ysd = zeros(Ndata, ny, nu);
    t = time(actime).';
    zer = find(t == 0);
    int = zer:Ndata;
    for ku = 1:nu
        y(:, :, ku) = squeeze(B(:, ku, actime))'*(ulevel(2, ku)-ulevel(1, ku));
        for ky = 1:ny
            %             y(:, ky, ku) = ylevin(ky, ku)*ulevel(2, ku);
            y(int, ky, ku) = cumsum(y(int, ky, ku));
            y(:, ky, ku) = y(:, ky, ku)+ylevin(ky, ku)*ulevel(1, ku);
        end
        ysd(:, :, ku) = squeeze(dBstep(:, ku, actime))'*(ulevel(2, ku)-ulevel(1, ku));
    end
elseif isa(sys1, 'idmodel')
    % Linear model.
    Tstart = floor(T1/Ts);
    if (Tstart*Ts < T1)
        Tstart = Tstart+1;
    end
    Ndata = ceil((T2-T1)/Ts-10*eps)+1;
    %     inpd = pvget(sys1, 'InputDelay');
    %     Ndata = Ndata+max(inpd);
    [~, ylev] = findeq(sys1, ulevel(1, :), Ts);
    ulevel(2, :) = ulevel(2, :)-ulevel(1, :);
    ulevel(1, :) = zeros(size(ulevel(1, :)));
    udat = zeros(Ndata, nu);
    for ku = 1:nu
        udat(:, ku) = ones(Ndata, 1)*ulevel(1, ku);
    end
    uu = iddata([], udat, Ts);
    uu = pvset(uu, 'Tstart', Tstart*Ts, ...
        'InputName', pvget(sys1, 'InputName')); % This is to assure that 0 is a sampling point.
    zer = find(get(uu, 'SamplingInstants') == 0);
    int = zer:Ndata;
    y = zeros(Ndata, ny, nu);
    ysd = zeros(Ndata, ny, nu);
    if (sd && (isa(sys1, 'idmodel') && ~isa(sys1, 'idpoly')))
        [~, sys1, flag] = idpolget(sys1);
    end
    for ku = 1:nu
        u1 = uu;
        u1.u(int, ku)=ones(size(int))*ulevel(2, ku);
        if sd
            ssd = 0;
            if isa(sys1, 'idproc')
                typ = i2type(sys1);
                if isempty(sys1.CovarianceMatrix)
                    ssd = 0;
                else
                    ssd = any(cat(2, typ{:}) == 'D');
                end
            end
            if ssd
                % Compute the uncertainty by Monte Carlo simulations.
                try
                    sys1 = pvset(sys1,'InitialState','Fixed');
                    sys1.x0 = zeros(size(sys1.x0));
                end
                RSTREAM = RandStream('shr3cong','seed',0);
                PREVSTREAM = RandStream.setDefaultStream(RSTREAM);
                WarnSt = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:unstableSimulations');
                [y1, ysd1] = simsd(sys1, u1, 30);
                delete(WarnSt)
                RandStream.setDefaultStream(PREVSTREAM)
                y1 = y1{1};
            else
                [y1, ysd1] = sim(sys1, u1, 'z');
            end
            y1.y = y1.y + ones(size(y1.y,1), 1)*ylev;
            if ~isempty(ysd1)
                ysd2 = pvget(ysd1, 'OutputData');
                ysd(1:length(ysd2{1}), :, ku) = ysd2{1};
            else
                ysd = [];
            end
        else
            y1 = sim(sys1, u1,'z');
            y1.y = y1.y + ones(size(y1.y,1), 1)*ylev;
        end
        y2 = pvget(y1, 'OutputData');
        y(1:length(y2{1}), :, ku) = y2{1};
    end
    t = pvget(y1, 'SamplingInstants');
    t = t{1};
else
    % Nonlinear model.
    Tstart = floor(T1/Ts);
    if (Tstart*Ts < T1)
        Tstart=Tstart+1;
    end
    Ndata = ceil((T2-T1)/Ts-10*eps)+1;
    %     inpd = pvget(sys1, 'InputDelay');
    %     Ndata = Ndata+max(inpd);
    xss = findeq(sys1, ulevel(1, :), Ts);
    udat = zeros(Ndata, nu);
    for ku = 1:nu
        udat(:, ku) = ones(Ndata, 1)*ulevel(1, ku);
    end
    uu = iddata([], udat, Ts);
    uu = pvset(uu, 'Tstart', Tstart*Ts, ...
        'InputName', pvget(sys1, 'InputName')); % This is to assure that 0 is a sampling point.
    zer = find(get(uu, 'SamplingInstants') == 0);
    int = zer:Ndata;
    y = zeros(Ndata, ny, nu);
    ysd = zeros(Ndata, ny, nu);
    if (sd && (isa(sys1, 'idmodel') && ~isa(sys1, 'idpoly')))
        [~, sys1, flag] = idpolget(sys1);
    end
    for ku = 1:nu
        u1 = uu;
        u1.u(int, ku) = ones(size(int))*ulevel(2, ku);
        was = ctrlMsgUtils.SuspendWarnings;
        y1 = sim(sys1,u1,xss);
        delete(was)
        y2 = pvget(y1, 'OutputData');
        y(1:length(y2{1}), :, ku) = y2{1};
    end

    %%%% Added by QZ %%%
    if nu==0
        udat = zeros(Ndata, ny);
        for ku = 1:ny
            udat(:, ku) = ones(Ndata, 1)*ulevel(1, ku);
        end
        uu = iddata([], udat, Ts);
        uu = pvset(uu, 'Tstart', Tstart*Ts);
        zer = find(get(uu, 'SamplingInstants') == 0);
        int = zer:Ndata;
        y = zeros(Ndata, ny, ny);
        ysd = zeros(Ndata, ny, ny);
        for ku = 1:ny
            u1 = uu;
            u1.u(int, ku) = ones(size(int))*ulevel(2, ku);
            y1 = sim(sys1,u1,xss);
            y2 = pvget(y1, 'OutputData');
            y(1:length(y2{1}), :, ku) = y2{1};
        end
    end
    %%%%%

    t = pvget(y1, 'SamplingInstants');
    t = t{1};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function arg = low(arg)
for kk = 1:length(arg)
    if ischar(arg{kk})
        arg{kk} = lower(arg{kk});
    end
end
