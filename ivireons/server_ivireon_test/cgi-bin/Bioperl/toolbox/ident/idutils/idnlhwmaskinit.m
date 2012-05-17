function varargout = idnlhwmaskinit(Action, varargin)
%Mask initialization function for Hammerstein-Wiener model block.

%[A,B,C,D,X0,Ts,WarnMsg] = idnlhwmaskinit('initialization', CB,sys,Y0);
%idnlhwmaskinit('maskparamcallback',gcb);

% Written by: Rajiv Singh
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:51:35 $

switch Action
    case 'maskparamcallback'
        LocalMaskParam1Callback(varargin{:});
    case 'initialization'        
        [varargout{1:7}] = LocalUpdateDiagram(varargin{:}); %inputs: CB,sys,IC,Y0
end

%--------------------------------------------------------------------------
function LocalMaskParam1Callback(CB)

%y0len = 0;
MaskVal = get_param(CB,'MaskValues');
MaskPrompts = get_param(gcb,'MaskPrompts');

try
    sys = slResolve(MaskVal{1},CB); %LocalEvaluate(MaskVal{1},bdroot(CB));
catch %#ok<CTCH>
    sys = [];
end

if ~isempty(sys) && isa(sys,'idnlhw')
    A = ssdata(sys.LinearModel);
    MaskPrompts{3} = sprintf('Specify initial states as a vector of %d elements:',...
        size(A,1));
else
    MaskPrompts{3} = 'Specify a vector of state values';
end

set_param(gcb,'MaskPrompts',MaskPrompts);

%--------------------------------------------------------------------------
function [A, B, C, D, X0, Ts, WarnMsg] = LocalUpdateDiagram(CB,sys,IC,X0)

WarnMsg = '';

if ~isa(sys,'idnlhw')
    ctrlMsgUtils.error('Ident:simulink:invalidNLModel','Hammerstein-Wiener','IDNLHW');
elseif isestimated(sys)==0 %could be 0, +/-1
    ctrlMsgUtils.error('Ident:idnlmodel:unestimatedModel')
end

% load identextras to copy blocks
load_system('identextras')

[ny,nu] = size(sys);
[A, B, C, D, K, X0i] = ssdata(sys.LinearModel);
Ts = sys.Ts;

if IC==2
    X0 = X0(:);
    if ~isequal(length(X0),length(X0i))
        ctrlMsgUtils.error('Ident:simulink:idnlhwInvalidX0Length',length(X0i))
    elseif ~isrealmat(X0) || any(~isfinite(X0))
        ctrlMsgUtils.error('Ident:simulink:idnlhwInvalidX0Value')
    end
else
    X0 = zeros(size(A,1),1);
end

% clear out all contents of subsystem representing idnlhw model (CB)
h = LocalGetDeletableItems(CB);

if ~isempty(h) %&& all(ishandle(h))
    delete_block(h);
end
% also delete all connecting lines
delete(find_system(CB,'FollowLinks','on','LookUnderMasks','all',...
        'SearchDepth',1,'FindAll','on','type','line'))

vt = 56.5; % height of mux block = vt*n, where n is nu or ny
vm = 26;   % minimum vertical margin
Pos = get_param([CB,'/LinearModel'],'Position');
ht = Pos(4)-Pos(2);
y1loc = vm+vt*nu/2-ht/2+5;
Pos = [Pos(1),y1loc,Pos(3),y1loc+ht];
set_param([CB,'/LinearModel'],'Position',Pos);

% make basic connections
unl = sys.InputNonlinearity;
ynl = sys.OutputNonlinearity;

LocalProcessNonlinearities(CB,'Input',nu,unl,Ts,Pos,vm,vt);
LocalProcessNonlinearities(CB,'Output',ny,ynl,Ts,Pos,vm,vt);

%--------------------------------------------------------------------------
function LocalProcessNonlinearities(CB,Type,n,nl,Ts,refpos,vm,vt)

isInput = strcmp(Type,'Input');
if isInput
    PosDemux = [refpos(1)-190,vm,refpos(1)-185,vt*n+vm];
    DemuxName = 'InputDemux';
    PosBus = [refpos(1)-20,vm,refpos(1)-15,vt*n+vm];
    BusName = 'InputBus';
else
    PosDemux = [refpos(3)+30,vm,refpos(3)+35,vt*n+vm];
    DemuxName = 'OutputDemux';
    PosBus = [refpos(3)+200,vm,refpos(3)+205,vt*n+vm];
    BusName = 'OutputBus';
end

if n>1
    Bus = add_block('built-in/BusCreator',[CB,'/',BusName],...
        'Inputs',num2str(n),'DisplayOption','bar','Position', PosBus);
    BusName = get(Bus,'Name');

    Demux = add_block('built-in/Demux',[CB,'/',DemuxName],...
        'Outputs',num2str(n),'DisplayOption','bar','Position', PosDemux);
    DemuxName = get(Demux,'Name');
    if isInput
        add_line(CB,[BusName,'/1'],'LinearModel/1','autorouting','on');
        add_line(CB,'In1/1',[DemuxName,'/1'],'autorouting','on');
    else
        add_line(CB,'LinearModel/1',[DemuxName,'/1'],'autorouting','on');
        add_line(CB,[BusName,'/1'],'Out1/1','autorouting','on');
    end
end

for k = 1:n
    if ~isa(nl(k),'unitgain')
        nlblk = LocalAddNLBlock(CB,nl(k),k,refpos,Ts,isInput);
        nlblkName = get(nlblk,'Name');

        if n>1
            add_line(CB,[DemuxName,'/',num2str(k)],[nlblkName,'/1'],...
                'autorouting','on');
            add_line(CB,[nlblkName,'/1'],[BusName,'/',num2str(k)],...
                'autorouting','on');
        else
            if isInput
                add_line(CB,'In1/1',[nlblkName,'/1'],'autorouting','on');
                add_line(CB,[nlblkName,'/1'],'LinearModel/1','autorouting','on');
            else
                add_line(CB,'LinearModel/1',[nlblkName,'/1'],'autorouting','on');
                add_line(CB,[nlblkName,'/1'],'Out1/1','autorouting','on');
            end
        end
    else
        if n>1
            add_line(CB,[DemuxName,'/',num2str(k)],...
                [BusName,'/',num2str(k)],'autorouting','on');
        else
            if isInput
                add_line(CB,'In1/1','LinearModel/1','autorouting','on');
            else
                add_line(CB,'LinearModel/1','Out1/1','autorouting','on');
            end
        end
    end

end

%--------------------------------------------------------------------------
function blk = LocalAddNLBlock(CB,NL,Ind,refpos,Ts,isInput)
% Types of nonlinearities are:
%    pwlinear, deadzone, saturation, sigmoidnet, poly1d, wavenet, customnet
%    unitgain is represented by absence of NL block

vm = 38+(Ind-1)*60;
%ht = 34; wd = 115;
if isInput
    pos = [refpos(1)-160,vm,refpos(1)-45,vm+38];
else
    pos = [refpos(3)+60,vm,refpos(3)+175,vm+38];
end

CommonPV = {'MakeNameUnique','on','Position',pos,'Ts',mat2str(Ts,16)};

if any(strcmp(class(NL),{'wavenet','sigmodnet','pwlinear','customnet'}))
    % add some more PV pairs
    CommonPV = [CommonPV,{'NumReg',num2str(1)}];
end
 
Pars = LocalGetParList(NL,Ind,isInput);

switch class(NL)
    case 'wavenet'
        Block_Source = 'Wavenet Estimator';
        Block_Name   = 'Wavenet';

    case 'sigmoidnet'
        Block_Source = 'Sigmoidnet Estimator';
        Block_Name   = 'Sigmoidnet';

    case 'pwlinear'
        Block_Source = 'Pwlinear Estimator';
        Block_Name   = 'Pwlinear';
    
     case 'customnet'
        Block_Source = 'Nonlinearity Estimator';
        Block_Name   = 'Customnet';
        
    case 'saturation'
        Block_Source = 'Saturation DeadZone Estimator';
        Block_Name   = 'Saturation';
        
    case 'deadzone'
        Block_Source = 'Saturation DeadZone Estimator';
        Block_Name   = 'Deadzone';
        
    case 'poly1d'
        Block_Source = 'Poly1d Estimator';
        Block_Name   = 'Poly1d';
        
    otherwise
        ctrlMsgUtils.error('Ident:simulink:UnknownNL',class(NL))
end

blk = add_block(['identextras/',Block_Source], [CB,'/',Block_Name],...
    CommonPV{:},Pars{:}); 

%--------------------------------------------------------------------------
function deletableItems = LocalGetDeletableItems(CB)

allItems = find_system(CB,'FollowLinks','on','LookUnderMasks','all',...
    'SearchDepth',1);
lvl0Items = find_system(CB,'FollowLinks','on','LookUnderMasks','all',...
    'SearchDepth',0); 
lvl1Items = setdiff(allItems,lvl0Items);
doNotDeleteItems(1) = find_system(lvl1Items,'Name','In1');
doNotDeleteItems(2) = find_system(lvl1Items,'Name','Out1');
doNotDeleteItems(3) = find_system(lvl1Items,'Name','LinearModel');

deletableItems = setdiff(lvl1Items,doNotDeleteItems);

%--------------------------------------------------------------------------
function Pars = LocalGetParList(NL, CInd, isInput)
% return PV pairs for NL's parameters required for simulation; not called
% for NL = unit gain

switch class(NL)        
    case {'wavenet','sigmoidnet'}
        par = NL.Parameters;
        Pars = {'NumUnits', mat2str(NL.NumberOfUnits,100)};
        f = fieldnames(par);
        for k = 1:length(f)
            Pars = [Pars, f{k}, mat2str(par.(f{k}),100)]; %#ok<AGROW>
        end
        
    case 'pwlinear'
        par = NL.internalParameter;
        Pars = {'NumUnits', mat2str(NL.NumberOfUnits,100)};
        f = fieldnames(par);
        for k = 1:length(f)
            Pars = [Pars, f{k}, mat2str(par.(f{k}),100)]; %#ok<AGROW>
        end

    case 'customnet'
        Pars = {'sys','sys','CInd',num2str(CInd)};
        if isInput
            Pars = [Pars,{'NLType','Input'}];
        else
            Pars = [Pars,{'NLType','Output'}];
        end
        
    case {'saturation','deadzone'}
        par = NL.prvParameters;
        f = fieldnames(par);
        Pars = {};
        for k = 1:length(f)
            Pars = [Pars, f{k}, mat2str(par.(f{k}),100)]; %#ok<AGROW>
        end
        Pars = [Pars, {'IsSaturation',num2str(isa(NL,'saturation'))}];
        
    case 'poly1d'
        Pars = {'Degree',num2str(NL.Degree),'Coefficients',mat2str(NL.Coefficients,100)};
        
    otherwise
        ctrlMsgUtils.error('Ident:simulink:unknownNL',upper(class(NL)))
end
