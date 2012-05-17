function [blocksTree, blockNames, libFlat] = libbrowse(varargin)
%LIBBROWSE Simulink Library Browser
%  LIBBROWSE provides the functions for populating the Library Browser.

%  $Revision: 1.22.2.16 $ 
%  Copyright 1990-2009 The MathWorks, Inc.

if nargin < 1
  error('Incorrect number of input arguments');
end

warning('Simulink:LibraryBrowser:DeprecationWarning','%s is deprecated and will be removed in a future release', 'LIBBROWSE');

% Determine whether we want to Create the entire tree
% or Initialize the tree for incremental loading. If we 
% initialize the tree, then we would want to load the library
% upon tree expansion.
Action = lower(varargin{1});

switch (Action)
case 'initialize'
  [blocksTree, blockNames, libFlat] = InitializeBrowser;
  
case 'load'
  LibName = varargin{2};
  [blocksTree, blockNames] = LoadLibrary(LibName);

case {'create', ''}
  [blocksTree, blockNames] = PopulateBrowser;
  
end

%
%--------------------------------------------------------------------------
% Function : InitializeBrowser
% Abstract : Return the list of library names.
%--------------------------------------------------------------------------
%
function [libNames, libs, libFlat] = InitializeBrowser

all_slblocks = which('-all','slblocks.m');
all_slblocks2 = which('-all','SLBLOCKS.M');
all_slblocks = union(all_slblocks, all_slblocks2);
libNames     = {};
libs         = {};
libFlat      = [];

% Process all slblocks to get all the libraries
for i = 1:length(all_slblocks)
  fid  = fopen(all_slblocks{i}, 'r');
  if fid == -1,
    warning(['Error while opening the Simulink Library Browser.  ',...
             'The file ''%s'' could not be opened.'], all_slblocks{i});
    continue;
  end
  
  file = fread(fid, '*char')';
  fclose(fid);
  idx = findstr(file, 'slblocks');
  if (idx)
    file(1:(idx(1)+8)) = [];
  end
  clear('blkStruct', 'Browser')
  
  try
    eval(file)
    currentInfo = blkStruct(1);
 
    if isfield(currentInfo, 'Browser')
      % This slblock.m may have returned a null Name as a place holder.
      % Just ignore any entries with Name set to the null string.
      % Browser may be a vector of Name/Library entries.
      for idx = 1:length(currentInfo.Browser)
        if length( currentInfo.Browser(idx).Name ) ~= 0
          libNames = [libNames ; {currentInfo.Browser(idx).Name   }'];
          libs     = [libs     ; {currentInfo.Browser(idx).Library}'];
          libFlat(end+length(currentInfo.Browser(idx))) = 0;
          if isfield(currentInfo.Browser(idx), 'IsFlat')
            libFlat(end-length(currentInfo.Browser(idx))+1:end) = [currentInfo.Browser(idx).IsFlat]';
          end
        end
      end
    else
      libNames = [libNames ; {strrep(currentInfo.Name,sprintf('\n'),' ')}'];
      libs     = [libs     ; {currentInfo.OpenFcn}'];
      libFlat(end+1) = 0;
      if isfield(currentInfo,'IsFlat')
        libFlat(end) = currentInfo.IsFlat;
      end
    end
    
  catch me
    errMsg = me.message;
    defwarn = warning;
    warning('on','all')
    warning(['Error evaluating ''' all_slblocks{i} ...
             '''. Error Message: ' errMsg])
    warning(defwarn)
  end
end

% Make the list of libraries unique
[libNames idx] = unique(libNames);
libs           = libs(idx);
libFlat        = libFlat(idx);

% Set Simulink to be the first library
simulinkIdx = find(strcmpi(libNames, 'simulink'));
if ~isempty(simulinkIdx)
  newOrder = [simulinkIdx 1:simulinkIdx-1 simulinkIdx+1:length(libs)];
  libNames = libNames(newOrder);
  libs     = libs(newOrder);
  libFlat  = libFlat(newOrder);
end

%
%--------------------------------------------------------------------------
% Function : LoadLibrary
% Abstract : Load a particular library and find its children
%--------------------------------------------------------------------------
%
function [blocksTree, modFullNames] = LoadLibrary(libName)

libHandle = i_LoadSys(libName);
BlockFullNames = {};
[blocksTree modFullNames] = FindAllChildren(libHandle, BlockFullNames);

%
%--------------------------------------------------------------------------
% Function : i_LoadSys
% Abstract : Load a particular library, if not already inmem
%--------------------------------------------------------------------------
%
function libH = i_LoadSys(lib)

  libH  =  find_system(0,'SearchDepth',0,'Name',lib);
  
  if isempty(libH),
    %
    % Load the lib.  Suppress warning as per legacy in libbrowse.m.
    %
    try
      defwarn = warning;
      warning('off');
      load_system(lib);
    end
    warning(defwarn) 
           
    %
    % Grab the bd handle.  It should be there now.
    %
    libH  =  find_system(0,'SearchDepth',0,'CaseSensitive','off','Name',lib);
    if isempty(libH),
      error(['Library ''' lib ''' not found or not available']);
    end
  end

%endfunction

%
%--------------------------------------------------------------------------
% Function : PopulateBrowser
% Abstract : Populate the browser view.
%--------------------------------------------------------------------------
%
function [blocksTree, modFullNames] = PopulateBrowser

[libNames, libs] = InitializeBrowser;
defwarn = warning;
warning('off','all');
% Load all libraries
for i = 1:length(libs)
  load_system(libs{i})
  libHandles(i) = get_param(libs{i}, 'Handle');  %#ok - mlint
end
warning(defwarn)

BlockFullNames = {};
[blocksTree modFullNames] = FindAllChildren(libHandles, BlockFullNames);
% set the names of the libraries
for i = 1:length(blocksTree)
  indLib = blocksTree{i};
  indLib{1} = libNames{i};
  blocksTree{i} = indLib;
end


%
%--------------------------------------------------------------------------
% Function : FindAllChildren
% Abstract : Finds all blocks in the library. This is a recursive
%            function.    
%--------------------------------------------------------------------------
%
function [b, BlockFullNames] = FindAllChildren(libH, BlockFullNames)

defwarn = warning;
warning('off','all');
b = {};
k = 0;
for i = 1:length(libH)
  % lib_blocks contains the handles of all the blocks inside of the
  % library and subsystem to be shown by the Library Browser
  lib_blocks = find_system(libH(i), 'SearchDepth', 1, ...
      'LookUnderMasks', 'functional');
  lib_blocks(1) = [];
  
  % If the there is a Configurable subsystem, then do not show the blocks in it.
  if ~strcmp(get_param(libH(i),'Type'),'block_diagram')
    if strcmp(get_param(libH(i),'BlockType'),'SubSystem')
      if (~strcmp(get_param(libH(i),'TemplateBlock'),''))
        lib_blocks = [];
      end
    end
  end
  
  lib_blocks = OrderBlocks(lib_blocks);

  % If looking at the top Simulink library, reorder the Subsystem
  % blocks so the Additional Math & Discrete Library is on the bottom
  % Currently, this means moving the top node to the bottom (Oct03)
  if strcmp(get_param(libH(i),'Name'),'simulink')
      lib_blocks = [lib_blocks(2:end);lib_blocks(1)];
  end
  
  Name = strrep(get_param(libH(i), 'Name'),sprintf('\n'),' ');
  
  if strcmpi(get_param(libH(i),'Type'),'block'),
    OpenFcnStr = get_param(libH(i), 'OpenFcn');
  else
    OpenFcnStr = '';
  end
  
  prune = 0;
  if ~isempty(OpenFcnStr) 
    % Make sure there are no semi-colons in the OpenFcnStr
    % if it is in fact a model.
    OpenFcnStr = strrep(OpenFcnStr,';','');
    subsystem = '';
    
    % Look for special case function for xPC libraries (see g202178)
    if strncmp(OpenFcnStr, 'load_open_subsystem', 19)
      cmd = strrep(OpenFcnStr, 'load_open_subsystem', 'FindLibAndSubsystem');
      [OpenFcnStr, subsystem] = eval(cmd);
    end

    if exist(OpenFcnStr,'file')==4
      load_system(OpenFcnStr);
      if strcmp(get_param(OpenFcnStr, 'BlockDiagramType'), 'library')
        if isempty(subsystem)
          O_blk = get_param(OpenFcnStr, 'Handle');
          lib_blocks = find_system(O_blk, 'SearchDepth', 1);
        else
          O_blk = get_param(subsystem, 'Handle');
          lib_blocks = find_system(O_blk, 'SearchDepth', 1);
        end
        lib_blocks(1) = [];
        lib_blocks = OrderBlocks(lib_blocks);
      else
        if strcmpi(get_param(OpenFcnStr, 'Open'), 'off')
          close_system(OpenFcnStr, 0);
        end
        % if it is a model, then it should be pruned.
        prune = 1;
      end
    else
      % If the open function exists, but it isn't a model,
      % check if this subsystem is empty.
      totalBlocks = find_system(libH(i), 'SearchDepth', 1, ...
                                'FollowLinks', 'on', ...
                                'LookUnderMasks', 'all');
      totalBlocks(1)=[];
      if isempty(totalBlocks) && strcmp(get_param(libH(i), 'BlockType'), 'SubSystem')
        % If subsystem is empty, then skip this block for the library browser unless
        % there is a mask and it has a parameter named 'ShowInLibBrowser'.
        if strcmp(get_param(libH(i),'Mask'),'off') || ...
              isempty(strfind(get_param(libH(i),'MaskVariables'),'ShowInLibBrowser'))
          prune = 1;
        end
      end
    end
  end

  % Register only the non pruned blocks
  if ~prune
    k = k + 1;
    BlockFullNames{end+1} = getfullname(libH(i));
    
    if isempty(lib_blocks)
      b{k,1} = Name;
    else
      [blockNames, BlockFullNames] = FindAllChildren(lib_blocks, BlockFullNames);
      b{k,1}{1} = Name;
      b{k,1}{2} = blockNames;
    end
  end
  
end
warning(defwarn)

%
%--------------------------------------------------------------------------
% Function: OrderBlocks
% Abstract: Orders the blocks so that subsystems are first and then blocks.
%--------------------------------------------------------------------------
%
function blocks = OrderBlocks(blocksIn)

if strcmpi(get_param(blocksIn,'Type'),'block'),
  %
  % The idea here is that subsystems with a dialog or an open function that
  % doesn't point to a block library are treated as regular blocks.  These
  % and regular blocks are placed at the end of the blocks list, following
  % any subsystems or subsystems that point to other libraries.
  %
  type = get_param(blocksIn, 'BlockType');
  dlg = hasmaskdlg(blocksIn);
  diveIn=~dlg & strcmpi(type,'Subsystem');
  openFcnStr = get_param(blocksIn,'OpenFcn');
  if ischar(openFcnStr),
    openFcnStr = {openFcnStr};
  end    
  for i=1:length(openFcnStr),
    if ~strcmpi(openFcnStr{i},''),
      openFcnStr{i} = strrep(openFcnStr{i},';','');
      if exist(openFcnStr{i},'file') ~= 4,
        diveIn(i) = false;
      end
    end
  end
  
  firsts=find(diveIn == true);
  lasts=find(diveIn == false);
  
  %Sort based on the name of the block 
  last_names = cellstr(get_param(blocksIn(lasts), 'Name'));
  last_names = regexprep(last_names, '\s+', ' ');
  [b indx] = sort(lower(last_names));  %#ok - mlint
  lasts = lasts(indx);
  
  first_names = cellstr(get_param(blocksIn(firsts), 'Name'));
  first_names = regexprep(first_names, '\s+', ' ');
  [b indx] = sort(lower(first_names));  %#ok - mlint
  firsts = firsts(indx);
  
  blocks=blocksIn([firsts; lasts]);
else
  blocks = blocksIn;
end


%
%--------------------------------------------------------------------------
% Function : FindLibAndSubsystem
% Abstract : Returns the two passed parameters straight back. This is used
%            to have MATLAB parse the parameters for us.
%--------------------------------------------------------------------------
%
function [r1, r2] = FindLibAndSubsystem(p1, p2)

r1 = p1;
r2 = p2;
