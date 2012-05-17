function hyperlink(h, type, vargin)
%  HYPERLINK
%
%  Execute action to be taken when a user clicks a hyperlink displayed in
%  the Diagnostic Viewer where the action depends on the type of hyperlink.
%
%  Copyright 1990-2008 The MathWorks, Inc.

switch type
  
  % Hyperlink type: a Stateflow object id, e.g., #22. 
  % Action: open the chart containing the corresponding object in the
  % Stateflow editor and select the object.
  case 'id'
    txt = vargin;        % remove beginning
    [s,e] = regexp(txt, '\d+');
    id1 = 0;
    id2 = 0;
    id3 = 0;
    if(length(s)>=1)
      id1 = str2double(txt(s(1):e(1)));
    end
    if (length(s)>=2)
      id2 = str2double(txt(s(2):e(2)));
    end
    if (length(s)>=3)
      id3 = str2double(txt(s(3):e(3)));
    end
    sf('Open', id1,id2,id3);
  
  % Hyperlink type: path to a text file, typically an M-file that caused 
  % Action: open the file in the MATLAB editor.
  case 'txt'
    t = vargin;

    if (t(1) == '"'),
      t(t=='"') = '''';
    end
    if (exist(t, 'dir') == 7),
      ME = MException('DiagnosticViewer:HyperlinkError', ...
      'Expected path to a text file but got path to a directory.');
      throw(ME);
    else
      edit(t);
    end

  % Hyperlink type: path to a directory. 
  % Action: display the directory in a command shell.
  case 'dir'
    t = vargin;

    if (t(1) == '"'),
      t(t=='"') = '''';
    end

    curDir = pwd;
    cd (t);

    if ispc,
      cmd = ['cmd /c start',10];
    elseif isunix,
      cmd = 'xterm &';
    else
      return;
    end;
    dos(cmd);
    cd(curDir);

  % Hyperlink type: path to a model or a block in a model.
  % Action: open the model or subsystem containing the block and select
  % the block.
  case 'mdl'

    % need to turn off the "unable to load" warnings as this
    % can cause myriad useless warnings when the system in
    % question is a bad library link.
    filterWarningMsgId1 = 'Simulink:LoadSave:CannotOpenFile';
    state1 = warning('query', filterWarningMsgId1);
    state1 = state1.state;

    warning('off', filterWarningMsgId1);

    filterWarningMsgId2 = 'Simulink:Engine:UnableToLoadBd';
    state2 = warning('query', filterWarningMsgId2);
    state2 = state2.state;

    warning('off', filterWarningMsgId2);


    txt = vargin;
    
    % Fix for g511058: the GLEE text browser converts forward
    % slashes in hyperlinks to back slashes on Windows.
    txt = strrep(txt, '\', '/');
    
    % Check if txt is a valid model name and then open it.
    try 
      if exist(txt, 'file') == 4
        open_system(txt);
      end
      blockH = get_param(txt, 'handle');
    catch ME
      disp(['Hyperlink error (' ME.identifier '): ' ME.message]);
      warning(state1, filterWarningMsgId1);
      warning(state2, filterWarningMsgId2);
      return; % EARLY RETURN
    end

    if (ishandle(blockH))
      if strcmp(get_param(blockH,'Type'),'block') && ...
          ~strcmp(get_param(blockH,'iotype'),'none')
        bd = bdroot(blockH);
        sigandscopemgr('Create',bd);
        sigandscopemgr('SelectObject',blockH);
      else
        open_block_and_parent_l(h,blockH);
      end
    else
      disp('Hyperlink error: invalid block handle.')
    end
    warning(state1, filterWarningMsgId1);
    warning(state2, filterWarningMsgId2);
    
  case 'bus'
    txt = vargin;
    try %#ok<TRYNC>
      buseditor('Create', txt)
    end
    
end %end switch
end


function open_block_and_parent_l(h,blockH)
%
% Open block and parent
%
dehilitBlocks(h);
switch get_param(blockH, 'Type')
  
  case 'block'
    parentH = get_param(blockH,'Parent');
    % Check if block still exists (not in undo stack only)
    checkBlks = find_system(parentH, 'SearchDepth', 1, ...
      'FollowLinks', 'on', ...
      'LookUnderMasks', 'on', ...
      'Handle', blockH);
    if ~isempty(checkBlks)
      deselect_all_blocks_in_l(parentH);
      hiliteBlocks(h, blockH)
      set_param(blockH,'Selected','on');
    end
    
  case 'block_diagram'
    open_system(blockH);
    
end

end

function deselect_all_blocks_in_l(sysH)

selectedBlocks = find_system(sysH, 'SearchDepth', 1, 'Selected', 'on');
for i = 1:length(selectedBlocks),
  set_param(selectedBlocks{i},'Selected','off');
end

end

