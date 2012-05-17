function [blocksTree, blockNames] = SigAndScopeMgrLoadLibrary(LibName)
%SIGANDSCOPEMGRLOADLIBRARY
%  SIGANDSCOPEMGRLOADLIBRARY Load a particular library and returns the
%  hierarchy of all is children.

%   Copyright 2009 The MathWorks, Inc.

libHandle = LoadSystem( LibName );

BlockFullNames = {};
[blocksTree, blockNames] = FindAllChildren(libHandle, BlockFullNames);

%endfunction

%
%--------------------------------------------------------------------------
% Function : LoadSystem
% Abstract : Load a particular library, if not already inmem
%--------------------------------------------------------------------------
%
function libH = LoadSystem(lib)

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