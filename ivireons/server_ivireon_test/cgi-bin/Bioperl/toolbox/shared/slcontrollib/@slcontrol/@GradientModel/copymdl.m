function copymdl(this)
% COPYMDL Creates an augmented SL model, used in gradient finding.

% Author(s): Bora Eryilmaz, P. Gahinet
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/04/21 21:47:39 $

% Short names
origsys = this.OrigModel;
gradsys = this.GradModel;

% Copy configuration from original model
cs = copy( getActiveConfigSet(origsys) );
cs.Name = 'sro_grad_config';
attachConfigSet( gradsys, cs );
setActiveConfigSet( gradsys,'sro_grad_config' )

% Disable unconnected warnings
set_param(gradsys, ...
          'UnconnectedInputMsg',  'none', ...
          'UnconnectedOutputMsg', 'none', ...
          'UnconnectedLineMsg',   'none', ...
          'SignalLogging',        'on')

% Subsystem names
LeftSubSys  = [gradsys '/Left'];
RightSubSys = [gradsys '/Right'];

% Create Left subsystem (masked)
add_block( 'built-in/Subsystem', LeftSubSys, ...
           'Position', [150 50 200 100], 'NamePlacement', 'alternate' );
LocalMaskSubsystem( this, LeftSubSys, 'LValue' );

% Create Right subsystem (masked)
add_block( 'built-in/Subsystem', RightSubSys, ...
           'Position', [150 150 200 200] );
LocalMaskSubsystem( this, RightSubSys, 'RValue' );

% Original system blocks
blocks = find_system( origsys, 'SearchDepth', 1 );
blocks = blocks(2:end);  % 1st block is the system itself.

% RE: Do not duplicate floating scopes (corrupts Simulink)
% scopes = find_system( blocks, 'SearchDepth', 0, 'BlockType', 'Scope', ...
%                       'Floating', 'on' );
% blocks = setdiff(blocks, scopes);

%% Copy all original system blocks into the left subsystem
for ct = 1:length(blocks)
  bct = blocks{ct};
  pos = get_param( bct, 'Position' );
  ort = get_param( bct, 'Orientation' );
  add_block( bct, strrep(bct, origsys, LeftSubSys), ...
             'Position', pos, 'Orientation', ort );
end

% Update Log ID's in left subsystem (SRO)
SROBlocks = find_system( LeftSubSys, 'FollowLinks', 'on', ...
                         'LookUnderMasks','all', 'RegExp', 'on', ...
                         'BlockType', 'SubSystem', 'LogID', 'SRO_DataLog_\d');
for ct = 1:length(SROBlocks)
  LogID = sprintf('%s_L', get_param(SROBlocks{ct},'LogID'));
  set_param(SROBlocks{ct}, 'LogID', LogID)
end

%% Copy all original system blocks into the right subsystem
for ct = 1:length(blocks)
  bct = blocks{ct};
  pos = get_param( bct, 'Position' );
  ort = get_param( bct, 'Orientation' );
  add_block( bct, strrep(bct, origsys, RightSubSys), ...
             'Position', pos, 'Orientation', ort );
end

% Update Log ID's in right subsystem (SRO)
SROBlocks = find_system( RightSubSys, 'FollowLinks', 'on', ...
                         'LookUnderMasks', 'all', 'RegExp', 'on', ...
                         'BlockType', 'SubSystem', 'LogID', 'SRO_DataLog_\d');
for ct = 1:length(SROBlocks)
  LogID = sprintf('%s_R', get_param(SROBlocks{ct},'LogID'));
  set_param(SROBlocks{ct}, 'LogID', LogID)
end

%% Copy all lines between blocks
lines = get_param( origsys, 'Lines' );
for ct = 1:length(lines)
  lct = lines(ct);
  LocalCopyLine( lct, LeftSubSys );
  LocalCopyLine( lct, RightSubSys );
end

%% Replace all the Scope, ToFile, Display, and ToWorkspace blocks with
% terminators.
replace_block( gradsys, 'Scope',       'Terminator', 'noprompt' );
replace_block( gradsys, 'ToFile',      'Terminator', 'noprompt' );
replace_block( gradsys, 'Display',     'Terminator', 'noprompt' );
replace_block( gradsys, 'ToWorkspace', 'Terminator', 'noprompt' );
replace_block( gradsys, 'ReferenceBlock', 'simulink/Sinks/XY Graph', 'Terminator', 'noprompt' );

%% Process the input ports
numinports = length( find_system(blocks,'SearchDepth',0,'BlockType','Inport') );
marker = length(origsys)+1;
for i = 1:numinports
  ipn = int2str(i);
  blk = find_system( origsys, 'SearchDepth', 1, ...
                     'BlockType', 'Inport', 'Port', ipn );
  blk = blk{1};
  oblk = strrep( blk, origsys, LeftSubSys );
  pblk = strrep( blk, origsys, RightSubSys );

  set_param( oblk, 'ShowName', 'off', 'Port', ipn );
  set_param( pblk, 'ShowName', 'off', 'Port', ipn );

  pos = [15 45+30*(i-1) 35 65+30*(i-1)];
  add_block( blk, strrep(blk, origsys, gradsys), 'Position', pos, ...
             'ShowName', 'off', 'Orientation', 'right' );

  add_line( gradsys, [blk(marker+1:end) '/1'], ['Left/'  ipn] );
  add_line( gradsys, [blk(marker+1:end) '/1'], ['Right/' ipn] );
end

%% Loop from port number 1 to numoutports.
% This order is very important, since the port numbers need to match up
numoutports = length(find_system(blocks,'SearchDepth',0,'BlockType','Outport'));
for i = 1:numoutports
  opn = int2str(i);
  blk = find_system( origsys, 'SearchDepth', 1, ...
                     'BlockType', 'Outport', 'Port', opn );
  blk  = blk{1};
  oblk = strrep( blk, origsys, LeftSubSys );
  pblk = strrep( blk, origsys, RightSubSys );

  set_param(oblk, 'ShowName', 'off', 'Port', opn);
  set_param(pblk, 'ShowName', 'off', 'Port', opn);
end

% Change the tags on the Goto, From & GoToTagVisibility
% blocks in the perturbed subsystem
blks{1} = find_system( RightSubSys, 'LookUnderMasks','all', 'BlockType','Goto');
blks{2} = find_system( RightSubSys, 'LookUnderMasks','all', 'BlockType','From');
blks{3} = find_system( RightSubSys, 'LookUnderMasks','all', ...
                       'BlockType','GotoTagVisibility' );
blks = cat(1,blks{:});
nblks = length(blks);
for i = 1:nblks
  blk = blks{i};
  set_param( blk, 'GotoTag',['D' get_param(blk,'GotoTag')] );
end

% set the model parameters
LocalSetOdeParam(this,origsys,gradsys)

% --------------------------------------------------------------------------- %
function LocalMaskSubsystem(this, blockname, type)
Variables = this.Variables;

maskValues    = cell(0,1);
maskPrompts   = cell(0,1);
maskVariables = '';

for ct = 1:length(Variables)
  maskVariable = Variables(ct).Name;
  if ct == 1
    maskVariables = sprintf('%s=@%s', maskVariable, num2str(ct));
  else
    maskVariables = sprintf('%s;%s=@%s',maskVariables,maskVariable,num2str(ct));
  end

  maskValues{ct}  = sprintf('%s(%d).%s', this.WSVariable, ct, type);
  maskPrompts{ct} = maskVariable;
end

set_param(blockname, 'MaskPrompts',   maskPrompts, ...
                     'MaskVariables', maskVariables, ...
                     'MaskValues',    maskValues);

% --------------------------------------------------------------------------- %
function LocalCopyLine(ln, sys)
% Copy a single instance of a line and all its branches
% NOTE: Unconnected lines don't get copied over, which may or may not
% be desirable.
if isempty(ln.Branch)
  if isempty(ln.SrcBlock) || isempty(ln.DstBlock)
    % REM: Relevant to Physmod blocks. See G206444.
    % Also, update try/catch in initialize.m when the geck is fixed.
    ctrlMsgUtils.error( 'SLControllib:slcontrol:RefinedGradientNotAvailable' );
  elseif ishandle(ln.SrcBlock) && ishandle(ln.DstBlock)
    % Direct copy if SrcBlock and DstBlock are valid block handles
    pts = ln.Points;
    iport = [strrep(get_param(ln.SrcBlock, 'Name'),'/','//') '/' ln.SrcPort];
    oport = [strrep(get_param(ln.DstBlock, 'Name'),'/','//') '/' ln.DstPort];
    new_line = add_line(sys, iport, oport);
    set_param(new_line, 'Points', pts);
  end
else
  % For branches, get the SrcBlock and SrcPort from the trunk
  for lbct = ln.Branch'
    lbct.SrcBlock = ln.SrcBlock;
    lbct.SrcPort  = ln.SrcPort;
    LocalCopyLine(lbct, sys);
  end
end

% --------------------------------------------------------------------------- %
function LocalSetOdeParam(this, origsys, gradsys)
set_param(gradsys, 'SaveTime', 'off', 'SaveState', 'off', ...
                   'SaveOutput', 'off', 'Outputtimes', '[]',...
                   'LoadInitialState', 'off', 'InitialState', '[]');

% Initial states
if strcmp( get_param(origsys, 'LoadInitialState'), 'on'),
  % Creates a temporary variable with a unique name in the model workspace to
  % store configuration data.
  wksp = get_param(this.GradModel, 'ModelWorkspace');
  s = wksp.whos;
  name = genvarname('grad_x0', {s.name});

  % Store the initial state data in the model workspace.
  var = getInitialStates(origsys, gradsys); % Replicate initial state
  set_param(gradsys, 'LoadInitialState', 'on', 'InitialState', name);
  
  % Store the data structure in the model workspace.
  wksp.assignin(name, var)
end

% --------------------------------------------------------------------------- %
function x0grad = getInitialStates(origsys, gradsys)
% Constructs the initial state structure for the gradient model from the initial
% state structure of the original model by copying the state values.
x0orig = getModelStates(slcontrol.Utilities, origsys);
x0grad = getModelStates(slcontrol.Utilities, gradsys);

% Will replace string starting with original model name followed by separators
% '.' or '/' with model name followed by Left/Right using same separators.
expr = ['^' origsys '([./])'];
replL = [gradsys '$1Left$1'];
replR = [gradsys '$1Right$1'];

for ct = 1:length(x0orig.signals)
  % Left subsystem (match block and state name separators + Left)
  xct = x0orig.signals(ct);
  xct.blockName = regexprep(xct.blockName, expr, replL);
  xct.stateName = regexprep(xct.stateName, expr, replL);
  idx = LocalFindMatchingStateStruct(xct, x0grad);
  if ~isempty(idx)
    x0grad.signals(idx).values = xct.values;
  end
  % Right subsystem (match block and state name separators + Right)
  xct = x0orig.signals(ct);
  xct.blockName = regexprep(xct.blockName, expr, replR);
  xct.stateName = regexprep(xct.stateName, expr, replR);
  idx = LocalFindMatchingStateStruct(xct, x0grad);
  if ~isempty(idx)
    x0grad.signals(idx).values = xct.values;
  end
end

% ----------------------------------------------------------------------------
function idx = LocalFindMatchingStateStruct(state, x0)
% Extract state structure array from original state structure.
x0list = x0.signals;
idx = [];
for k = 1:length(x0list)
  if strcmp(state.blockName, x0list(k).blockName) && ...
        strcmp(state.stateName, x0list(k).stateName) && ...
        strcmp(state.label, x0list(k).label)
    idx = k;
    break;
  end
end
