function varargout = editedlinkstool(varargin)

%   Copyright 2009-2010 The MathWorks, Inc.

persistent DIALOG_USERDATA

persistent HILITE_DATA

% Lock this file now to prevent user tampering
mlock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error(nargchk(1, Inf, nargin));

% Determine what the action is
Action = varargin{1};
args   = varargin(2:end);

% Arg1 -> model
% Arg2 -> empty or subsystem path to start from

switch (Action)
  case 'Create'
    % Test for existence of java
    if ~usejava('swing')
      error(DAStudio.message('Simulink:dialog:LinksToolNeedsJava'));
    end

    % Input arguments are model and the subsystem to start with
    model  = args{1};
    subsys = args{2};
    
    ModelHandle   = get_param(model, 'Handle');
    dialog_exists = 0;
  
    % Check if dialog already created
    if ~isempty(DIALOG_USERDATA)
      idx = find([DIALOG_USERDATA.ModelHandle] == ModelHandle);
      if ~isempty(idx)
        FrameHandle = DIALOG_USERDATA(idx).FrameHandle;
        awtinvoke(FrameHandle,'show()');
        dialog_exists = 1;
      end
    end

    % Create tool and store it
    if (dialog_exists == 0)
      FrameHandle = CreateEditedLinksTool(model, subsys);
      DIALOG_USERDATA(end+1).ModelHandle = ModelHandle;
      DIALOG_USERDATA(end).FrameHandle   = FrameHandle;
    end
    
    % Update link tool
    [data, selected] = PopulateLinkTool(model, subsys);
    javaMethodEDT('UpdateTable', FrameHandle, data, selected);
    
    % Make it visible only after all settings have been done
    awtinvoke(FrameHandle,'setVisible(Z)',true);
    drawnow

  case {'Delete', 'Close', 'Cancel'}
    ModelHandle = get_param(args{1}, 'Handle');

    % Check if dialog exists
    if ~isempty(DIALOG_USERDATA)
      idx = find([DIALOG_USERDATA.ModelHandle] == ModelHandle);
      if ~isempty(idx)
        FrameHandle = DIALOG_USERDATA(idx).FrameHandle;
        awtinvoke(FrameHandle,'dispose()');
        DIALOG_USERDATA(idx) = [];
      end
    end
  
    % Unhilite last selection
    HILITE_DATA = i_Unhilite(HILITE_DATA);
  
  case 'DeleteAll'
    % Delete all existing dialogs
    if ~isempty(DIALOG_USERDATA)
      for i = 1:length(DIALOG_USERDATA)
        FrameHandle = DIALOG_USERDATA(i).FrameHandle;
        awtinvoke(FrameHandle,'dispose()');
      end
      DIALOG_USERDATA = [];
    end
    
  case 'GetPopulationData'
    % Return data to Populate Link Tool
    [varargout{1} varargout{2}] = PopulateLinkTool(args{:});
 
  case 'Highlight'
    % Unhilite last selection
    HILITE_DATA = i_Unhilite(HILITE_DATA);
 
    % Highlight object
    objPath = args{1};
    model = strtok(objPath, '/');
    load_system(model);
    if strcmp(model, objPath)
      open_system(model);
    else
      HILITE_DATA.Block = objPath;
      hilite_system(objPath, 'find');
    end
      
  case {'Apply', 'OK'}
    blocks  = args{1};
    actions = args{2};
    
    try
      success = i_doApply(blocks, actions); 
    catch errmsg
      success = false;
      errordlg(errmsg.message, errmsg.identifier);
    end
    
    if strcmp(Action, 'OK')
      if success
        editedlinkstool('Cancel', args{3});
      end
    else
      % Return data to Populate Link Tool
      [varargout{1} varargout{2}] = PopulateLinkTool(args{3:end});
    end
     
  case 'Help'
    slprophelp('editedlinkstool')
   
  case 'GetEditedLinksTool'
    ModelHandle = get_param(args{1}, 'Handle');
    idx = find([DIALOG_USERDATA.ModelHandle] == ModelHandle);
    if ~isempty(idx)
        FrameHandle = DIALOG_USERDATA(idx).FrameHandle;
    else
        FrameHandle = [];
    end
    varargout{1} = FrameHandle;
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = i_Unhilite(data)

if ~isempty(data)
  try
    hilite_system(data.Block, 'none');
  catch %#ok
  end 
  data = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function frame = CreateEditedLinksTool(model, subsys)

% Call constructor
frame = javaMethodEDT('CreateEditedLinksTool','com.mathworks.toolbox.simulink.linkstool.EditedLinksTool', ...
                  model, subsys);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [objects, selected] = PopulateLinkTool(varargin)

import com.mathworks.toolbox.simulink.linkstool.LinkObject;

model    = varargin{1};
subsys   = varargin{2};
onlyEdited = true;
if (nargin == 3)
    onlyEdited = varargin{3};
end

objects  = {};
selected = 1;

% Use StaticLinkStatus - as we don't need to resolve any unedited links
% Don't need to look under links as they would have broken if they were
% changed
dlinks = find_system(model, ...
                     'LookUnderMasks', 'on', ...
                     'Variants', 'AllVariants',...
                     'SkipLinks', 'on', ...
                     'StaticLinkStatus', 'inactive');

vers = get_param(dlinks, 'LibraryVersion');
if ~iscell(vers)
  vers = {vers};
end

% Filter out un-edited links if required
if onlyEdited
    idx = strncmp(vers, '*', 1);
    dlinks = dlinks(idx);
end

plinks    = find_system(model, ...
                        'LookUnderMasks', 'on', ...
                        'Variants', 'AllVariants',...
                        'SkipLinks', 'on', ...
                        'StaticLinkStatus', 'resolved');
plinkdata = get_param(plinks, 'LinkData');
idx       = [];
for i = 1:length(plinkdata)
  if ~isempty(plinkdata{i})
    idx = [idx;i]; %#ok
  end
end
plinks = plinks(idx);
dlinks = [dlinks;plinks];

% Add the requested subsystem to the list as well
% if it is disabled or is parameterized
if ~isempty(subsys)
  linkStatus = get_param(subsys, 'StaticLinkStatus');
  if strcmp(linkStatus, 'inactive') || ...
      (strcmp(linkStatus, 'resolved') && ~isempty(get_param(subsys, 'LinkData')))
    dlinks = [dlinks;{subsys}];
  end
end
dlinks = unique(dlinks);

% No edited or requested links
if isempty(dlinks)
  return;
end

% Highlighted one
selected = find(strcmp(dlinks, subsys));

% Now we need to pass to the java UI, the following :
% 1) Fullpath of subsystem
% 2) Disabled link or not
% 3) AncestorBlock (2 can be derived from this, here or in java)
% 4) Handle to the block
dnames = get_param(dlinks, 'Name');
if ~iscell(dnames)
  dnames = {dnames};
end

% Get library paths derived as a combination of both ancestor blocks (for
% disable links) and reference blocks (for parameterized links)
dancest = get_param(dlinks, 'AncestorBlock');
if ~iscell(dancest)
  dancest = {dancest};
end

drefs = get_param(dlinks, 'ReferenceBlock');
if ~iscell(drefs)
  drefs = {drefs};
end

dlibpaths = dancest;
idx = find(strcmp(dlibpaths, ''));
dlibpaths(idx) = drefs(idx);

ddupes = cell(length(dlibpaths), 1);
for i = 1:length(dlibpaths)
  idxes = find(strcmp(dlibpaths{i}, dlibpaths));
  ddupes{i} = (length(idxes) > 1);
end

dhandles = get_param(dlinks, 'Handle');
if ~iscell(dhandles)
  dhandles = {dhandles};
end

versions = get_param(dlinks, 'LibraryVersion');
if ~iscell(versions)
  versions = {versions};
end

objects = cell(1, length(dlinks));
for i = 1:length(dlinks)
  disabled = ~isempty(dancest{i});
  objects{i} = LinkObject(dnames{i}, dlinks{i}, ...
    dlibpaths{i}, versions{i}, ...
    dhandles{i}, ...
    disabled, ~disabled, ...
    ddupes{i});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function success = i_doApply(blocks, actions)

numBlocks     = blocks.size;
pushBlocks    = {};
restoreBlocks = {};
success       = true;

% Walk this backward - very important for reverse hierarchy
% especially in the push case
for i = (numBlocks-1):-1:0
  action = actions.elementAt(i);
  if strcmp(action, '--> Push')
    pushBlocks{end + 1} = blocks.elementAt(i); %#ok
  else
    restoreBlocks{end + 1} = blocks.elementAt(i); %#ok
  end
end

% Determine if there are any clashes
clashBlocks = i_DetermineClashes(pushBlocks, restoreBlocks);
if ~isempty(clashBlocks)
  if ~iscell(clashBlocks)
    clashBlocks = {clashBlocks};
  end

  conflictTxt = DAStudio.message('Simulink:dialog:LinksConflictTxt');

  txt = [{conflictTxt}, {''}, clashBlocks];
  errordlg(txt, DAStudio.message('Simulink:dialog:LinksConflictTitle'), 'modal');
  success = false;
  return;
end

% Determine if any changes are going to be discarded
lostChanges = slInternal('examineLinks', restoreBlocks, pushBlocks);
lostChangeBlocks = getfullname(lostChanges);
if ~iscell(lostChangeBlocks)
  lostChangeBlocks = {lostChangeBlocks};
end

% Warn about changes being lost
if ~isempty(lostChangeBlocks)
  disc1 =  DAStudio.message('Simulink:dialog:LinkDiscard1');
  disc2 =  DAStudio.message('Simulink:dialog:LinkDiscard2');
  disc3 =  DAStudio.message('Simulink:dialog:LinkDiscard3');
  
  txt = [{disc1}, {''}, ...
    restoreBlocks, {''},...
    {disc2}, {''}, ...
    lostChangeBlocks];
  
  choice = questdlg(txt, disc3, 'OK', 'Cancel', 'OK');
  if strcmp(choice, 'Cancel')
    return;
  end
end

% Proceed with changes
for i = (numBlocks-1):-1:0
  action = actions.elementAt(i);
  block  = blocks.elementAt(i);
  if strcmp(action, '--> Push')
    set_param(block, 'LinkStatus', 'propagateHierarchy');
  else
    set_param(block, 'LinkStatus', 'restoreHierarchy');
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function libPaths = i_GetLibPaths(blocks)

ancest = get_param(blocks, 'AncestorBlock');
if ~iscell(ancest)
  ancest = {ancest};
end

refs = get_param(blocks, 'ReferenceBlock');
if ~iscell(refs)
  refs = {refs};
end

libPaths = ancest;
idx = find(strcmp(libPaths, ''));
libPaths(idx) = refs(idx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clashes = i_DetermineClashes(pushBlocks, restoreBlocks)

clashes = {};

pushLibPaths    = i_GetLibPaths(pushBlocks);
restoreLibPaths = i_GetLibPaths(restoreBlocks);

% For push blocks, check with restore blocks as well as push blocks
for i = 1:length(pushLibPaths)
  idxes = strcmp(pushLibPaths{i}, restoreLibPaths);
  if any(idxes)
    clashes = [clashes pushBlocks(i) restoreBlocks(idxes)]; %#ok
  end
  
  idxes = find(strcmp(pushLibPaths{i}, pushLibPaths));
  idxes = setdiff(idxes, i);
  if ~isempty(idxes)
    clashes = [clashes pushBlocks(idxes)]; %#ok
  end
end

clashes = unique(clashes);

