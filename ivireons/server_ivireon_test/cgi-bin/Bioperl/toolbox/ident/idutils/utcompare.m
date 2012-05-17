function [yh1, fit, x01] = utcompare(varargin)
%UTCOMPARE  Utility code used by idmodel and idnlmodel COMPARE methods.

%   L. Ljung 10-1-89,10-10-93
%   R. Singh 02/05/08
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.21 $   $Date: 2010/03/31 18:22:42 $

%**************************************************************************
% Turning off uitabgroup warnings
%**************************************************************************
oldState = warning('off','MATLAB:uitabgroup:OldVersion');
warnCleaner = onCleanup(@() warning(oldState));
%**************************************************************************


%**************************************************************************
% Basic checking.
%**************************************************************************
ni = nargin;
no = nargout;
error(nargchk(2,Inf,ni,'struct'))

%**************************************************************************
% Parse for the special property-value pairs.
%**************************************************************************
init = []; initsel = false;
nr = [];
ychan = [];
hitnr = [];
chansel = 0;
nrsel = 0;
zwfwarn = false;
frdu =[]; %% G358959
inpn = varargin{end}; %Inputnames from the primary call.
varargin = varargin(1:end-1);
ni = ni-1;
for ki = 1:ni
    try
        pnmatchd(varargin{ki}, {'InitialState'});
        init = varargin{ki+1};
        initsel = true;
        hitnr = [hitnr(:); ki; ki+1];
    catch
    end
    if initsel
        if ischar(init)
            ini = lower(init(1));
            if ~any(ini == ['m' 'e' 'z'])
                ctrlMsgUtils.error('Ident:analysis:compareInvalidIni1')
            end
        elseif  ~isstruct(init) && (~isnumeric(init) || ndims(init)>2 || ~all(isfinite(init(:))))
            ctrlMsgUtils.error('Ident:analysis:compareInvalidIni2')
        end
    end
    try
        pnmatchd(varargin{ki}, {'Samples'});
        nr = varargin{ki+1};
        hitnr = [hitnr(:); ki; ki+1];
        nrsel = 1;
    catch
    end
    
    try
        pnmatchd(varargin{ki}, {'OutputPlots'});
        ychan = varargin{ki+1};
        chansel = 1;
        hitnr = [hitnr(:); ki; ki+1];
    catch
    end
    if (chansel && ~isa(ychan, 'cell'))
        ctrlMsgUtils.error('Ident:analysis:compareInvalidYnames')
    end
end

varargin(hitnr') = [];
ni = length(varargin);

%**************************************************************************
% Forgiving if iddata appears in wrong place.
%**************************************************************************
idi = find(cellfun('isclass',varargin,'iddata'));
% idi may be empty if data is provided using double matrix or idfrd/frd

if length(idi)>1
    ctrlMsgUtils.error('Ident:general:InvalidSyntax','compare','compare')
elseif ~isempty(idi) && idi~=1
    % rearrange to make data the first argument
    varargin = [varargin(idi), varargin([1:idi-1, idi+1:end])];
end

if ~any(strcmp(class(varargin{1}),{'iddata','double','idfrd','frd'}))
    ctrlMsgUtils.error('Ident:analysis:compareNoDataSupplied')
end

%**************************************************************************
% Parse input arguments for systems and plot styles.
%**************************************************************************

nsys = 0; nsysall = 0;     % Counts number of models.
sysname = {}; sysnames = {};
nstr = 0;      % Counts plot style strings.
sys = cell(1, ni-1);
%sysname = cell(1, ni);

if (sum(get(0, 'defaultAxesColor')) < 1.5)
    DefaultPlotStyle = repmat({'y' 'm' 'c' 'r' 'g' 'b'}, 1, ceil(ni/6)); % Dark background.
else
    DefaultPlotStyle = repmat({'b' 'g' 'r' 'c' 'm' 'y'}, 1, ceil(ni/6)); % Light background.
end
PlotStyle = repmat({''},1,ni);
lastsyst = 0;
modflag = false;
nlflag = false;
validmodelind = [];  %indices of non-empty models (in model set)
%emptysystcount = 0;
for jj = 2:ni
    argj = varargin{jj};
    if (isa(argj, 'idfrd') || isa(argj, 'frd'))
        ctrlMsgUtils.error('Ident:analysis:compareInvalidModel1')
    end
    if isa(argj, 'lti')
        argj = idss(argj);
    end
    if (isa(argj, 'idmodel') || isa(argj, 'idnlmodel'))
        nsysall = nsysall+1;
        if ~isempty(inpn{jj})
            sysnames{end+1} = ['''',inpn{jj},''''];
        else
            sysnames{end+1} = ['no. ',int2str(nsysall)];
        end
        lastsyst = jj; %index of last model
        modflag = true;
        if isa(argj, 'idnlmodel')
            nlflag = true;
        end
        if ~isempty(argj)
            %             if isa(argj, 'idnlmodel') && ~isestimated(argj) %% LL.
            %               error('Ident:analysis:comparenonestimatedmdl', ...
            %                       'One or more models has not been estimated.');
            %             end
            if isnan(argj)
                ctrlMsgUtils.error('Ident:analysis:compareInvalidModel2')
            end
            nsys = nsys+1;
            sys{nsys} = argj;
            sysname{nsys} = sysnames{end}; %inpn{jj};
            validmodelind(end+1) = nsysall;
            %lastsyst = jj;
            %modflag = true;
        else
            ctrlMsgUtils.warning('Ident:analysis:compareEmptyModel1',sysnames{end})
        end
    elseif ischar(argj) && modflag
        nstr = nstr+1;
        if ~isempty(argj)
            if ~all(ismember(argj, 'bBgGrRcCmMyYkKwW.oOxX+*sSdDvV^<>pPhH-:'))
                ctrlMsgUtils.error('Ident:analysis:unrecognizedLineStyle',argj)
            end
        end
        PlotStyle{nsysall} = argj;
        modflag = false;
    else
        break; % models exhausted (models are assumed to have been supplied together)
    end
end

%{
if initsel && ~isempty(init) && isnumeric(init) && (nsys>1)
    error('Ident:analysis:compareNumericX0withMultipleModels',...
        ['A numeric value for "InitialState" property cannot be used when the "compare" command is called with more than one models as inputs. ',...
        '\nThis is because the definition of initial states need not be the same for all models.'])
end
%}

if nsys==0
    ctrlMsgUtils.error('Ident:analysis:compareNoValidModels')
end

%lastsyst = lastsyst + emptysystcount;
if ~modflag
    lastsyst = lastsyst+1;
end

PlotStyle = PlotStyle(validmodelind);
Pind = cellfun('isempty',PlotStyle);
PlotStyle(Pind) = DefaultPlotStyle(1:sum(Pind));

%**************************************************************************
% Remaining input arguments.
%**************************************************************************
if (ni > lastsyst) % The prediction horizon was defined.
    m = varargin{lastsyst+1};
    if ~isempty(m) && (~isa(m,'double') || ~isscalar(m))
        ctrlMsgUtils.error('Ident:general:InvalidSyntax','compare','compare')
    end
else
    m = [];
end
if (ni > lastsyst+1) % The old syntax with trailing arguments has been used.
    [init1, nr1, ychan1] = oldsyntax(varargin{lastsyst+2:end});
    if ~isempty(init1)
        init = init1;
    end
    if ~isempty(ychan1)
        ychan = ychan1;
        chansel = 1;
    end
    if ~isempty(nr1)
        nr = nr1;
        nrsel = 1;
    end
end

nr = LocalCheckSampNumSpec(nr,nrsel);

%**************************************************************************
% Get info about the data set.
%**************************************************************************
z = varargin{1};
if isa(z, 'frd')
    z = idfrd(z);
end
if isa(z, 'idfrd')
    z = iddata(z, 'me');
    frdflag = true;
else
    frdflag = false;
end

if ~isa(z, 'iddata')
    % Create iddata objects from matrices.
    m1 = sys{1};
    if ~isa(z, 'double')
        ctrlMsgUtils.error('Ident:analysis:compareNoDataSupplied')
    end
    tsm = pvget(m1, 'Ts');
    if (tsm == 0)
        ttes = pvget(m1, 'Utility'); % This is really to honor old syntax.
        try
            tsm = ttes.Tsdata;
        catch
            ctrlMsgUtils.error('Ident:analysis:compareInvalidData1')
        end
    end
    ny = size(m1, 'ny');
    z = iddata(z(:, 1:ny), z(:, ny+1:end), tsm);
end

% Now z is iddata in every case.
[nrow, ny, nu, ne] = size(z);
y = pvget(z, 'OutputData');
ynam = pvget(z, 'OutputName');
yunit = pvget(z, 'OutputUnit');
unam = pvget(z, 'InputName');
sa = pvget(z, 'SamplingInstants');
if isnan(z)
    ctrlMsgUtils.error('Ident:analysis:compareInvalidData2')
end

zfflag = false; % To flag the presence of frequency 0 in FD data set.
ud = pvget(z, 'Utility');
dataid = datenum(ud.last);
if strcmp(pvget(z, 'Domain'), 'Frequency')
    if nlflag
        ctrlMsgUtils.error('Ident:analysis:compareFreqDataNLModel')
    end
    fre = pvget(z, 'SamplingInstants');
    for kexp = 1:length(fre)
        if any(fre{kexp} == 0)
            zfflag = true;
        end
    end
    if (nu == 0)
        ctrlMsgUtils.error('Ident:analysis:compareFreqDataTSModel')
    end
    fddata = true;
else
    fddata = false;
end
if isempty(init)
    if frdflag
        init = 'z';
    else
        init = 'e';
    end
end

if isempty(nr)
    nr = cell(1,ne);
    for kexp = 1:ne
        nr{kexp} = 1:nrow(kexp);
    end
end

if (length(nr) ~= ne)
    if ~frdflag
        ctrlMsgUtils.error('Ident:analysis:compareSamp1')
    else
        if length(nr)==1
            % scalar expansion
            nr = repmat(nr,1,ne);
        else
            ctrlMsgUtils.error('Ident:analysis:compareSamp2',ne)
        end
    end
end

% Compute channel numbers for plots.
if (chansel && ~no)
    yshow = [];
    for kch = 1:length(ychan)
        ynumb = find(strcmp(ychan{kch}, ynam));
        if isempty(ynumb)
            ctrlMsgUtils.warning('Ident:analysis:compareMissingOutputChannel',ychan{kch})
        else
            yshow = [yshow(:); ynumb];
        end
    end
    yshow = yshow';
    ny = length(yshow);
else
    yshow = (1:ny);
end

if isempty(yshow) && ~no
    % plot option, but no channels found
    ctrlMsgUtils.error('Ident:analysis:compareNoOutputChannelsFound')
end

% Translate intervals to absolute time and trim the output for plots.
timebeg = cell(ne, 1);
timeend = cell(ne, 1);
sampi = cell(ne, 1);
samp = cell(ne, 1);
yplot = cell(ne, 1);
ytplot = z(:, :, []);
if (nrsel || chansel)
    for kexp = 1:ne
        timebeg{kexp} = sa{kexp}(nr{kexp}(1));
        if (nr{kexp}(end) > length(sa{kexp}))
            ctrlMsgUtils.error('Ident:analysis:compareSamp3')
        end
        timeend{kexp} = sa{kexp}(nr{kexp}(end));
        sampi{kexp} = find((sa{kexp} >= timebeg{kexp}) & (sa{kexp} <= timeend{kexp}));
        samp{kexp} = sa{kexp}(sampi{kexp});
        yplot{kexp} = y{kexp}(sampi{kexp}, yshow);
    end
else
    for kexp = 1:ne
        sampi{kexp} = (nr{kexp}(1):nr{kexp}(end));
        samp{kexp} = sa{kexp}(sampi{kexp});
        yplot{kexp} = y{kexp}(sampi{kexp}, yshow);
    end
end
if ~no
    was = warning('off','Ident:iddata:MoreOutputsThanSamples');
    ytplot = pvset(ytplot, 'OutputData', yplot, 'SamplingInstants', samp,...
        'OutputName',ynam(yshow), 'OutputUnit',yunit(yshow));
    warning(was)
end

%**************************************************************************
% Some checks about the prediction horizon.
%**************************************************************************
if isempty(m)
    m = Inf;
end
if ~isinf(m)
    if (m < 1) || (m ~= floor(m))
        ctrlMsgUtils.error('Ident:analysis:predHorizon2')
    end
    
    if (m >= min(nrow))
        ctrlMsgUtils.warning('Ident:analysis:predHorizon1')
        m = Inf;
    end
    
    if strcmp(pvget(z, 'Domain'), 'Frequency')
        ctrlMsgUtils.warning('Ident:analysis:predHorizon3')
        m = Inf;
    end
end
if (frdflag && (init == 'e'))
    ctrlMsgUtils.warning('Ident:analysis:X0estForIDFRD')
    init = 'z';
end

%**************************************************************************
% Now compute the model outputs.
%**************************************************************************
yh = cell(nsys, 1);
x01 = cell(nsys, 1);
fit = zeros(ne, nsys, ny);
if ~no
    yhplot = cell(nsys, 1);
end
sysname1 = sysname;
for ksys = 1:nsys
    zflag = false; % To flag that zero frequency is removed.
    sampizf = sampi; % These are for this particular model.
    sampzf = samp;
    th = sys{ksys};
    try
        sysname1{ksys} = eval(sysname{ksys});
    catch
        sysname1{ksys} = '';
    end
    
    % Remove zero frequency if there is an integrator in the FD case.
    if zfflag
        was = ctrlMsgUtils.SuspendWarnings;
        fr = freqresp(th, 0);
        delete(was)
        if any(~isfinite(fr(:)))
            zflag = true;
            for kexp = 1:ne
                kz = find(samp{kexp} == 0);
                if ~isempty(kz),
                    if ~zwfwarn
                        ctrlMsgUtils.warning('Ident:analysis:zeroFrequencyRemoved2',sysname{ksys})
                    end
                    zwfwarn = true;
                    sampizf{kexp}(kz) = [];
                    sampzf{kexp} = sa{kexp}(sampizf{kexp});
                end
            end
        end
    end
    
    % Idmodel conversions.
    th = pvset(th, 'CovarianceMatrix', 'None');
    if isa(th, 'idmodel')
        if isinf(m)
            th = th('m');
        end
        if ~isa(th, 'idgrey')
            th = idss(th);
        end
    end
    
    % Time-series checks.
    una = th.InputName;
    yna = th.OutputName;
    if isempty(una)
        if fddata
            ctrlMsgUtils.error('Ident:analysis:compareTSFreqData')
        end
        if isinf(m)
            ctrlMsgUtils.error('Ident:analysis:compareTSPredictionHorizon')
        end
    end
    
    % Check channels in model and data.
    yni = ynam(ismember(ynam, yna));
    uni = unam(ismember(unam, una));
    if isempty(yni)
        ctrlMsgUtils.warning('Ident:analysis:compareNoModelOutputFound',sysname{ksys})
    elseif false %isempty(uni)
        %{
            warning('Ident:analysis:compareNoModelInputFound', ...
            ['All inputs required for model ' sysname{ksys} ...
            ' are missing in the data set.\nPlease check input names' ...
            ' for data and this model.']);
        %}
    else
        if ((length(yni) ~= length(yna)) || (length(uni) ~= length(una)))
            % Not all model channels present in data.
            if isempty(uni)
                uni = [];
            end
            if isa(th, 'idmodel')
                th = th(yni, uni);
            end
            if ((length(yni) ~= length(yna)) && ~isinf(m))
                if isa(th, 'idnlmodel')
                    % Idnlmodel requires all output channels
                    ctrlMsgUtils.warning('Ident:analysis:compareMissingOutputData1',sysname{ksys})
                    continue;
                else
                    ctrlMsgUtils.warning('Ident:analysis:compareMissingOutputData2',sysname{ksys})
                end
            end
            if (length(uni) ~= length(una))
                if isa(th, 'idnlmodel')
                    % Idnlmodel requires all input channels
                    ctrlMsgUtils.warning('Ident:analysis:compareMissingInputData1',sysname{ksys})
                    continue;
                else
                    ctrlMsgUtils.warning('Ident:analysis:compareMissingInputData2',sysname{ksys})
                end
            end
        end
        
        if frdflag %%%special fix for geck 358959
            frdu(:,ksys) = ismember(unam,una);
        end
        z1 = z(:, yni, uni);
        if isa(th, 'idmodel')
            th = th(yni, uni);
        end
        
        if isempty(th)
            if isinf(m)
                ctrlMsgUtils.warning('Ident:analysis:compareEmptyModel2',sysname{ksys})
            else
                ctrlMsgUtils.warning('Ident:analysis:compareEmptyModel3',sysname{ksys})
            end
            continue;
        end
        
        % Check and modify initial states.
        ksysinit = init;
        %         if (isa(th, 'idnlhw') && ischar(ksysinit))
        %             ksysinit = 'z';
        %         end
        if (isa(th, 'idmodel') && (norm(pvget(th, 'InputDelay')) > 0) &&...
                ischar(init) && strcmpi(init,'e'))
            ksysinit = 'd';
            try
                nk = pvget(th,'nk');
            catch
                sz = size(th);
                nk = zeros(sz(1:2));
            end
            if ~fddata
                if pvget(th,'Ts')
                    udel = pvget(th,'InputDelay');
                else
                    udel = pvget(th,'InputDelay');
                    Ts = pvget(z1,'Ts'); Ts = Ts{1};
                    udel = udel/Ts;
                end
                if any(max(udel+max(nk)')>size(z1,'N')*0.1)
                    %todo: udel+nk>Nsamp?
                    ctrlMsgUtils.warning('Ident:analysis:compareLongDelay',...
                        floor(max(udel+max(nk)')),sysname{ksys})
                end
            end
        end
        %{
        if (isa(th, 'idnlarx') && isnumeric(ksysinit))
            ksysinit = 'e';
        end
        %}
        if (isa(th, 'idmodel') && isa(ksysinit, 'iddata'))
            ksysinit = 'e';
        end
        
        % The main calculation.
        if zflag
            was = ctrlMsgUtils.SuspendWarnings;
            [yh{ksys}, x01{ksys}] = predict(th, z1, m, ksysinit);
            delete(was); 
        else
            [yh{ksys}, x01{ksys}] = predict(th, z1, m, ksysinit);
        end
        yhh = pvget(yh{ksys}, 'OutputData');
        yhnam = pvget(yh{ksys}, 'OutputName');
        if ~no
            yhhplot = yhh;
        end
        
        % Compute fit.
        for kexp = 1:ne
            for ky = yshow
                kyy = find(strcmp(ynam{ky}, yhnam));
                if ~frdflag||(frdflag&&frdu(kexp,ksys)) %%%Fix for geck 358959
                    if ~isempty(kyy)
                        err = norm(yhh{kexp}(sampizf{kexp}, kyy) - y{kexp}(sampizf{kexp}, ky));
                        meanerr = norm(y{kexp}(sampizf{kexp}, ky) - mean(y{kexp}(sampizf{kexp}, ky)));
                        fit(kexp, ksys, ky) = 100*(1-err/meanerr);
                    else
                        fit(kexp, ksys, ky) = Inf;
                    end
                else
                    fit(kexp, ksys, ky) = NaN;
                end
            end
            
            % Select channels and samples for plot.
            if ~no
                if (chansel || nrsel || zflag)
                    yhhplot{kexp} = yhhplot{kexp}(sampizf{kexp}, :); %yshow
                end
            end
        end
        if ~no
            yhtmp = yh{ksys};
            was = ctrlMsgUtils.SuspendWarnings('Ident:iddata:MoreOutputsThanSamples');
            if fddata
                RespFr = pvget(yhtmp,'SamplingInstants');
                for ct = 1:ne
                    if ~isequal(length(sampzf{ct}),length(yhhplot{ct}))
                        yhhplot{ct} = yhhplot{ct}(ismember(RespFr{ct},sampzf{ct}));
                    end
                end
            end
            yhplot{ksys} = pvset(yhtmp, 'OutputData', yhhplot, 'SamplingInstants', sampzf);
            delete(was);
        end
        
        %******************************************************************
        % Update the advice-section for linear models.
        %******************************************************************
        if isa(sys{ksys}, 'idmodel')
            adv = getadv(sys{ksys});
            samedat = false;
            try
                fitadv = adv.compare.fit;
                if (dataid == adv.compare.DataId)
                    samedat = true;
                end
            catch
                fitadv = [];
            end
            fff = squeeze(fit(:, ksys, :));
            if ~samedat
                % If not the same data as for previous fit, then delete the old info.
                adv.compare.DataId = dataid;
                adv.compare.fit =[m*ones(size(fff)) fff];
            else
                try
                    fitadv = [fitadv; [m*ones(size(fff)) fff]];
                catch
                    fitadv = [m*ones(size(fff)) fff];
                end
                adv.compare.fit = fitadv;
            end
            
            % Advice on prediction horizon.
            ut = pvget(sys{ksys}, 'Utility');
            ut.advice = adv;
            th = uset(sys{ksys}, ut);
            try
                assignin('caller', sysname1{ksys}, th);
            end
        end
    end
end

%**************************************************************************
% Finish and plot if required.
%**************************************************************************
if no
    yh1 = yh;
else
    if ~isempty(yshow)
        % Remove models that could not be simulated or predicted.
        
        %{
        modind = 1;
        for ksys = 1:nsys
            if isa(yhplot{ksys}, 'iddata')
                modind = [modind(:); ksys+1];
            end
        end
        %}
        ismod = cellfun('isclass',yhplot,'iddata');
        if ~all(ismod)
            yhplot = yhplot(ismod);
            fit = fit(:,ismod,:);
            sysname1 = sysname1(ismod);
            PlotStyle = PlotStyle(ismod);
            if ~isempty(frdu) && frdflag
                frdu = frdu(:,ismod);
            end
        end
        data = {ytplot yhplot{:}};
        %{
        if (length(modind) < nsys+1)
            data = {data{modind}};
            fit = fit(:, modind(2:end)-1, :);
            sysname1 = {sysname1{modind}};
            PlotStyle = {PlotStyle{modind(2:end)-1}};
            if ~isempty(frdu) && frdflag
                frdu = frdu(:,modind(2:end)-1);
            end
        end
        %}
        
        % Reconcile fit values with measured data
        [dum,Ind] = ismember(data{1}.yname, ynam);
        if any(Ind>0) && ~isempty(fit)
            fit = fit(:,:,Ind);
        end
        compareplot(data, fit, sysname1, PlotStyle, frdflag, m, inpn{1}, frdu);
    end
    clear yh1 fit x01;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local functions.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [init, nr, ychan] = oldsyntax(varargin)
% Convert old syntax to new syntax.
init = [];
nr = [];
ychan = [];
ychantest = varargin{end};
narg = length(varargin);
if (iscell(ychantest) && ischar(ychantest{1})) % Channels are specified.
    ychan = ychantest;
    varargin = varargin(1:end-1);
    narg = length(varargin);
end
if (narg >= 2)
    init = varargin{2};
end
if (narg >= 1)
    nr = varargin{1};
    if ~isa(nr,'double')
        ctrlMsgUtils.error('Ident:general:InvalidSyntax','compare','compare')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  nr = LocalCheckSampNumSpec(nr,nrsel)
% Check sample number specification

if isempty(nr)
    nr = [];
    return
end

if ~iscell(nr)
    nr = {nr};
end

ne = numel(nr);
if nrsel
    if any(cellfun(@(x)~isnumeric(x) || ~isvector(x) || ~all(isfinite(x)),nr))
        if ne==1
            ctrlMsgUtils.error('Ident:analysis:compareInvalidSamp1')
        else
            ctrlMsgUtils.error('Ident:analysis:compareInvalidSamp2')
        end
    elseif any(cellfun(@(x)isscalar(x),nr))
        if ne==1
            ctrlMsgUtils.error('Ident:analysis:compareInvalidSamp3')
        else
            ctrlMsgUtils.error('Ident:analysis:compareInvalidSamp4')
        end
    else
        nr = cellfun(@unique,nr,'UniformOutput',false);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compareplot(data, fit, name, plotstyle, frdflag, m, inname,frdu)
%Plots the outputs obtained by compare.

name = [{inname}, name];
% Determine plotstyle.
cols = get(0, 'defaultAxesColor');
if (sum(cols) < 1.5)
    plotstyle = {'w' plotstyle{:}};
else
    plotstyle = {'k' plotstyle{:}};
end

% Determine the name of the figure.
figname = pvget(data{1}, 'Name');
if isempty(figname)
    figname = '';
end

% Retrieve variables from data.
ne = size(data{1}, 'ne');
ny = size(data{1}, 'ny');
ExperimentName = pvget(data{1}, 'ExperimentName');
OutputName = pvget(data{1}, 'OutputName');
OutputUnit = pvget(data{1}, 'OutputUnit');
Domain = pvget(data{1}, 'Domain');
if strcmpi(Domain, 'time')
    Unit = pvget(data{1}, 'TimeUnit');
else
    Unit = pvget(data{1}, 'Tstart');
    Unit = Unit{1};
end
imagflag = ~isreal(data{1});

% Plotting.
if (usejava('awt') && (ne > 1))
    % Plot with one tab per experiment.
    figh = gcf;
    clf(figh);
    set(figh, 'Name', figname, 'NextPlot', 'replacechildren');
    set(0, 'CurrentFigure', figh);
    h = uitabgroup();
    tab = zeros(ne, 1);
    for i = 1:ne
        if isempty(ExperimentName{i})
            ExperimentName{i} = ['Exp' int2str(i)];
        end
        tab(i) = uitab(h, 'title', ExperimentName{i});
        axes('parent', tab(i));
        for j = 1:ny
            % Plot measured output and set title.
            subplot(ny, 1, j);
            set(gca, 'NextPlot', 'replace');
            curdata = getexp(data{1}, i);
            sa = pvget(curdata, 'SamplingInstants');
            if imagflag
                plot(sa{1}, abs(curdata.y(:, j)), plotstyle{1});
            else
                plot(sa{1}, curdata.y(:, j), plotstyle{1});
            end
            if frdflag
                title('Frequency functions.');
            else
                if ~isempty(OutputName{j})
                    titletxt = [OutputName{j} '. '];
                else
                    titletxt = '';
                end
                if isinf(m)
                    title([titletxt '(sim)']);
                else
                    title([titletxt '(' int2str(m) '-step pred)']);
                end
            end
            legtxt = {};
            if frdflag
                if isempty(inname)
                    legtxt{1} = 'Given function';
                else
                    legtxt{1} = ['Function: ' inname];
                end
            elseif isempty(name{1})
                legtxt{1} = 'Measured';
            else
                legtxt{1} = [name{1} '; measured'];
            end
            
            % Plot model output(s).
            set(gca, 'NextPlot', 'add');
            legind = 2;
            for k = 2:length(data)
                curdata = getexp(data{k}, i);
                if ~isempty(strmatch(data{1}.OutputName{j}, curdata.OutputName, 'exact'))
                    curdata = curdata(:, data{1}.OutputName{j}, :);
                    sa = pvget(curdata, 'SamplingInstants');
                    if imagflag
                        plot(sa{1}, abs(curdata.y(:, 1)), plotstyle{k});
                    else
                        plot(sa{1}, curdata.y(:, 1), plotstyle{k});
                    end
                    if ~frdflag||(frdflag&&frdu(i,k-1)) %%%special fix for geck 358959
                        if isempty(name{k})
                            legtxt{legind} = ['fit: ' sprintf('%0.4g', fit(i, k-1, j)) '%'];
                        else
                            legtxt{legind} = [name{k} '; fit: ' sprintf('%0.4g', fit(i, k-1, j)) '%'];
                        end
                        legind = legind+1;
                    end %%%
                end
            end
            if frdflag
                set(gca, 'NextPlot', 'replace', 'xscale', 'log', 'yscale', 'log');
            else
                set(gca, 'NextPlot', 'replace');
            end
            
            % Create legend and set x- and y-label.
            legend(legtxt{:}, 'Location', 'BestOutside');
            if ~isempty(OutputUnit{j})
                if imagflag
                    ylabel(['abs(', OutputName{j}, ') (' OutputUnit{j} ')']);
                else
                    ylabel([OutputName{j}, ' (' OutputUnit{j} ')']);
                end
            elseif imagflag
                ylabel(['abs(', OutputName{j}, ')']);
            else
                ylabel(OutputName{j});
            end
            if ((j == ny) && ~isempty(Unit))
                xlabel([Domain ' (' Unit ')']);
            end
            axis('tight');
        end
    end
    set(figh,'NextPlot','replacechildren');
else
    % Standard plot without tabs.
    for i = 1:ne
        if (isempty(ExperimentName{i}) || (ne == 1))
            expname = '';
        else
            expname = ['. ' ExperimentName{i}];
        end
        if (i == 1)
            figh = gcf;
            clf(figh);
            set(figh, 'Name', [figname expname], 'NextPlot', 'replacechildren');
            set(0, 'CurrentFigure', figh);
        else
            figh = figure('Name', [figname expname]);
        end
        if ~isempty(expname)
            expname = [expname(3:end) '. '];
        end
        for j = 1:ny
            % Plot measured output and set title.
            subplot(ny, 1, j);
            set(gca, 'NextPlot', 'replace');
            curdata = getexp(data{1}, i);
            sa = pvget(curdata, 'SamplingInstants');
            if imagflag
                plot(sa{1}, abs(curdata.y(:, j)), plotstyle{1});
            else
                plot(sa{1}, curdata.y(:, j), plotstyle{1});
            end
            if frdflag
                title([expname 'Frequency functions.']);
            else
                if ~isempty(OutputName{j})
                    titletxt = [expname OutputName{j} '. '];
                else
                    titletxt = expname;
                end
                if isinf(m)
                    title([titletxt '(sim)']);
                else
                    title([titletxt '(' int2str(m) '-step pred)']);
                end
            end
            legtxt = {};
            if frdflag
                if isempty(inname)
                    legtxt{1} = 'Given function';
                else
                    legtxt{1} = ['Function: ' inname];
                end
            elseif isempty(name{1})
                legtxt{1} = 'Measured';
            else
                legtxt{1} = [name{1} '; measured'];
            end
            
            % Plot model output(s).
            set(gca, 'NextPlot', 'add');
            legind = 2;
            for k = 2:length(data)
                curdata = getexp(data{k}, i);
                if ~isempty(strmatch(data{1}.OutputName{j}, curdata.OutputName, 'exact'))
                    curdata = curdata(:, data{1}.OutputName{j}, :);
                    sa = pvget(curdata, 'SamplingInstants');
                    if imagflag
                        plot(sa{1}, abs(curdata.y(:, 1)), plotstyle{k});
                    else
                        plot(sa{1}, curdata.y(:, 1), plotstyle{k});
                    end
                    if isempty(name{k})
                        legtxt{legind} = ['fit: ' sprintf('%0.4g', fit(i, k-1, j)) '%'];
                    else
                        legtxt{legind} = [name{k} '; fit: ' sprintf('%0.4g', fit(i, k-1, j)) '%'];
                    end
                    legind = legind+1;
                end
            end
            if frdflag
                set(gca, 'NextPlot', 'replace', 'xscale', 'log', 'yscale', 'log');
            else
                set(gca, 'NextPlot', 'replace');
            end
            
            % Create legend and set x- and y-label.
            legend(legtxt{:}, 'Location', 'BestOutside');
            if ~isempty(OutputUnit{j})
                if imagflag
                    ylabel(['abs(', OutputName{j}, ') (' OutputUnit{j} ')']);
                else
                    ylabel([OutputName{j}, ' (' OutputUnit{j} ')']);
                end
            elseif imagflag
                ylabel(['abs(', OutputName{j}, ')']);
            else
                ylabel(OutputName{j});
            end
            if ((j == ny) && ~isempty(Unit))
                xlabel([Domain ' (' Unit ')']);
            end
            axis('tight');
        end
        set(figh,'NextPlot','replacechildren');
    end
end

