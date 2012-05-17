function varargout = block(Hd, varargin)
%BLOCK Generate a Signal Processing Blockset block equivalent to the filter object.
%   BLOCK(Hd) generates a Signal Processing Blockset block equivalent to Hd.
%
%   BLOCK(Hd, PARAMETER1, VALUE1, PARAMETER2, VALUE2, ...) generates a
%   Signal Processing Blockset block using the options specified in the
%   parameter/value pairs. The available parameters are:
%
%     -------------       ---------------      ----------------------------
%     Property Name       Property Values      Description
%     -------------       ---------------      ----------------------------
%     Destination         [{'current'}         Specify whether to add the block
%                          'new'               to your current Simulink model,
%                          <user defined>]     create a new model to contain the
%                                              block, or specify the name of the
%                                              target subsystem. 
%
%     Blockname           {'filter'}           Provides the name for the new 
%                                              subsystem block. By default the 
%                                              block is named 'filter'.
%
%     OverwriteBlock      ['on' {'off'}]       Specify whether to overwrite an
%                                              existing block with the same name
%                                              as specified by the Blockname 
%                                              property or create a new block.
%
%     MapStates           ['on' {'off'}]       Specify whether to map the States
%                                              of the filter as initial conditions
%                                              of the block.
%
%     Link2Obj            ['on' {'off'}]       Specify whether to set the
%                                              filter variable in the block
%                                              mask rather than setting the
%                                              coefficient values.
%
%     MapCoeffsToPorts    ['on' {'off'}]       Specify whether to map the 
%                                              coefficients of the filter 
%                                              to the ports of the block.
%
%     CoeffNames          {'Num'}              Specify the coefficients
%                                              variables names. By default 
%                                              the coefficient variables take
%                                              the names of the ports.
%                                              MapCoeffsToPorts must be 'on' 
%                                              for this property to apply.
%
%
%    EXAMPLES:
%    [b,a] = butter(5,.5);
%    Hd = dfilt.df1(b,a);
% 
%    %#1 Default syntax:
%    block(Hd);
% 
%    %#2 Using parameter/value pairs:
%    block(Hd, 'Blockname', 'DF1');

%   Author(s): V. Pellissier
%   Copyright 1988-2010 The MathWorks, Inc.
%   $Revision: 1.2.4.21 $  $Date: 2010/05/20 03:10:04 $

% Check if Signal Processing Blockset is installed
[b, errstr, errid] = isspblksinstalled;
if ~b
    error(generatemsgid(errid), errstr);
end

mapstates = 'off';
idx = find(strcmpi(varargin,'MapStates'));
if ~isempty(idx), mapstates = varargin{idx+1}; end

link2obj = 'off';
idx = find(strcmpi(varargin,'Link2Obj'));
if ~isempty(idx), link2obj = varargin{idx+1}; end

isfixpt = isfield(get(Hd),'Arithmetic') && strcmpi(get_arith(Hd),'fixed');
if (isfixpt && strcmpi(link2obj,'on'))
    msgid = generatemsgid('fixedpointLink2obj');    
    warning(msgid,'Changes in InputWordlength and InputFracLength will be ignored by the block.');
end
    
try
     [lib srcblk s] = superblockparams(Hd, mapstates, link2obj, inputname(1));
catch ME
     throw(ME);
end

% Parse inputs
[hTar, errid, errmsg]= uddpvparse('dspfwiztargets.blocktarget', varargin{:});
if ~isempty(errmsg), error(generatemsgid(errid),errmsg); end

% Map Coefficients to Ports 
[mapcoeffs2ports coeffnames variables] = mapcoeffstoports(Hd,varargin{:});
doMapCoeffs2Ports = strcmpi(mapcoeffs2ports,'on');
if doMapCoeffs2Ports 
    variables = checkoptimizescalevalues(Hd,variables);
end

% Check if mapcoeffstoports supported for block method
if ~isblockmapcoeffstoports(Hd) && doMapCoeffs2Ports
    error(generatemsgid('InvalidParameter'), ...
        'Block method does not support MapCoeffsToPorts parameter for %s filters.',class(Hd));
end

% If a block handle was passed in, use it, else add it from the Simulink
% system from [lib '/' srcblk]
doReuseModel = ~isempty(hTar.BlockHandle) && ishandle(hTar.BlockHandle);
if doReuseModel,
    pos = [];
    isloaded = false;
    h = hTar.blockHandle;
    set_param(h,'Tag','BlockMethodSubSystem');
else
    % Create model
    pos = createmodel(hTar);

    isloaded = lclload_system(lib);
    sys = hTar.system;
    sysname = hTar.blockname;

    % Find the sys path
    slindex = findstr(sys,'/');
    syspath = sys(1:slindex(end)-1);

    if strcmpi(hTar.OverwriteBlock, 'on') %
        currentblk = find_system(syspath, 'SearchDepth', 1,'LookUnderMasks', 'all', 'Name', sysname);
        if ~isempty(currentblk)
            delete_block(currentblk{1});% Delete Filter block if present in the Destination
        end
    end
    
    % Check whether the filter arithmetic is fixed point.
    if(isfixpt)
        load_system('simulink');
        
        h = add_block('built-in/subsystem',hTar.system,'Tag','BlockMethodSubSystem');        
        h1 = add_block('built-in/Inport',[hTar.System '/In']);
        h2 = add_block('simulink/Signal Attributes/Data Type Conversion',[hTar.System '/Input Quantizer']);
        h3 = add_block([lib '/' srcblk], [hTar.system '/filter']);
        h4 = add_block('built-in/Outport',[hTar.System '/Out']);
        
        set_param(h1,'Position',[20 45 60 65]);
        set_param(h2,'Position',[110 40 150 70]);
        set_param(h3,'Position',[200 35 270 75]);
        set_param(h4,'Position',[320 45 360 65]);

        add_line(hTar.system,'In/1','Input Quantizer/1')
        add_line(hTar.system,'Input Quantizer/1','filter/1')
        add_line(hTar.system,'filter/1','Out/1')
        
        close_system('simulink');

    elseif doMapCoeffs2Ports,
        load_system('simulink');
        
        h = add_block('built-in/subsystem',hTar.system,'Tag','BlockMethodSubSystem');
        h1 = add_block('built-in/Inport',[hTar.System '/In']);
        h3 = add_block([lib '/' srcblk], [hTar.system '/filter']);
        h4 = add_block('built-in/Outport',[hTar.System '/Out']);
        
        set_param(h1,'Position',[20 45 60 65]);
        
        add_line(hTar.system,'In/1','filter/1')
        add_line(hTar.system,'filter/1','Out/1')
        
        close_system('simulink');
        
    else
        h = add_block([lib '/' srcblk], hTar.system, 'Tag', 'BlockMethodSubSystem');
    end
    
    % Refresh connections
    oldpos = get_param(sys, 'Position');
    set_param(sys, 'Position', oldpos + [0 -5 0 -5]);
    set_param(sys, 'Position', oldpos);
 
end

% Set Filter parameters
if(isfixpt)
    iwl = Hd.inputWordLength;
    ifl = Hd.InputFracLength;
    outdatatype = strcat('sfix(',num2str(iwl),')');
    outscaling = strcat('2^',num2str(-ifl));
    rndmeth = 'Round';
    set_param(h2, ...
        'OutDataTypeMode','Specify via Dialog', ...
        'OutDataType',outdatatype, ...
        'OutScaling',outscaling, ...
        'LockScale','off', ...
        'RndMeth', rndmeth, ...
        'DoSatur','on');
    fldnames = fieldnames(s);
    for i=1:length(fldnames),
        set_param(h3, fldnames{i}, s.(fldnames{i}));
    end    
elseif doMapCoeffs2Ports,
    fldnames = fieldnames(s);
    for i=1:length(fldnames),
        set_param(h3, fldnames{i}, s.(fldnames{i}));
    end
else
    fldnames = fieldnames(s);
    for i=1:length(fldnames),
        set_param(h, fldnames{i}, s.(fldnames{i}));
    end
end      

if ~isempty(pos), set_param(h, 'Position', pos); end

if isloaded,
    close_system(lib);
end

% Map Coefficients to Ports 
if strcmpi(mapcoeffs2ports,'on'),
    N = length(coeffnames);
    if N==1,
        posf =   [200    30   275   125];
        posout = [320    70   360    90];
    elseif N==2,
        posf =   [200    30   275   170];
        posout = [320    90   360   110];
    else
        posf =   [200    27   275   218];
        posout = [320   115   360   135];
    end
    set_param(h3,'FilterSource','Input port(s)');
    set_param(h3,'position', posf);
    set_param(h4,'position', posout);
    
    % Check if the variables exist in the workspace.
    pos = [20    87    75   113];
    step = [0 45 0 45];
    for i = 1:N,
        [varsExist, existMsg] = chkIfVarExistInWksp(coeffnames{i});
        if varsExist,  warning(generatemsgid('VariableExist'), ...
                existMsg); end
        try
            assignin('base',coeffnames{i},variables{i});
            hCoeff = add_block('built-in/Constant',[hTar.System '/' coeffnames{i}]);
            set_param(hCoeff,'Value',coeffnames{i},'position', pos+(i-1)*step);
            add_line(hTar.system,[coeffnames{i} '/1'],['filter/' sprintf('%d',i+1)]);
        catch ME
            rethrow(ME)
        end
    end
end

% When the model is not reused and when the path points to a system or a
% non-mask block, open the system
if ~doReuseModel && (isempty(strfind(syspath,'/')) || ~strncmpi(get_param(syspath,'mask'),'on',2)),
    % Open system
    open_system(syspath);
end

if nargout,
    varargout = {h};
end

%-----------------------------------------------------------
function isloaded = lclload_system(name)

isloaded = false;

% We don't need to load the built-in library blocks.
if strcmpi(name, 'built-in')
    return;
end

if isempty(find_system(0,'flat','Name', name)),
    isloaded = true;
    w=warning;
    warning('off');
    load_system(name);
    warning(w);
end

%-------------------------------------------------------------------
function [varsExist, existMsg] = chkIfVarExistInWksp(vname)
% CHKIFVAREXISTINWKSP Check if the variable exist in the workspace.

varsExist = 0;
existMsg = '';
[vals, errStr] = evaluatevars(vname); %#ok<NASGU>
if ~isempty(vals),
    varsExist = 1;
    existMsg = sprintf('Overwriting variable %s in the MATLAB workspace.',vname);
end

% [EOF]
