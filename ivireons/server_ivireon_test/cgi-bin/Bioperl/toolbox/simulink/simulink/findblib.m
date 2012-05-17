function varargout = findblib
%FINDBLIB Searches the MATLAB path for products with Simulink blocks.

%   Optionally returns: 
%            0 for failure (an error occurred).
%            1 for success. 
%            2 when the window is already open. 
%            3 when no slblocks files are found.

%   Copyright 1990-2009 The MathWorks, Inc.

warning('Simulink:LibraryBrowser:DeprecationWarning','%s is deprecated and will be removed in a future release', 'FINDBLIB');

errmsg = '';
errAlreadyOpen = 2;
errNoFilesFound = 3;

% Determine if the library is already loaded up.  If it is, exit early.
found = find_system(0,...
                    'SearchDepth', 0,...
                    'Name','Blocksets_and_Toolboxes');
if ~isempty(found),
  open_system(found);
  if nargout > 0, varargout{1} = errAlreadyOpen; end
  return
end

% Put up message box.
mhdl = helpdlg('Scanning the MATLAB path for Simulink blocks...','Please wait');
drawnow;

% Find all slblocks.m
libs = which('slblocks.m', '-all');
if ~isempty(libs)
  libs = cellstr(unique(char(libs),'rows'));  % Remove any duplicates.
end

% If no slblocks.m files were found place a message in the subsystem
% and get out.
if isempty(libs)
  delete(mhdl);
  mhdl = msgbox('No Blocksets or Toolboxes with Simulink Blocks are installed.',...
      'Simulink','help');
  if nargout > 0, varargout{1} = errNoFilesFound; end
  return
end

% Create the new system as an unlocked library.
sys = ['Blocksets_and_Toolboxes'];
new_system(sys,'Library');
set_param(sys,'Location',[28 247 518 357],'Lock','off');

% disable the toolbar and statusbar
set_param(sys, 'ToolBar', 'off', 'StatusBar', 'off');

open_system(sys);

% Counters
row = 1;
col = 0;

% Define the position of the new blocks.
ys = 15; xs = 20; width = 50; xgap = 30; ygap = 40;
pos(1, :) = [xs    ys    xs+width    ys+width];
pos(2, :) = pos(1, :) + [width+xgap  0  width+xgap  0];
pos(3, :) = pos(2, :) + [width+xgap  0  width+xgap  0];
pos(4, :) = pos(3, :) + [width+xgap  0  width+xgap  0];
pos(5, :) = pos(4, :) + [width+xgap  0  width+xgap  0];
pos(6, :) = pos(5, :) + [width+xgap  0  width+xgap  0];

% Loop through the occurrences of 'slblocks.m' in the MATLAB path.
nBS = size(libs,1);
for i=1:nBS
  
  % Use fopen to avoid checking out the toolbox license keys
  % This code is not robust to changes in the variable name "blkStruct"
  fcnStr = '';
  fid = fopen(libs{i},'r');
  
  % Skip down to function definition.
  while 1
    fcnLine = fgetl(fid);
    if findstr(lower(fcnLine),'function'), break, end
  end
  
  % Start reading the file.
  while 1
    fcnLine = fgetl(fid);           % Read next line in file.
    if ~ischar(fcnLine), break, end  % Breaks out at end of file.
    dotsIndex = findstr(fcnLine,'...');
    if isempty(dotsIndex),
      fcnStr=[fcnStr fcnLine sprintf('\n')];
    else
      % We're removing the "..." and literally concatenating the
      % two affected lines to make one line
      % Note: this will remove the "..."s inside any quoted strings
      fcnLine(dotsIndex:dotsIndex+2) = [];
      fcnStr=[fcnStr fcnLine];
    end
  end
  fclose(fid);
  
  % Execute the function slblocks.
  if ~isempty(fcnStr),
    blkStruct = '';
    clear Browser;
    %eval(fcnStr,'errmsg = LocalErrHandler(libs{i}, nargout);');
    
    try
        eval(fcnStr);
    catch me
        errmsg = LocalErrHandler(libs{i}, nargout, me.message);
    end
    
    out = blkStruct;
  else
    errmsg = LocalErrHandler(libs{i}, nargout, '');
  end
  
  % If there was no error above (struct returned),
  % continue processing this file.
  if isstruct(out)
    for ind = 1:length(out)
      if ~isfield( out(ind), 'Name' ) && isfield( out(ind), 'Browser' )
          out(ind).Name = out(ind).Browser.Name;
          out(ind).OpenFcn = out(ind).Browser.Library;
          out(ind).MaskDisplay = ['image(imread(''', strrep(out(ind).Browser.PanelIcon, '\','/'), '''));'];
      end
        
      if ~isempty( out(ind).Name )  % Not a null name
        %
        % Determine if the block already exists.  This can happen when the
        %  MATLABPATH contains multiple directories that contain similar
        % slblocks.m files.
        %
        if isempty(find_system(sys,'Name',out(ind).Name)),
        
          % Create the block and set the required parameters, Name and OpenFcn.
          name = [sys '/' out(ind).Name];
    
          col = col + 1;
          if col > 6
            col = 1;
            row = row + 1;
            set_param(sys,'Location',[28 247 518 (247 + 110*row)]);
          end
          add_block('built-in/Subsystem',name, ...
                    'Position',(pos(col,:) + (row-1).*[0 90 0 90]));
      
          %
          % Set other block params (Name and OpenFcn required) the user desires.
          % Any other parameters the user provides are 'set' in the block.
          % Note that other non-subsystem parameters must be removed from 
          % the set as they are used by other Simulink components.
          %
          fieldsToRemove = { 'Browser', 'IsFlat', ...
                             'Viewer', 'Generator', 'ModelUpdaterMethods' };
          tmp = locRemoveFields(out(ind), fieldsToRemove);
          params = fieldnames(tmp);
          for ind = 1:length(params),
            value = eval(['tmp.' params{ind}]);
            try
              set_param(name,params{ind},value)
            catch me
              exceptionMsg = me.message;  
              errmsg = LocalErrHandler(libs{i}, nargout, exceptionMsg);
            end
          end
      
          % Flush the graphics so that blocks appear as they are added.
          drawnow;
        end
      end
    end
  end
end

% Turn off dirty flag, clean up figures and return to original directory.
set_param(sys,'Dirty','off','Lock','on');
if ishandle(mhdl), delete(mhdl); end
if (nargout > 0)
  varargout{1} = double(isempty(errmsg)); 
  warning(errmsg);
end

% Function: LocalErrHandler ==============================================
% Abstract:
%  Used to trap and process errors in user slblocks.m files.
%  The second input is to determine if we should display the error
%  dialog or not.  This value is based on nargout of the main function.
%
function str = LocalErrHandler(fname, showdialog, exceptionMsg)

str = sprintf('Error in file : %s\n%s', fname, exceptionMsg);
if (showdialog == 0)
  % Raise error dialog
  errordlg(str, 'Error in slblocks.m file');
end

% Function: locRemoveFields ==============================================
% Abstract:
%   Remove an unwanted field from the returned data structure.  The intent
%   is so that all the remaining properties are subsystem properties for
%   the "classic" unix library browser lib.

function out = locRemoveFields(blksStruct, fieldsToRemove)

out = blksStruct;

for k=1:numel(fieldsToRemove)
    if isfield(out,fieldsToRemove{k}),
        out = rmfield(out,fieldsToRemove{k});
    end
end

%[EOF] findblib.m
