function fhandle=getinternaldiscfunction(fname)
%GETINTERNALDISCFUNCTION returns the function handle with name 'fname'

% $Revision: 1.7.4.17.2.1 $ $Date: 2010/06/24 19:44:49 $
% Copyright 1990-2010 The MathWorks, Inc.

fhandle = str2func(fname);
myfield = getfield(functions(fhandle),'type');
% bridge from dispatcher R13      ->                   R14
if ~strcmp(myfield,'subfunction') && ~strcmp(myfield,'scopedfunction')
    fhandle = 0;
end
%end getInternalDiscFunction

%
%===============================================================================
% DiscretizeDerivative
% Replaces a continuous derivative block  with a faithful discrete version
% of the block.
% arguments: block --block
%            method --transform method (refer to c2d)
%            SampleTime --sample time
%            offset  -- offset
%            cf -- critical frequency (for tustin with prewarping only)
%            ReplaceMethod -- 0: replace with hard-coded discrete equivalents
%                             1: replace with continuous parametric masks
%===============================================================================
%
function newBlk = DiscretizeDerivative(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');

if ~strcmp(method,'tustin') && ~strcmp(method,'prewarp')
    warning(sprintf('Applying ''tustin'' to derivative instead of ''%s''\n',method));
    method = 'tustin';
end

if ReplaceMethod == 1    %Replace with continuous parametric mask
    % replace the continuous block with the masked discrete block
    libBlockName = sprintf('discretizing/Discretized\nDerivative');

    block2link(block, libBlockName);

    % set the parameters
    if strcmp(method,'prewarp')
        Wc = cf;
        set_param(block,'Wc',formatCf(Wc));
    end
    set_param(block, 'SampleTime', formatSampleTime(SampleTime, offset), 'method',method,...
        'Name',newBlk);

else %ReplaceMethod==0, Replace with hard-coded discrete equivalent
   
    Numerator = [1 0];
    Denominator = [1];
    [numd, dend] = sldiscutil('disctransferfcn', {SampleTime, method, cf, Numerator, Denominator});
    nl = sprintf('\n');
    ReplaceBlock(block,['simulink3/Discrete/Discrete',nl,'Transfer Fcn'],...
        'Numerator',        getString(numd),...
        'Denominator',      getString(dend),...
        'SampleTime',       formatSampleTime(SampleTime, offset),...
        'Name',             newBlk);
end
newBlk = block;

% end DiscretizeDerivative
%
%===============================================================================
% DiscretizeIntegrator
% Replaces a continuous integrator with a faithful discrete version
% of the block.
%===============================================================================
%
function newBlk=DiscretizeIntegrator(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
if strcmp(get_param(block,'BlockType'), 'DiscreteIntegrator')
  newBlk = block;
  fprintf('*** Block ''%s'' is already discrete - no changes made.\n', ...
          strrep(block, sprintf('\n'), ' '));
  return
end

ExternalReset = get_param(block,'ExternalReset');
InitialConditionSource = get_param(block,'InitialConditionSource');
InitialCondition = get_param(block,'InitialCondition');
LimitOutput = get_param(block,'LimitOutput');
UpperSaturationLimit = get_param(block,'UpperSaturationLimit');
LowerSaturationLimit = get_param(block,'LowerSaturationLimit');
ShowSaturationPort = get_param(block,'ShowSaturationPort');
ShowStatePort = get_param(block,'ShowStatePort');

nl = sprintf('\n');

switch(method)
 case 'zoh'
  Imethod = 'Forward Euler';
 case 'foh'
  Imethod = 'Trapezoidal';
 case 'tustin'
  Imethod = 'Trapezoidal';
 otherwise
  Imethod = 'Trapezoidal';
end

% cf: in rad/sec
if strcmp(method, 'prewarp')
    SampleTime = str2num(formatSampleTime(SampleTime, offset));
    gainVal = 2*tan(cf * SampleTime/2) /(cf *SampleTime);
    
    ReplaceBlock(block,['simulink3/Discrete/Discrete-Time',nl,'Integrator'],...
        'gainval',               formatCf(gainVal), ...
        'ExternalReset',          ExternalReset,...
        'InitialConditionSource', InitialConditionSource,...
        'InitialCondition',       InitialCondition,...
        'LimitOutput',            LimitOutput,...
        'UpperSaturationLimit',   UpperSaturationLimit,...
        'LowerSaturationLimit',   LowerSaturationLimit,...
        'ShowSaturationPort',     ShowSaturationPort,...
        'ShowStatePort',          ShowStatePort,...
        'IntegratorMethod',       Imethod,...
        'SampleTime',             formatSampleTime(SampleTime, offset),...
        'Name',             newBlk);
    
else
    % replace the continuous block with discrete block
    ReplaceBlock(block,['simulink3/Discrete/Discrete-Time',nl,'Integrator'],...
        'ExternalReset',          ExternalReset,...
        'InitialConditionSource', InitialConditionSource,...
        'InitialCondition',       InitialCondition,...
        'LimitOutput',            LimitOutput,...
        'UpperSaturationLimit',   UpperSaturationLimit,...
        'LowerSaturationLimit',   LowerSaturationLimit,...
        'ShowSaturationPort',     ShowSaturationPort,...
        'ShowStatePort',          ShowStatePort,...
        'IntegratorMethod',       Imethod,...
        'SampleTime',             formatSampleTime(SampleTime, offset),...
        'Name',             newBlk);
end

newBlk = block;
if strcmp(get_param(newBlk,'BlockType'), 'DiscreteIntegrator')
  set_param(newBlk,'MaskType','DiscretizedDiscreteIntegrator');
  set_param(newBlk,'MaskInitialization',['%' method]);
end
% end DiscretizeIntegrator


%===============================================================================
% DiscretizeSecondOrderIntegrator
% Replaces a Second-Order integrator with an discrete approximation  
% containing two discrete integrators and the logic to start/stop integration,
% handle saturations and reset, and internal reinitialization.
% Note that this may not be 
%===============================================================================
%
function discBlock = DiscretizeSecondOrderIntegrator(block,method,SampleTime,offset,...
                                                  cf,ReplaceMethod)

    discBlockName = get_param(block,'Name');

    if strcmp(get_param(block,'MaskType'), 'DiscretizedSecondOrderIntegrator')
       discBlock = discBlockName;
        return;
    end

    
    ExternalReset = get_param(block,'ExternalReset');
    ICSourceX = get_param(block,'ICSourceX');
    ICSourceDXDT = get_param(block,'ICSourceDXDT');
    ICX = get_param(block,'ICX');
    ICDXDT = get_param(block,'ICDXDT');

    LimitX = get_param(block,'LimitX');
    UpperLimitX = get_param(block,'UpperLimitX');
    LowerLimitX = get_param(block,'LowerLimitX');

    LimitDXDT = get_param(block,'LimitDXDT');
    UpperLimitDXDT = get_param(block,'UpperLimitDXDT');
    LowerLimitDXDT = get_param(block,'LowerLimitDXDT');

    ReinitDXDTwhenXreachesSaturation = get_param(block,...
                                                 'ReinitDXDTwhenXreachesSaturation');

    ShowOutput = get_param(block,'ShowOutput');

    % Second-order integrator discretized library
    sIntDiscLib = 'discretizedSecondOrderIntegrator';

    % Assumption that we do not have to deal with complications
    sIntVariant = 'xFree'; 

    % If there is a reset, switch to the version having a reset
    if ~strcmp(ExternalReset, 'none')
        sIntVariant = 'xFreeWithReset';
    end

    % if x has saturation limits, we need different variants
    if strcmp(LimitX, 'on')
        if strcmp(ExternalReset, 'none')
                sIntVariant = 'xLimited';
        else
                sIntVariant = 'xLimitedWithReset';
        end
    end

    sIntDiscBlock = [sIntDiscLib '/' sIntVariant];

    % Choose integrator method
    % Assuming same logic as Integrator. 
    switch(method)
      case 'zoh'
        % Forward Euler needs a different configuration
        IntegratorMethod = 'Integration: Forward Euler';
      case 'foh'
        IntegratorMethod = 'Integration: Trapezoidal';
      case 'tustin'
        IntegratorMethod = 'Integration: Trapezoidal';
      otherwise
        IntegratorMethod = 'Integration: Trapezoidal';
    end
    

    blockParams = {'ExternalReset',  ExternalReset,...
                   'ICSourceX', ICSourceX,...
                   'ICX',   ICX,...
                   'ICSourceDXDT', ICSourceDXDT,...
                   'ICDXDT',   ICDXDT,...
                   'LimitX',       LimitX,...
                   'UpperLimitX',  UpperLimitX,...
                   'LowerLimitX',  LowerLimitX,...
                   'LimitDXDT',       LimitDXDT,...
                   'UpperLimitDXDT',  UpperLimitDXDT,...
                   'LowerLimitDXDT',  LowerLimitDXDT,...
                   'ReinitDXDTwhenXreachesSaturation',...
                   ReinitDXDTwhenXreachesSaturation,...
                   'IntegratorMethod',IntegratorMethod,... 
                   'ShowOutput',  ShowOutput,...
                   'Name',            discBlockName};
    
    % Assuming same as integrator
    % critical frequency cf (?): in rad/sec

    if strcmp(method, 'prewarp')
        SampleTime = str2num(formatSampleTime(SampleTime, offset));
        gainVal = 2*tan(cf * SampleTime/2) /(cf *SampleTime);
        
        maskParams = { 'GainValue', formatCf(gainVal), ...
                       'SampleTime',...
                       formatSampleTime(SampleTime, offset),...
                       blockParams{:} };
        
    else
        maskParams = {'SampleTime',...
                      formatSampleTime(SampleTime, offset),...
                      blockParams{:} };
        
    end
    

% Preserve the decoration and callbacks
decorations = GetDecorationParams(block);

callbackfcns = GetCallbackParams(block);

% Get the name/parent 
name   = strrep(get_param(block,'Name'),'/','//');
parent = get_param(block,'Parent');

% Open the library if it is not open
slashes = find( sIntDiscBlock == '/' );
discLibrary = sIntDiscBlock( 1:slashes(1) - 1 );
if isempty(find_system('type','block_diagram','name',discLibrary)),
   feval(discLibrary,[],[],[],'load');
end
    
blockHandle = get_param(block,'handle');
set_param(block,'Name',[name '_backup_discretizer']);

insertedBlock = -1.0;

try
   insertedBlock = add_block(sIntDiscBlock, [parent '/' name],maskParams{:});
   delete_block(blockHandle);
   set_param(insertedBlock,decorations{:}, callbackfcns{:});
catch e
   if insertedBlock == -1.0
      set_param(blockHandle, 'Name', name); 
   end
   fprintf('Cannot generate discrete block for ''%s'' because of the following error: %s \n',strrep(block,sprintf('\n'),' '), e.message);
end
    
% Replacement done.
discBlock = block;
set_param(discBlock, 'MaskType','DiscretizedSecondOrderIntegrator');
    
% end DiscretizeSecondOrderIntegrator

%
%===============================================================================
% DiscretizePID1dof
% Replaces a continuous PID Controller with a faithful discrete version
% of the block by switching the block's time-domain
%===============================================================================
%
function newBlk=DiscretizePID1dof(block,method,SampleTime,offset,cf,ReplaceMethod)
Handle = get_param(block,'Handle');
h = handle(Handle);
if strcmp(h.MaskType,'PID 1dof')
    TimeDomainEntries = h.getPropAllowedValues('TimeDomain');
    if strcmp(get_param(block,'TimeDomain'),TimeDomainEntries{2})
        newBlk = block;
        fprintf('*** Block ''%s'' is already discrete - no changes made.\n', ...
            strrep(block, sprintf('\n'), ' '));
        return
    end
end

% Error if the selected method is 'matched'
if strcmpi(method,'matched')
    newBlk = block;
    fprintf('The PID Controller block cannot be discretized using the ''matched'' method.\n');
    return;
end

IntegratorMethodEntries = h.getPropAllowedValues('IntegratorMethod');
FilterMethodEntries = h.getPropAllowedValues('IntegratorMethod');

% Evaluate the Mask parameters
Pc = get_param(block,'P'); Ic = get_param(block,'I');
Dc = get_param(block,'D'); Nc = get_param(block,'N');
% REVESIT: P,I,D, and N may need to be resolved differently using SLRESOLVE
Pc = evalin('base',Pc); Ic = evalin('base',Ic);
Dc = evalin('base',Dc); Nc = evalin('base',Nc);

if ~isnumeric(SampleTime)
    SampleTime = str2double(SampleTime);
end

switch(method)
    case 'zoh'
        IntegratorMethod = IntegratorMethodEntries{1}; % 'Forward Euler'
        FilterMethod = FilterMethodEntries{1};         % 'Forward Euler'
        % Replace with hard-coded discrete equivalent
        Nd = (1-exp(-Nc*SampleTime))/SampleTime;
        Dd = Dc*Nc/Nd;
        Id = Ic;
        Pd = Pc;
        
    case 'foh'
        IntegratorMethod = IntegratorMethodEntries{3}; % 'Trapezoidal'
        FilterMethod = FilterMethodEntries{1};         % 'Forward Euler'
        % Replace with hard-coded discrete equivalent
        Nd = (1-exp(-Nc*SampleTime))/SampleTime;
        Dd = Dc;
        Id = Ic;
        Pd = Pc;
        
    case {'tustin'}
        IntegratorMethod = IntegratorMethodEntries{3}; % 'Trapezoidal'
        FilterMethod = FilterMethodEntries{1};         % 'Forward Euler'
        % Replace with hard-coded discrete equivalent
        Nd = Nc/(1+Nc*SampleTime/2);
        Dd = Dc;
        Id = Ic;
        Pd = Pc;
        
    case {'prewarp'}
        IntegratorMethod = IntegratorMethodEntries{3}; % 'Trapezoidal'
        FilterMethod = FilterMethodEntries{1};         % 'Forward Euler'
        % Replace with hard-coded discrete equivalent
        Tprime = tan(SampleTime*cf/2)/(cf/2);
        Nd = Nc/(1+Nc*Tprime/2)*Tprime/SampleTime;
        Dd = Dc*SampleTime/Tprime;
        Id = Ic*Tprime/SampleTime;
        Pd = Pc;
end

% Switch PID Controller to its Discrete-time mode
set_param(Handle,'TimeDomain',TimeDomainEntries{2},'IntegratorMethod',IntegratorMethod,...
    'FilterMethod',FilterMethod,'SampleTime',formatSampleTime(SampleTime, offset),...
    'P',num2str(Pd,'%.15f'),'I',num2str(Id,'%.15f'),'D',num2str(Dd,'%.15f'),...
    'N',num2str(Nd,'%.15f'));

newBlk = block;

% end DiscretizePID1dof

%===============================================================================
% DiscretizePID2dof
% Replaces a continuous PID Controller (2DOF) with a faithful discrete version
% of the block by switching the block's time-domain
%===============================================================================
%
function newBlk=DiscretizePID2dof(block,method,SampleTime,offset,cf,ReplaceMethod)
Handle = get_param(block,'Handle');
h = handle(Handle);
if strcmp(h.MaskType,'PID 2dof')
    TimeDomainEntries = h.getPropAllowedValues('TimeDomain');
    if strcmp(get_param(block,'TimeDomain'),TimeDomainEntries{2})
        newBlk = block;
        fprintf('*** Block ''%s'' is already discrete - no changes made.\n', ...
            strrep(block, sprintf('\n'), ' '));
        return
    end
end

% Error if the selected method is 'matched'
if strcmpi(method,'matched')
    newBlk = block;
    fprintf('The PID Controller block cannot be discretized using the ''matched'' method.\n');
    return;
end

IntegratorMethodEntries = h.getPropAllowedValues('IntegratorMethod');
FilterMethodEntries = h.getPropAllowedValues('IntegratorMethod');

% Evaluate the MAsk parameters
Pc = get_param(block,'P'); Ic = get_param(block,'I');
Dc = get_param(block,'D'); Nc = get_param(block,'N');
% REVESIT: P,I,D, and N may need to be resolved differently using SLRESOLVE
Pc = evalin('base',Pc); Ic = evalin('base',Ic);
Dc = evalin('base',Dc); Nc = evalin('base',Nc);

if ~isnumeric(SampleTime)
    SampleTime = str2double(SampleTime);
end

switch(method)
    case 'zoh'
        IntegratorMethod = IntegratorMethodEntries{1}; % 'Forward Euler'
        FilterMethod = FilterMethodEntries{1};         % 'Forward Euler'
        % Replace with hard-coded discrete equivalent
        Nd = (1-exp(-Nc*SampleTime))/SampleTime;
        Dd = Dc*Nc/Nd;
        Id = Ic;
        Pd = Pc;
        
    case 'foh'
        IntegratorMethod = IntegratorMethodEntries{3}; % 'Trapezoidal'
        FilterMethod = FilterMethodEntries{1};         % 'Forward Euler'
        % Replace with hard-coded discrete equivalent
        Nd = (1-exp(-Nc*SampleTime))/SampleTime;
        Dd = Dc;
        Id = Ic;
        Pd = Pc;
        
    case {'tustin'}
        IntegratorMethod = IntegratorMethodEntries{3}; % 'Trapezoidal'
        FilterMethod = FilterMethodEntries{1};         % 'Forward Euler'
        % Replace with hard-coded discrete equivalent
        Nd = Nc/(1+Nc*SampleTime/2);
        Dd = Dc;
        Id = Ic;
        Pd = Pc;
        
    case {'prewarp'}
        IntegratorMethod = IntegratorMethodEntries{3}; % 'Trapezoidal'
        FilterMethod = FilterMethodEntries{1};         % 'Forward Euler'
        % Replace with hard-coded discrete equivalent
        Tprime = tan(SampleTime*cf/2)/(cf/2);
        Nd = Nc/(1+Nc*Tprime/2)*Tprime/SampleTime;
        Dd = Dc*SampleTime/Tprime;
        Id = Ic*Tprime/SampleTime;
        Pd = Pc;
end

% Switch PID Controller to its Discrete-time mode
set_param(Handle,'TimeDomain',TimeDomainEntries{2},'IntegratorMethod',IntegratorMethod,...
    'FilterMethod',FilterMethod,'SampleTime',formatSampleTime(SampleTime, offset),...
    'P',num2str(Pd,'%.15f'),'I',num2str(Id,'%.15f'),'D',num2str(Dd,'%.15f'),...
    'N',num2str(Nd,'%.15f'));

newBlk = block;

% end DiscretizePID2dof
%
%===============================================================================
% DiscretizeMemory
% Replaces a continuous memory with a unit delay.
% 
%===============================================================================
%
function newBlk=DiscretizeMemory(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
%if ReplaceMethod==1    %Replace with continuous parametric mask
X0 = get_param(block,'X0');

% replace the continuous block with discrete block 
libBlockName = sprintf('discretizing/Discretized\nMemory');

block2link(block, libBlockName);

set_param(block,'X0',X0,'SampleTime',formatSampleTime(SampleTime, offset),...
            'Name',newBlk);
newBlk = block;
% end DiscretizeMemory


%
%===============================================================================
% DiscretizeStateSpace
% Replaces a continuous state space system with a faithful discrete version
% of the block.
%===============================================================================
%
function newBlk=DiscretizeStateSpace(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');

if strcmp(get_param(block,'BlockType'), 'DiscreteStateSpace')
  newBlk = block;
  fprintf('*** Block ''%s'' is already discrete - no changes made.\n', ...
          strrep(block, sprintf('\n'), ' '));
  return
end

if ReplaceMethod==1    %Replace with continuous parametric mask
% replace the continuous block with discrete block 
    A = get_param(block,'A');
    B = get_param(block,'B');
    C = get_param(block,'C');
    D = get_param(block,'D');
    ic = get_param(block,'X0');
    AbsTol = get_param(block, 'AbsoluteTolerance');
libBlockName = sprintf('discretizing/Discretized\nState-Space');

block2link(block, libBlockName);

% set the parameters
if strcmp(method,'prewarp')
  Wc = cf;
  set_param(block,'Wc',formatCf(Wc));
end
set_param(block,'SampleTime',formatSampleTime(SampleTime, offset),'method',method,...
            'ic',ic,...
            'A',A,...
            'B',B,...
            'C',C,...
            'D',D,...
            'AbsTol',AbsTol,...
            'Name',newBlk);

else %ReplaceMethod==0,  Replace with hard-coded discrete equivalent
    A = get_param(block,'A');
    B = get_param(block,'B');
    C = get_param(block,'C');
    D = get_param(block,'D');
    ic = get_param(block,'X0');
    A = evalin('base',A);
    B = evalin('base',B);
    C = evalin('base',C);
    D = evalin('base',D);
    ic = evalin('base',ic);
    [Ad, Bd, Cd, Dd, icd] = sldiscutil('discstatespace', {SampleTime, method, cf, A, B, C, D, ic});
    ReplaceBlock(block,['simulink3/Discrete/Discrete State-Space'],...
                'A',getString(Ad),...
                'B',getString(Bd),...
                'C',getString(Cd),...
                'D',getString(Dd),...
                'X0',getString(icd),...
                'SampleTime',formatSampleTime(SampleTime, offset),...
                'Name',newBlk);    
    
end

newBlk = block;
if strcmp(get_param(newBlk,'BlockType'), 'DiscreteStateSpace')
  set_param(newBlk,'MaskType','DiscretizedDiscreteStateSpace');
  set_param(newBlk,'MaskInitialization',['%' method]);
end
% end DiscretizeStateSpace


%
%===============================================================================
% DiscretizeTransferFcn
% Replaces a continuous transfer function with a faithful discrete version
% of the block.
%===============================================================================
%
function newBlk=DiscretizeTransferFcn(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');

if strcmp(get_param(block,'BlockType'), 'DiscreteTransferFcn')
  newBlk = block;
  fprintf('*** Block ''%s'' is already discrete - no changes made.\n', ...
          strrep(block, sprintf('\n'), ' '));
  return
end

if ReplaceMethod == 1    %Replace with continuous parametric mask
Numerator = get_param(block,'Numerator');
Denominator = get_param(block,'Denominator');
AbsTol = get_param(block, 'AbsoluteTolerance');

% replace the continuous block with the masked discrete block
libBlockName = sprintf('discretizing/Discretized\nTransfer Fcn');

block2link(block, libBlockName);

% set the parameters
if strcmp(method,'prewarp')
  Wc = cf;
  set_param(block,'Wc',formatCf(Wc));
end
set_param(block,'Numerator',Numerator,'Denominator',Denominator,...
		'SampleTime',formatSampleTime(SampleTime, offset),'method',method,...
        'AbsTol',AbsTol,...
        'Name',newBlk);

else %ReplaceMethod==0,  Replace with hard-coded discrete equivalent
    Numerator = get_param(block,'Numerator');
    Denominator = get_param(block,'Denominator');    
    Numerator = evalin('base',Numerator);
    Denominator = evalin('base',Denominator);
    [numd, dend] = sldiscutil('disctransferfcn', {SampleTime, method, cf, Numerator, Denominator});
    nl = sprintf('\n');
    ReplaceBlock(block,['simulink3/Discrete/Discrete',nl,'Transfer Fcn'],...
                'Numerator',        getString(numd),...
                'Denominator',      getString(dend),...
                'SampleTime',       formatSampleTime(SampleTime, offset),...
                'Name',             newBlk);

end

newBlk = block;
if strcmp(get_param(newBlk,'BlockType'), 'DiscreteTransferFcn')
  set_param(newBlk,'MaskType','DiscretizedDiscreteTransferFcn');
  set_param(newBlk,'MaskInitialization',['%' method]);
end
% end DiscretizeTransferFcn


%
%===============================================================================
% DiscretizeTransferFcnWithIC
% Replaces a continuous transfer function that has initial condition 
% with a faithful discrete version of the block.
%===============================================================================
%
function newBlk=DiscretizedTransferFcnWithIC(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
Numerator = get_param(block,'N');
Denominator = get_param(block,'D');
X0 = get_param(block,'X0');

Wc = 1;
% set the parameters
if strcmp(method,'prewarp')
  Wc = cf;
end

% This doesn't work, since the underline block is discrete transfer fcn
nl = sprintf('\n');

if strcmp(method,'prewarp')
    ReplaceBlock(block,['discretizing/Discretized' nl 'Transfer Fcn' nl '(with initial states)'],...
        'Numerator',        Numerator,...
        'Denominator',      Denominator,...
        'X0',               X0,...
        'SampleTime',       formatSampleTime(SampleTime, offset),...
        'method',           method, ...
        'Wc',              Wc, ...
        'Name',             newBlk);
else
    ReplaceBlock(block,['discretizing/Discretized' nl 'Transfer Fcn' nl '(with initial states)'],...
        'Numerator',        Numerator,...
        'Denominator',      Denominator,...
        'X0',               X0,...
        'SampleTime',       formatSampleTime(SampleTime, offset),...
        'method',           method, ...
        'Name',             newBlk);
end

newBlk = block;

% end DiscretizeTransferFcnWithIC


%
%===============================================================================
% DiscretizeLTISystem
% Replaces a continuous LTI system with a discrete version
%===============================================================================
%
function newBlk=DiscretizeLTISystem(block,method,SampleTime,offset,cf,ReplaceMethod)

newBlk = get_param(block,'Name');
sysc = get_param(block, 'sys');
cic = get_param(block, 'IC');

% replace the continuous block with the masked discrete block
libBlockName = sprintf('discretizing/Discretized\nLTI System');
ReplaceBlock(block,libBlockName,...
             'sysc', sysc,...
             'cic', cic,...
             'SampleTime', formatSampleTime(SampleTime, offset),...
             'method', method,...
             'Name',  newBlk);

if strcmp(method,'prewarp')
  Wc = cf;
  set_param(block,'Wc',formatCf(Wc));
end

newBlk = block;
% end DiscretizeLTISystem


%
%===============================================================================
% DiscretizeTransportDelay
% Replaces a continuous transport with either the z^-n DSP block if licensed
% or a discrete z^-n transfer function (inefficient!).
%===============================================================================
%
function newBlk=DiscretizeTransportDelay(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
delay = get_param(block,'DelayTime');
ic    = get_param(block,'InitialInput');

% replace the continuous block with the masked discrete block
% libBlockName = sprintf('discretizing/Discretized\nTransport Delay');
libBlockName = sprintf('discretizing/Discretized\nTransport Delay 2');

block2link(block, libBlockName);

set_param(block,'delay',delay,'ic',ic,'SampleTime',formatSampleTime(SampleTime, offset),...
            'Name',newBlk);
newBlk = block;
% end DiscretizeTransportDelay


%
%===============================================================================
% DiscretizeVariableTransportDelay
% Replaces a continuous variable transport delay with TBD.
% 
%===============================================================================
%
function newBlk=DiscretizeVarTransportDelay(block,method,SampleTime,offset,cf,ReplaceMethod)

 if strcmp(get_param(block, 'VariableDelayType'), 'Variable transport delay')
    % DAStudio.warning('Simulink:components:VariableTransportDelayNotSupported');
     newBlk = block;
 else
    newBlk = get_param(block,'Name');
    % include maxPoints to support un-discretizing
    
    MaximumDelay  = get_param(block,'MaximumDelay');
    InitialInput  = get_param(block,'InitialInput');
    MaximumPoints = get_param(block,'MaximumPoints');
    
    % replace the continuous block with the masked discrete block
    libBlockName = sprintf('discretizing/Discretized\nVariable\nTime Delay');
    
    block2link(block, libBlockName);
    
    set_param(block,'MaximumDelay',MaximumDelay, 'InitialInput',InitialInput, ...
        'MaximumPoints',MaximumPoints,'SampleTime',formatSampleTime(SampleTime, offset),...
        'Name',newBlk);
    newBlk = block;
 end
 %end DiscretizeVarTransportDelay


%
%===============================================================================
% DiscretizeZeroPole
% Replaces a continuous memory with a unit delay.
% 
%===============================================================================
%
function newBlk=DiscretizeZeroPole(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
if strcmp(get_param(block,'BlockType'), 'DiscreteZeroPole')
  newBlk = block;
  fprintf('*** Block ''%s'' is already discrete - no changes made.\n', ...
          strrep(block, sprintf('\n'), ' '));
  return
end
if ReplaceMethod == 1    %Replace with continuous parametric mask
  Zeros = get_param(block,'Zeros');
  Poles = get_param(block,'Poles');
  Gain  = get_param(block,'Gain');
  AbsTol = get_param(block, 'AbsoluteTolerance');
% replace the continuous block with discrete block 
libBlockName = sprintf('discretizing/Discretized\nZero-Pole');

block2link(block, libBlockName);

% set the parameter values on the mask
if strcmp(method,'prewarp')
  Wc = cf;
  set_param(block,'Wc',formatCf(Wc));
end
set_param(block,'Zeros',Zeros,'Poles',Poles,'Gain',Gain,...
		'SampleTime',formatSampleTime(SampleTime, offset),'method',method,...
        'AbsTol',AbsTol,...
        'Name',newBlk);

else %ReplaceMethod==0,  Replace with hard-coded discrete equivalent
    Zeros = get_param(block,'Zeros');
    Poles = get_param(block,'Poles');
    Gain  = get_param(block,'Gain');
    Zeros = evalin('base',Zeros);
    Poles = evalin('base',Poles);
    Gain = evalin('base',Gain);
    [zerosd, polesd, gaind] = sldiscutil('disczpk', {SampleTime, method, cf, Zeros, Poles, Gain});
    nl = sprintf('\n');
    ReplaceBlock(block,['simulink3/Discrete/Discrete',nl,'Zero-Pole'],...
                'Zeros',getString(zerosd),...
                'Poles',getString(polesd),...
                'Gain',getString(gaind),...
                'SampleTime',formatSampleTime(SampleTime, offset),...
                'Name',newBlk);
    
end
newBlk = block;
if strcmp(get_param(newBlk,'BlockType'), 'DiscreteZeroPole')
  set_param(newBlk,'MaskType','DiscretizedDiscreteZeroPole');
  set_param(newBlk,'MaskInitialization',['%' method]);
end
% end DiscretizeZeroPole


%
%===============================================================================
% DiscretizeSource
% Converts a continuous source into a discrete
% source with an explicit sample time.
%===============================================================================
%
function newBlk=DiscretizeSource(block,method,SampleTime,offset,cf,ReplaceMethod)

blockSampleTime = get_param(block,'SampleTime');

% only change the block if it is continuous

Tsblk = eval(blockSampleTime);

if Tsblk == 0.0 | Tsblk == (-1.0)
    newBlk = get_param(block,'Name');
  set_param(block,'SampleTime',formatSampleTime(SampleTime, offset),...
            'Name',newBlk);
else
  fprintf('   *** Source block ''%s'' is already discrete - no changes made.\n', ...
  strrep(block, sprintf('\n'), ' '));
  newBlk = get_param(block,'Name');
end
newBlk = block;

blockTypes = {'Sin','Step','RandomNumber', ...
             'UniformRandomNumber','FromWorkspace','FromFile'};
if(any(strcmp(blockTypes, get_param(newBlk,'BlockType'))))
  set_param(newBlk,'MaskType','DiscretizedSource');
  set_param(newBlk,'MaskInitialization',['%' method]);
end

% end DiscretizeSource


%
%===============================================================================
% DiscretizePulseGenerator
% Replaces a continuous pulse generator with a discrete one.
%===============================================================================
%
function newBlk=DiscretizePulseGenerator(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');

Period       = str2num(get_param(block,'Period'));
PulseWidth   = str2num(get_param(block,'PulseWidth'));
Amplitude    = str2num(get_param(block,'Amplitude'));
PhaseDelay   = str2num(get_param(block,'PhaseDelay'));
PulseType    = get_param(block,'PulseType');

if(ischar(SampleTime))
    SampleTime = str2num(SampleTime);
end
if strcmp(PulseType,'Time based')  %continuous
    PulseWidth    = round(Period*PulseWidth/100.0/SampleTime);
    Period        = round(Period/SampleTime);
    PhaseDelay    = round(PhaseDelay/SampleTime);
    PulseType     = 'Sample based';
end
Period = num2str(Period);
PulseWidth = num2str(PulseWidth);
PhaseDelay = num2str(PhaseDelay);
Amplitude = num2str(Amplitude);

%Pulse Generator doesn't accept '[sampletime offset]' format
set_param(block,'Period',Period,'PulseWidth',PulseWidth,'Amplitude',Amplitude,...
             'PhaseDelay',PhaseDelay,'PulseType',PulseType,...
             'SampleTime',formatSampleTime(SampleTime, offset),...
             'Name', newBlk);
newBlk = block;  
% end DiscretizePulseGenerator


%
%===============================================================================
% DiscretizeRepeatingSequence
% Replaces a continuous repeating table with a discrete version.
%===============================================================================
%
function newBlk=DiscretizeRepeatingSequence(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
rep_seq_t = get_param(block,'rep_seq_t');
rep_seq_y = get_param(block,'rep_seq_y');
  
% replace the continuous block with discretized block 
libBlockName = sprintf('discretizing/Discretized\nRepeating Sequence');
ReplaceBlock(block, libBlockName);
% block2link(block,libBlockName);

% set the parameter values on the mask
nl=sprintf('\n');
set_param(block,'rep_seq_t',rep_seq_t, 'rep_seq_y', rep_seq_y, ...
                'Name',newBlk,...    
                'SampleTime',formatSampleTime(SampleTime, offset));
newBlk = block;
% end DiscretizeRepeatingSequence


%
%===============================================================================
% DiscretizeChirp
% Replaces a continuous chirp source with a discrete version.
%===============================================================================
%
function newBlk=DiscretizeChirp(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
f1 = get_param(block,'f1');
T = get_param(block,'T');
f2 = get_param(block,'f2');
  
% replace the continuous block with discretized block 
libBlockName = sprintf('discretizing/Discretized\nChirp Signal');
ReplaceBlock(block, libBlockName);
% block2link(block,libBlockName);

% set the parameter values on the mask
nl = sprintf('\n');
set_param(block,'f1',f1, 'T',T, 'f2',f2, ...
                'Name',newBlk,...
                'SampleTime',formatSampleTime(SampleTime, offset));
newBlk = block;
% end DiscretizeChirp


%
%===============================================================================
% DiscretizeRamp
% Replaces a continuous ramp source with a discrete version.
%===============================================================================
%
function newBlk=DiscretizeRamp(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
slope = get_param(block,'slope');
start = get_param(block,'start');
X0    = get_param(block,'X0');
  
% replace the continuous block with discretized block 
libBlockName = sprintf('discretizing/Discretized\nRamp');
ReplaceBlock(block, libBlockName);
%block2link(block,libBlockName);

% set the parameter values on the mask
nl=sprintf('\n');
set_param(block,'slope',slope, 'start',start, 'X0',X0, ...
                'Name',newBlk,...
                'SampleTime',formatSampleTime(SampleTime, offset));
newBlk = block;
% end DiscretizeRamp


%
%===============================================================================
% DiscretizeClock
% Replaces a continuous clock with a digital (discrete) one.
%===============================================================================
%
function newBlk=DiscretizeClock(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
% replace the continuous block with the discrete version
nl = sprintf('\n');
ReplaceBlock(block,'simulink3/Sources/Digital Clock',...
                   'SampleTime', formatSampleTime(SampleTime, offset),...
                   'Name',newBlk);
newBlk = block;
% end DiscretizeClock


%
%===============================================================================
% DiscretizeSignalGenerator
% Replaces a continuous signal generator with a digital (discrete) one.
%===============================================================================
%
function newBlk=DiscretizeSignalGenerator(block,method,SampleTime,offset,cf,ReplaceMethod)
newBlk = get_param(block,'Name');
% replace the continuous block with the discrete version

WaveForm  = get_param(block,'WaveForm');
Amplitude = get_param(block,'Amplitude');
Frequency = get_param(block,'Frequency');
Units     = get_param(block,'Units');

libBlockName = sprintf('discretizing/Discretized\nSignal Generator');

block2link(block, libBlockName);

nl=sprintf('\n');
set_param(block,'WaveForm',WaveForm,'Amplitude',Amplitude, ...
                'Frequency',Frequency,'Units',Units, ...
                'Name',newBlk,...
                'SampleTime', formatSampleTime(SampleTime, offset));
newBlk = block;
% end DiscretizeSignalGenerator


function newBlk = DiscretizeParamMask(block,method,SampleTime,offset,cf,ReplaceMethod)
%Discretize the continuous parametric mask

newBlk = get_param(block,'Name');
if ReplaceMethod==1    %Replace with continuous parametric mask
    set_param(block,'SampleTime', formatSampleTime(SampleTime, offset));
    set_param(block,'method',method);
    set_param(block,'Wc',sprintf('%g',cf));
else  %ReplaceMethod==0,  Replace with hard-coded discrete equivalent
    mtype = get_param(block,'MaskType');
    nl=sprintf('\n');
    switch lower(mtype)
    case 'discretizedderivative'
        if ~strcmp(method,'tustin') & ~strcmp(method,'prewarp')
            warning(sprintf('Applying ''tustin'' to derivative instead of ''%s''\n',method));
            method = 'tustin';
        end        
        Numerator = [1 0];
        Denominator = [1];
        [numd, dend] = sldiscutil('disctransferfcn', {SampleTime, method, cf, Numerator, Denominator});        
        ReplaceParamMaskBlock(block,['simulink3/Discrete/Discrete',nl,'Transfer Fcn'],...
                'Numerator',        getString(numd),...
                'Denominator',      getString(dend),...
                'SampleTime',       formatSampleTime(SampleTime, offset),...
                'Name',             newBlk);
    case 'discretizedstatespace'
        A = get_param(block,'A');
        B = get_param(block,'B');
        C = get_param(block,'C');
        D = get_param(block,'D');
        ic = get_param(block,'ic');
        A = evalin('base',A);
        B = evalin('base',B);
        C = evalin('base',C);
        D = evalin('base',D);
        ic = evalin('base',ic);      
        [ad,bd,cd,dd,x0] = sldiscutil('discstatespace', {SampleTime, method, cf, A, B, C, D, ic});        
        ReplaceParamMaskBlock(block,['simulink3/Discrete/Discrete State-Space'],...
                'A',getString(ad),...
                'B',getString(bd),...
                'C',getString(cd),...
                'D',getString(dd),...
                'X0',getString(x0),...
                'SampleTime',formatSampleTime(SampleTime, offset),...
                'Name',newBlk);    
    case 'discretizedtransferfcn'
        Numerator = get_param(block,'Numerator');
        Denominator = get_param(block,'Denominator');    
        Numerator = evalin('base',Numerator);
        Denominator = evalin('base',Denominator);
        [numd, dend] = sldiscutil('disctransferfcn', {SampleTime, method, cf, Numerator, Denominator});
        ReplaceParamMaskBlock(block,['simulink3/Discrete/Discrete',nl,'Transfer Fcn'],...
                'Numerator',        getString(numd),...
                'Denominator',      getString(dend),...
                'SampleTime',       formatSampleTime(SampleTime, offset),...
                'Name',             newBlk);
    case 'discretizedzeropole'
        Zeros = get_param(block,'Zeros');
        Poles = get_param(block,'Poles');
        Gain  = get_param(block,'Gain');
        Zeros = evalin('base',Zeros);
        Poles = evalin('base',Poles);
        Gain = evalin('base',Gain);
        [zerosd, polesd, gaind] = sldiscutil('disczpk', {SampleTime, method, cf, Zeros, Poles, Gain});
        ReplaceParamMaskBlock(block,['simulink3/Discrete/Discrete',nl,'Zero-Pole'],...
                'Zeros',getString(zerosd),...
                'Poles',getString(polesd),...
                'Gain',getString(gaind),...
                'SampleTime',formatSampleTime(SampleTime, offset),...
                'Name',newBlk);
    case 'discretizedltisystem'
        set_param(block,'SampleTime', formatSampleTime(SampleTime, offset));
        set_param(block,'method',method);
        set_param(block,'Wc',sprintf('%g',cf));
        
%  To Do:        How to get the string expression for discsys?
%         sysc = get_param(block, 'sysc');
%         cic = get_param(block, 'cic');
%         [discsys, discic] = sldiscutil('disclti', {SampleTime, method, cf, sysc, cic});
%         if(isempty(find_system('cstblocks')))
%             load_system('cstblocks');
%         end
%         ReplaceParamMaskBlock(block,'cstblocks/LTI System',...
%                 'sys',discsys,...
%                 'IC',discic,...
%                 'Name',newBlk); 
    end
end
newBlk = block;

%
%===============================================================================
%  Replaces a single block with a new block with specified parameters
%===============================================================================
%
function ReplaceBlock(oldBlock,newBlock,varargin)
% REPLACEBLOCK replaces a single block with a new block with specified parameters.

% the decorations must be preserved
decorations = GetDecorationParams(oldBlock);

% The callback functions should be preserved
callbackfcns = GetCallbackParams(oldBlock);

%
% the mask must be preserved, if the old block is not a SubSystem
% or an S-function.  The reasoning here is that SubSystem and S-function
% blocks (masked or otherwise) will be replaced with either a built-in
% or another SubSystem or S-function (possibly masked) and that the old
% mask is not important.  However, if the block is not one of the above,
% and it does have a mask then the mask may offer an alternative
% interface to the block that should be preserved.
%

switch get_param(oldBlock,'BlockType')
case {'SubSystem','S-Function'}
    mask = {};
otherwise
    mask = GetMaskParams(oldBlock);
end

% the old block's name and parent are needed for the new block

name   = strrep(get_param(oldBlock,'Name'),'/','//');
parent = get_param(oldBlock,'Parent');


slashes = find( newBlock == '/' );
library = newBlock( 1:slashes(1) - 1 );
if isempty(find_system('type','block_diagram','name',library)),
   feval(library,[],[],[],'load');
end
    
% rename the old block, add the new block with the appropriate 
% parameters (as passed in as a varargs) and with the old 
% decorations, delete the old block
%
% To Do: get a unique block name
oldh = get_param(oldBlock,'handle');
set_param(oldBlock,'Name',[name '_backup_discretizer']);

%delete_block(oldBlock);

changedBlk = -1.0;
try
   changedBlk = add_block(newBlock, [parent '/' name],varargin{:});
   delete_block(oldh);
   set_param(changedBlk,decorations{:}, callbackfcns{:});
   set_all_param(changedBlk,mask);
catch
   if changedBlk == -1.0
      set_param(oldh, 'Name', name); 
      fprintf('Cannot generate discrete block for ''%s''\n',strrep(oldBlock,sprintf('\n'),' '));
   end
end

% end ReplaceBlock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Replace a continuous parametric mask with the underneath discrete block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ReplaceParamMaskBlock(oldBlock,newBlock,varargin)
% REPLACEPARAMMASKBLOCK replaces a single block with a new block with specified parameters.

% the decorations must be preserved
decorations = GetDecorationParams(oldBlock);

% The callback functions should be preserved
callbackfcns = GetCallbackParams(oldBlock);

% the old block's name and parent are needed for the new block
name   = strrep(get_param(oldBlock,'Name'),'/','//');
parent = get_param(oldBlock,'Parent');


slashes = find( newBlock == '/' );
library = newBlock( 1:slashes(1) - 1 );
if isempty(find_system('type','block_diagram','name',library)),
   feval(library,[],[],[],'load');
end
    
% rename the old block, add the new block with the appropriate 
% parameters (as passed in as a varargs) and with the old 
% decorations, delete the old block
%
% To Do: get a unique block name
oldh = get_param(oldBlock,'handle');
set_param(oldBlock,'Name',[name '_backup_discretizer']);

changedBlk = -1.0;
try
   assignin('base', 'newblock',newBlock);
   assignin('base', 'curblock', [parent '/' name]);
   assignin('base', 'varin', varargin);
   changedBlk = add_block(newBlock, [parent '/' name],varargin{:});
   delete_block(oldh);
   set_param(changedBlk,'LinkStatus','none');
   set_param(changedBlk,decorations{:}, callbackfcns{:});
catch
   if changedBlk == -1.0
      set_param(oldh, 'Name', name); 
      fprintf('Cannot generate discrete block for ''%s''\n',strrep(oldBlock,sprintf('\n'),' '));
   end
end

% end ReplaceParamMaskBlock

%
%=============================================================================
% GetDecorationParams
% Return a cell array containing the parameter/value pairs for a block's
% decorations (i.e. FontSize, FontWeight, Orientation, etc.)
%=============================================================================
%
function decorations = GetDecorationParams(block)

decorations = {
  'Position',        [];
  'Orientation',     [];
  'ForegroundColor', [];
  'BackgroundColor', [];
  'DropShadow',      [];
  'NamePlacement',   [];
  'ShowName',        [];
  'Priority',        [];
  'RTWData',         [];
  'UserData',        [];
  'UserDataPersistent',[];  
  'FontName',        [];
  'FontSize',        [];
  'FontWeight',      [];
  'FontAngle',       [];
  'ShowName',        [];
  'Selected',        [];
  'Tag',             [];
  'HiliteAncestors', [];
};

for i = 1:size(decorations,1),
  decorations{i,2} = get_param(block,decorations{i,1});
end

decorations = reshape(decorations',1,length(decorations(:)));

% end GetDecorationParams

%
%=============================================================================
% GetCallbackParams
% Return a cell array containing the parameter/value pairs for a block's
% callback functions 
%=============================================================================
%
function callbackfcns = GetCallbackParams(block)

callbackfcns = {
  'CopyFcn',        [];
  'DeleteFcn',      [];
  'UndoDeleteFcn',    [];
  'LoadFcn',        [];
  'ModelCloseFcn',  [];
  'PreSaveFcn',     [];
  'PostSaveFcn',    [];
  'InitFcn',        [];
  'StartFcn',       [];
  'StopFcn',        [];
  'NameChangeFcn',  [];  
  'ClipboardFcn',   [];
  'DestroyFcn',     [];
  'OpenFcn',        [];
  'CloseFcn',       [];
  'ParentCloseFcn', [];
  'EvalFcn',        [];
  'MoveFcn',        [];
};

for i = 1:size(callbackfcns,1),
  callbackfcns{i,2} = get_param(block,callbackfcns{i,1});
end

callbackfcns = reshape(callbackfcns',1,length(callbackfcns(:)));

% end GetDecorationParams


%
%=============================================================================
% GetMaskParams
% Return a cell array containing the parameter/value pairs for a block's
% Mask.
%=============================================================================
%
function maskParams = GetMaskParams(block)

skipParams = {
    'MaskEnableString';...
    'MaskVisibilityString';...
    'MaskToolTipString';...
    'MaskVariableAliases';...
    'MaskCallbackString';...
};
noChangeParams = {
    'MaskEditorHandle';...
    'MaskCallbackString';...
};

obparams = get_param(block,'objectparameters');
paramnames = fieldnames(obparams);
masknames = paramnames(strmatch('Mask',paramnames));
k = 0;
if strcmp(get_param(block,'Mask'),'off')
    maskParams{1} = 'Mask';
    maskParams{2} = 'off';
else
    maskParams{1} = 'Mask';
    maskParams{2} = 'on';
    k = 1;
  for i = 1:length(masknames),
    thisparam = getfield(obparams,masknames{i});
    if isempty(strmatch('read-only',thisparam.Attributes)) & ...
          isempty(strmatch(masknames{i},noChangeParams,'exact'))
        k = k + 1;
        maskParams{2*k-1} = masknames{i};
        paramvalue = get_param(block,masknames{i});
        % deal with parameters which are string type but do not accept empty string
        if ~isempty(strmatch(masknames{i},skipParams,'exact')) & ischar(paramvalue) & ...
            strcmp(paramvalue,'')
            paramvalue = [];
        end
        maskParams{2*k} = paramvalue;
    end
  end
end

% end GetMaskParams

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set_all_param is protected by try/catch
%
% set_all_param
% Same as set_param, however, the call to set_param is protected by try/catch.
% Try to set all params again and again.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_all_param(block, paramcell)

% n must be an even number
n = length(paramcell);
n1 = n / 2;
n2 = 0;
for i = 1:n1,
    remainedParams{i,1} = paramcell{2*i-1};
    remainedParams{i,2} = paramcell{2*i};
end
while n1 ~= n2
    n2 = n1;
    toSetParams = remainedParams;
    remainedParams = {};
    k = 0;
    for i = 1:n1,
       try
          set_param(block, toSetParams{i,1},toSetParams{i,2});
       catch myException
           warning(myException.identifier, '%s', myException.getReport('basic'));
           k = k + 1;
           remainedParams{k} = toSetParams{i};
       end
    end
    n1 = k;   
end
                                                                 
%end set_all_param

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% get the string expression of a matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5555555
function result = getString(inputmtx)
%get the string expression of a matrix

   if ~isnumeric(inputmtx)
       result = '';
       return;
   end
   result = '[';
   [m,n] = size(inputmtx);
   for k = 1:m,
       for kk = 1:n,
           result = sprintf('%s%.15f ',result, inputmtx(k,kk));
       end
       if k < m
          result = sprintf('%s;',result);
      end
  end
  result = sprintf('%s]',result);
%end getString

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% formatSampleTime - Format sample time + offset
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function st = formatSampleTime(sampleTime, offset)

if(ischar(sampleTime))
    st = sampleTime;
else
    st = sprintf('%0.18g',sampleTime);
end
if(ischar(offset))
    if(isempty(str2double(offset)) || str2double(offset) ~= 0 )
        st = sprintf('[%s %s]', st, offset);
    end
else
    if(offset ~= 0)
        st = sprintf('[%s %g]', st, offset);
    end
end

%end formatSampleTime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% formatCf - Format critical frequency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ncf = formatCf(cf)

    if(ischar(cf))
        ncf = cf;
    else
        ncf = sprintf('%0.16g', cf);
    end
%end formatCf



%[EOF] getInternalDiscFunction.m



