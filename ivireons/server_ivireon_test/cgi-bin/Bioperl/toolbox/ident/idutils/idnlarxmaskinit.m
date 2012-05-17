function varargout = idnlarxmaskinit(Action, varargin)
%Mask initialization function for Nonlinear ARX Model block.

% [X0,Ts,WarnMsg] = idnlarxmaskinit('initialization', CB,sys,Y0);
% idnlarxmaskinit('maskparamcallback',gcb);

% Written by: Rajiv Singh
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/31 06:14:02 $

switch Action
    case 'maskparamcallback'
        LocalMaskParam1Callback(varargin{:});
    case 'initialization'
        %{
        if ~any(strcmp(get_param(bdroot(CB),'SimulationStatus'),{'initializing','updating'})) %todo: add 'stopped'?
            % purpose: stop execution when in library
            % this also prevents updates during copy, paste, click, etc
            % partial alternative: use BlockDiagramType property (?) to stop update
            % in library
            % todo: figure out the best way

            return
        end
        %}

        [varargout{1:3}] = LocalUpdateDiagram(varargin{:}); %inputs: CB,sys,IC,Y0
end

%--------------------------------------------------------------------------
function LocalMaskParam1Callback(CB)

maskStr = get_param(CB,'MaskValues');
MaskPrompts = get_param(CB,'MaskPrompts');
maskEn = get_param(CB,'MaskEnables');


try
    sys = slResolve(maskStr{1},CB); %LocalEvaluate(maskStr{1},bdroot(CB));
catch %#ok<CTCH>
    sys = [];
end

if ~isempty(sys) && isa(sys,'idnlarx')
    [ny,nu] = size(sys);
    AllMaxDelays = LocalGetModelInfo(sys,ny,nu);
    Nx = sum(AllMaxDelays);

    MaskPrompts{3} = sprintf('Specify initial states as a vector of %d values.',Nx);

    if nu==1
        MaskPrompts{4} = 'Input level (scalar)';
    else
        MaskPrompts{4} = 'Input levels (scalar or vector of length equal to number of model inputs)';
    end
    if ny==1
        MaskPrompts{5} = 'Output level (scalar)';
    else
        MaskPrompts{5} = 'Output levels (scalar or vector of length equal to number of model outputs)';
    end

    % {
    if nu==0
        maskEn{4} = 'off';
    else
        maskEn{4} = 'on';
    end
    %}
    
    set_param(CB,'MaskPrompts',MaskPrompts,'MaskEnables',maskEn);
end

%--------------------------------------------------------------------------
function [X0, Ts, WarnMsg] = LocalUpdateDiagram(CB,sys,IC,X0,U0,Y0)

if ~isa(sys,'idnlarx')
    ctrlMsgUtils.error('Ident:simulink:invalidNLModel','Nonlinear ARX','IDNLARX');
elseif isestimated(sys)==0 %could be 0, +/-1
    ctrlMsgUtils.error('Ident:idnlmodel:unestimatedModel')
end

% load identextras to copy blocks
load_system('identextras')

[ny,nu] = size(sys);
Ts = sys.Ts;

% clear out all contents of subsystem representing idnlarx model (CB)
h = LocalGetDeletableItems(CB);

if ~isempty(h) %&& all(ishandle(h))
    delete_block(h);
end
delete(find_system(CB,'FollowLinks','on','LookUnderMasks','all',...
    'SearchDepth',1,'FindAll','on','type','line'))

fInp = find_system(CB,'FollowLinks','on','LookUnderMasks','all',...
    'SearchDepth',1,'Name','In1');

if nu>0 && isempty(fInp)
    add_block('built-in/Inport',[CB,'/In1'],'Position',[20   133    50   147])
elseif nu==0 && ~isempty(fInp)
    delete_block(fInp);
end

% get model info
[AllMaxDelays, CumInd, LenCusts] = LocalGetModelInfo(sys,ny,nu);
Nxy = sum(AllMaxDelays(1:ny)); % number of states from output(s)
Nxu = sum(AllMaxDelays(ny+1:ny+nu)); % number of states from input(s)
Nx = Nxy+Nxu;

% determine initial states to use for tapped delay line(s)
[X0,WarnMsg] = LocalComputeInitialStates(sys,IC,X0,U0,Y0,AllMaxDelays,Nx,nu,ny);

TDLyblkName = LocalAddTDL(CB,Ts,AllMaxDelays(1:ny),X0(1:Nxy),'y');
TDLublkName = LocalAddTDL(CB,Ts,AllMaxDelays(ny+1:ny+nu),X0(Nxy+1:end),'u');

% Note: numPorts is at least one because the situation where there are no
% model regressors (nu=0 and nx=0) is not allowed.
numPorts = 3-isempty(TDLyblkName)-isempty(TDLublkName)-(nu==0);

refPos = [255,17,260,max(65*numPorts,56*ny)+18]; %reference position for some blocks
if Nx>0 % there is at least one state
    % add a XU BUS block
    uxBus = add_block('built-in/BusCreator',[CB,'/XUBus'],...
        'Inputs',num2str(numPorts),'Position',refPos);

    % connect TDL blocks with UX Bus
    uxBusName = get(uxBus,'Name');
    ii = 1;
    if ~isempty(TDLyblkName)
        add_line(CB,[TDLyblkName,'/1'],[uxBusName,'/',num2str(ii)]);
        ii = ii+1;
    end

    if ~isempty(TDLublkName)
        add_line(CB,[TDLublkName,'/1'],[uxBusName,'/',num2str(ii)]);
        ii = ii+1;
    end
    if nu~=0
        add_line(CB,'In1/1',[uxBusName,'/',num2str(ii)],'autorouting','on');
    end

    inName = uxBusName; % input to UX2Reg block
else
    % nu cannot be zero if nx==0; so the following setting is valid
    inName = 'In1/1';   % input to UX2Reg block
end

% add per-output elements: regressor selector and nonlinearity S functions
outName = LocalAddPerOutputBlocks(CB,sys,CumInd,LenCusts,Ts,Nx,ny,inName,refPos);

% connect everything
add_line(CB,[outName,'/1'],'Out1/1','autorouting','on');
if ~isempty(TDLyblkName)
    %connect input of TDLyblk to model output
    add_line(CB,[outName,'/1'],[TDLyblkName,'/1'],'autorouting','on');
end

if ~isempty(TDLublkName)
    %connect input of TDLublk to model input
    add_line(CB,'In1/1',[TDLublkName,'/1'],'autorouting','on');
end

%--------------------------------------------------------------------------
function outName = LocalAddPerOutputBlocks(...
    CB,sys,CumInd,LenCusts,Ts,Nx,ny,inName,Pos)

% add output bus
if ny>1
    outBus = add_block('built-in/BusCreator',[CB,'/OutputBus'],...
        'Inputs',num2str(ny),'DisplayOption','bar',...
        'Position',[605,15,610,55*ny+15]);
    outBusName = get(outBus,'Name');
end

NL = get(sys,'Nonlinearity');
na = sys.na; nb = sys.nb; %nk = sys.nk;
% compute std regressor subset selector (gain) matrix
Kcell = state2stdreg(sys,Nx,CumInd);

for ky = 1:ny
    K = Kcell{ky};
    len = sum(na(ky,:))+sum(nb(ky,:));

    if LenCusts(ky)>0
        pv = {'ModelVar','sys','ny',num2str(ny),'ynum',num2str(ky),...
            'cumDel',mat2str(CumInd-1,100),'Nx',num2str(Nx)};
    else
        pv = {};
    end

    pos = [Pos(1)+45, Pos(2)+70*(ky-1), Pos(1)+150, Pos(2)+70*(ky-1)+40];
    ux2regblk = add_block('identextras/UX2Reg',[CB,'/UX2Reg'],...
        'MakeNameUnique','on','Position',pos,'K',mat2str(K,100),pv{:});

    ux2regblkName = get(ux2regblk,'Name');
    add_line(CB,[inName,'/1'],[ux2regblkName,'/1'],'autorouting','on');

    CB1 = [CB,'/',ux2regblkName];
    if LenCusts(ky)>0
        % there are custom regressors for this output
        blkc = add_block('identextras/EvalCustomReg',[CB1,'/EvalCustomReg'],...
            'Position',[170,130,240,160]);
        blkcName = get(blkc,'Name');
        add_line(CB1,'XU/1',[blkcName,'/1'],'autorouting','on');
        % add and connect an output bus
        add_block('built-in/BusCreator',[CB1,'/OutputBus'],...
            'Inputs','2','DisplayOption','bar',...
            'Position',[275,40,280,115]);
        add_line(CB1,'Standard Regressors/1','OutputBus/1','autorouting','on');
        add_line(CB1,[blkcName,'/1'],'OutputBus/2','autorouting','on');
        add_line(CB1,'OutputBus/1','Regressors/1','autorouting','on');
    else
        add_line(CB1,'Standard Regressors/1','Regressors/1','autorouting','on');
    end

    NumReg = len+LenCusts(ky);
    NLi = NL(ky);
    nlblk = LocalAddNLBlock(CB,NLi,ky,pos,NumReg,Ts);
    nlblkName = get(nlblk,'Name');
    add_line(CB,[ux2regblkName,'/1'],[nlblkName,'/1'],'autorouting','on');
    if ny>1
        add_line(CB,[nlblkName,'/1'],[outBusName,'/',num2str(ky)],...
            'autorouting','on');
        outName = outBusName;
    else
        outName = nlblkName;
    end
end


%--------------------------------------------------------------------------
function TDLblkName = LocalAddTDL(CB,Ts,Delays,X0i,Name)
% Add a tapped delay line based on specified delays
% X0i: piece of X0 vector for input/or output.

TDLblkName = '';

if sum(Delays)==0
    return;
end

Pos = [145,28,216,72];
if strncmpi(Name,'u',1);
    Pos = Pos+[0,65,0,65];
end

% add a tapped delay line subsystem
TDLblk = add_block('built-in/Subsystem',[CB,'/TDL',Name],...
    'Position',Pos); %empty subsys
TDLblkName = get(TDLblk,'Name');
thisCB = [CB,'/',TDLblkName];

% add IO ports
add_block('built-in/Inport',[thisCB,'/InTDL'],...
    'Position',[45,110,65,130]);    %input port
add_block('built-in/Outport',[thisCB,'/OutTDL'],...
    'Position',[425,105,445,125]);  %output port

N = numel(Delays);
NumTDL = sum(Delays>0);
if NumTDL>1
    % add demux
    Demuxblk = add_block('built-in/Demux',[thisCB,'/inDemux'],...
        'DisplayOption','bar','Outputs',num2str(N),...
        'Position',[105,12,110,70*NumTDL-3]);
    LeftblkName = get(Demuxblk,'Name');
    add_line(thisCB,'InTDL/1',[LeftblkName,'/1'],'autorouting','on');
else
    LeftblkName = 'InTDL';
end

if NumTDL>1
    % add a Bus
    Busblk = add_block('built-in/BusCreator',[thisCB,'/outBus'],...
        'Inputs',num2str(NumTDL),'Position',[255,12,260,70*NumTDL-3]);
    RightblkName = get(Busblk,'Name');
    add_line(thisCB,[RightblkName,'/1'],'OutTDL/1','autorouting','on');
else
    RightblkName = 'OutTDL';
end

load_system('simulink');
tdlpath = 'simulink/Discrete/Tapped Delay';
refpos = [170,36,205,72];
ii = 0;
offset = 0;
for k = 1:N
    if Delays(k)>0
        tdlk = add_block(tdlpath,[thisCB,'/TDL',num2str(k)],...
            'NumDelays',num2str(Delays(k)),'DelayOrder','Newest',...
            'samptime',mat2str(Ts,16),...
            'vinit',mat2str(X0i(offset+1:offset+Delays(k)),100),...
            'Position',refpos+(k-1)*[0,70,0,70]);
        ii = ii+1;
        offset = offset+Delays(k);
        tdlkName = get(tdlk,'Name');
        add_line(thisCB,[LeftblkName,'/',num2str(k)],[tdlkName,'/1'],...
            'autorouting','on');
        add_line(thisCB,[tdlkName,'/1'],[RightblkName,'/',num2str(ii)],...
            'autorouting','on');
    else
        % put a signal terminator
        terk = add_block('built-in/Terminator',[thisCB,'/Terminator',num2str(k)],...
            'Position',refpos+(k-1)*[0,70,0,70]);
        terName = get(terk,'Name');
        add_line(thisCB,[LeftblkName,'/',num2str(k)],[terName,'/1'],...
            'autorouting','on');
    end
end

%--------------------------------------------------------------------------
function blk = LocalAddNLBlock(CB,NL,Ind,refpos,NumReg,Ts)
% add a nonlinearity block from identextras with right parameter config

pos = refpos+[125,0,125,0];

%todo: is there a better way of passing vector data to a block?
CommonPV = {'MakeNameUnique','on','Position',pos,'Ts',mat2str(Ts,16),...
    'NumReg',num2str(NumReg)};

Pars = LocalGetParList(NL, Ind);

switch class(NL)
    case 'treepartition'
        % note: Parameters 'sys' and 'Y0' are automatically available to
        % nonlinearity blocks
        Block_Source = 'Tree Partition Estimator';
        Block_Name   = 'TreePartition';

    case 'linear'
        Block_Source = 'Linear Estimator';
        Block_Name   = 'Linear';

    case 'wavenet'
        Block_Source = 'Wavenet Estimator';
        Block_Name   = 'Wavenet';

    case 'sigmoidnet'
        Block_Source = 'Sigmoidnet Estimator';
        Block_Name   = 'Sigmoidnet';

    case 'pwlinear'
        Block_Source = 'Pwlinear Estimator';
        Block_Name   = 'Pwlinear';

    case 'neuralnet'
        Block_Source = 'Nonlinearity Estimator';
        Block_Name   = 'Neuralnet';

    case 'customnet'
        Block_Source = 'Nonlinearity Estimator';
        Block_Name   = 'Customnet';

    otherwise
        ctrlMsgUtils.error('Ident:simulink:UnknownNL',class(NL));
end

blk = add_block(['identextras/',Block_Source], [CB,'/',Block_Name],CommonPV{:},Pars{:});

%--------------------------------------------------------------------------
function deletableItems = LocalGetDeletableItems(CB)

allItems = find_system(CB,'FollowLinks','on','LookUnderMasks','all',...
    'SearchDepth',1);
lvl0Items = find_system(CB,'FollowLinks','on','LookUnderMasks','all',...
    'SearchDepth',0); %'FindAll','on'
lvl1Items = setdiff(allItems,lvl0Items);
doNotDeleteItems = find_system(lvl1Items,'Name','In1');
doNotDeleteItems = [doNotDeleteItems, find_system(lvl1Items,'Name','Out1')];
deletableItems = setdiff(lvl1Items,doNotDeleteItems);

%--------------------------------------------------------------------------
function [AllMaxDelays, cumInd, LenCusts] = LocalGetModelInfo(sys,ny,nu)
% MaxDelays: calculate maximum delay on each I/O channel for each
% nonlinearity
%
%
% LenCusts: Length of custom regressors for each outputs (ny-by-1 vector)

na = sys.na; nb = sys.nb; nk = sys.nk;

custs = sys.CustomRegressors;
if ny==1
    custs = {custs};
end

MaxDelays = zeros(ny,ny+nu);
LenCusts = zeros(ny,1);

for k = 1:ny
    MaxDel = zeros(1,ny+nu);
    cust = custs{k};
    LenCust = numel(cust);
    if LenCust>0
        % parse each variable in k'th nonlinearity's custom regressor list
        for i = 1:ny+nu
            Delij = 0;
            for j = 1:LenCust
                Ind = find(cust(j).ChannelIndices == i); % could be non-scalar
                if ~isempty(Ind)
                    thisdel = cust(j).Delays(Ind);
                    Delij = max([Delij,thisdel]); % delay of y_i or u_(i-ny) in reg{i}(j)

                end %if
            end %j
            MaxDel(i) = Delij;
        end %i
    end %if
    MaxDel = max(MaxDel,[na(k,:),nb(k,:)+nk(k,:).*(nb(k,:)>0)-1]);
    MaxDelays(k,:) = MaxDel;
    LenCusts(k) = LenCust;
end

AllMaxDelays = max(MaxDelays,[],1); % max channel delays across all outputs
%Nx = sum(AllMaxDelays);             % number of states
cumDel = cumsum(AllMaxDelays)+1;
cumInd = [1,cumDel(1:end-1)];

%--------------------------------------------------------------------------
function Pars = LocalGetParList(NL,CInd)
% return PV pairs for NL's parameters required for simulation

switch class(NL)
    case 'treepartition'
        par = NL.Parameters;
        thresh = NL.Options.Threshold;
        if ischar(thresh)
            thresh = 1;
        end
        Pars = {'NumUnits', mat2str(NL.NumberOfUnits,100), ...
            'Threshold',  mat2str(thresh,100)};
        par = rmfield(par,'RegressorMinMax');
        f1 = fieldnames(par);
        f2 = fieldnames(par.Tree);
        for k = 1:length(f1)-1 %exclude Tree
            Pars = [Pars, f1{k}, mat2str(par.(f1{k}),100)]; %#ok<AGROW>
        end

        for k = 1:length(f2)
            Pars = [Pars, f2{k}, mat2str(par.Tree.(f2{k}),100)]; %#ok<AGROW>
        end

    case 'linear'
        par = NL.Parameters;
        Pars = {'OutputOffset', mat2str(par.OutputOffset,100),...
            'LinearCoef', mat2str(par.LinearCoef,100)};

    case {'wavenet','sigmoidnet'}
        par = NL.Parameters;
        Pars = {'NumUnits', mat2str(NL.NumberOfUnits,100)};
        f = fieldnames(par);
        for k = 1:length(f)
            Pars = [Pars, f{k}, mat2str(par.(f{k}),100)]; %#ok<AGROW>
        end

    case 'pwlinear'
        par = NL.internalParameter;
        Pars = {'NumUnits', mat2str(NL.NumberOfUnits,100)}; %'BreakPoints',mat2str(NL.BreakPoints,100)
        f = fieldnames(par);
        for k = 1:length(f)
            Pars = [Pars, f{k}, mat2str(par.(f{k}),100)]; %#ok<AGROW>
        end

    case {'neuralnet','customnet'}
        Pars = {'sys','sys','CInd',num2str(CInd)};

    otherwise
        ctrlMsgUtils.error('Ident:simulink:unknownNL',upper(class(NL)))
end

%--------------------------------------------------------------------------
function [X0,WarnMsg] = LocalComputeInitialStates(sys,IC,X0,U0,Y0,...
    AllMaxDelays,Nx,nu,ny)
% determine initial states for tapped delay line

WarnMsg = cell(0,2);

if IC==1
    % U0, Y0 level specification

    % validate input level specification
    U0 = LocalValidateIOLevelData(U0,nu,'input');

    % validate output level specification
    Y0 = LocalValidateIOLevelData(Y0,ny,'output');

    % map Y0 and U0 to X0 using AllMaxDelays
    X0 = constdata2states(sys,nu,ny,Nx,U0,Y0,AllMaxDelays);
    %X0 = LocalMapIOSamples2States(X0,AllMaxDelays,nu,ny,U0,Y0);
else
    % initial state specification
    msg = {'Ident:simulink:incorrectX0Len',...
        ctrlMsgUtils.message('Ident:simulink:incorrectX0Len',Nx)};

    if ~isrealvec(X0) || ~any(isfinite(X0))
        error(msg{:});
    end

    if ~isequal(numel(X0),Nx)
        msg{2} = sprintf('%s Using zero values instead.',msg{2});
        WarnMsg = msg;
        X0 = zeros(Nx,1);
    end
end

%--------------------------------------------------------------------------
function Z = LocalValidateIOLevelData(Z,n,Type)
% error-check past I/O data specification
% Type: 'input' or 'output'
% n: nu or ny (channel dim)

if n==1
    msg = {'Ident:simulink:incorrectPastSampLen',...
        ctrlMsgUtils.message('Ident:simulink:incorrectPastSampLen',Type)};
       
    if ~isscalar(Z) || ~isrealvec(Z) || ~isfinite(Z)
        error(msg{:});
    end

else
    msg = {'Ident:simulink:incorrectPastSampDim',...
        ctrlMsgUtils.message('Ident:simulink:incorrectPastSampDim',Type,n)};

    if ~isnumeric(Z) || ~isreal(Z) || ~any(isfinite(Z)) || ~isvector(Z)
        error(msg{:});
    end

    if isscalar(Z)
        Z = Z*ones(1,n);
    elseif ~isequal(numel(Z),n)
        error(msg{:});
    else
        Z = Z(:).';
    end
end
