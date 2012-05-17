function vrcadcleanup(filename, varargin)
%VRCADCLEANUP Cleanup VRML file exported from a CAD tool.
%
%   VRCADCLEANUP modifies the VRML file exported from Pro/Engineer or 
%   SolidWorks to work with Simulink 3D Animation.
%
%   VRCADCLEANUP(filename) copies the specified filename to a backup file
%   using the extension BAK, then modifies the original file to remove
%   everything but the inlines, viewpoints and transforms and names the
%   inlines transforms based on the inline part name.
%
%   VRCADCLEANUP(filename, hint) respects the supplied hint when making 
%   the conversion. Possible values of hint argument are:
%   
%     'solidworks' - Assumes that the original set of VRML files is
%                    exported from SolidWorks. Adds / increments the 
%                    numerical suffix to the node names to match part names
%                    present in corresponding physical modeling XML file.
%
%   Note:
%      This function expects that the input file structure corresponds to
%      the typical output of the specified CAD tools. It is supposed that
%      the input file contains a structure of Viewpoints and Inline nodes 
%      (possibly contained in one layer of Transform nodes), one Inline 
%      for each part of the exported assembly.  
%      Any additional nodes, including Transform nodes that don't contain
%      Inlines, are discarded on output. 
%      Hierarchically organised assemblies (where Inline files instead of 
%      part geometries contain further groups of nested node Inlines) 
%      are also processed. All Inline references found in such sub-assembly 
%      files are copied to the main VRML file, wrapped by a Transform node 
%      with name corresponding to the sub-assembly name.
%      The output file structure can be corrupted if this function is 
%      applied to a file that isn't a product of a CAD export filter.
%
%   Example:
%      vrcadcleanup('four_link.wrl');
%
%   See also STL2VRML, VRPHYSMOD.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/04/15 15:51:01 $ $Author: batserve $

% Known issues:
% - In Transforms (and Inlines in them), everything after line with .wrl is
%   ignored - all subsequent fields will be replaced by default field
%   values by viewers. Should not be a problem with CAD-generated VRML 
%   files, these files usually don't contain spacial information in the
%   main file.

hint = '';
% check arguments, set hint if supplied
if nargin > 2
  throwAsCaller(MException('VR:invalidinarg', 'Too many arguments.'));
elseif nargin == 2
  if ~strcmp(varargin{1}, 'solidworks')
    throwAsCaller(MException('VR:invalidinarg', 'Invalid ''hint'' argument.'));
  end
  hint = varargin{1};
end

% call validateName with reset flag true to initialize its persistent variables
validateName('', '', true);

% open and read input file, line by line
fR = fopen(filename, 'rt');
if eq(fR, -1)
  error('VR:cantopeninputfile', 'Could not open the input file.');
end
lines = {};
while true
  tline = fgetl(fR); 
  if ~ischar(tline), break, end
  lines{end+1} = tline; %#ok<AGROW>
end
fclose(fR);

% test for VRML token at the beginning of the file
if ~strncmp(lines{1}, '#VRML V2.0 utf8', 15)
  error('VR:filenotvrml', 'The input file is not a valid VRML97 file!');
end 

% test for token that marks already processed files
if ~isempty(strmatch('#_Processed_by_the_vrcadcleanup_function', lines))
  error('VR:filealreadyprocessed', 'The input VRML file has been already processed by vrcadcleanup!');
end  

% create the backup file and the output file
[mainpath, name] = fileparts(filename);
if ~movefile(filename, fullfile(mainpath, [name '.bak']))
  error('VR:cantmovefile', 'Could not create backup copy of the input file.');
end
fW = fopen(filename, 'wt');
if eq(fW, -1)
  error('VR:cantopenoutputfile', 'Could not open the output file for writing.');
end

% loop through the lines read from the input file
% look for: header, Viewpoints, Inlines and Transforms
lcount = length(lines);
li = 1;
while (li <= lcount)

  % process the next line from the input file, whole file has been read
  % already into lines{}
  tline = lines{li}; li = li + 1; 

  % process file header
  if strncmp(tline, '#VRML', 5) % Check if the line is a header comment
 
    %write the line to the output
    fprintf(fW, '%s\n', tline);
    fprintf(fW, '\n'); % add newline
    
    % add the token that marks already processed files
    fprintf(fW, '%s\n', '#_Processed_by_the_vrcadcleanup_function'); 
    
    % write supplied hints to the output file for further use by vrphysmod()
    if ~isempty(hint)
      fprintf(fW, ['#_Hints: ' sprintf('%s ', varargin{:}) '\n']);
    end
    fprintf(fW, '\n'); % add newline

  % process Viewpoints
  elseif regexp(tline, 'Viewpoint', 'once') % check if the line contains a Viewpoint
    i = 0;
    while (isempty(strfind(tline,'}')) && li <= lcount) % safety check to supplant EOF check
      i = i+1;
      viewpoint{i} = tline; %#ok<AGROW>
      tline = lines{li}; li = li + 1; 
    end
    
    % closing bracket not found till the EOF
    if isempty(strfind(tline,'}'))
       error('VR:badfilestructure', 'Closing bracket not found for the Viewpoint node defined at line: %d', li-i );
    end
    
    % write the Viewpoint lines to the output
    fprintf(fW, '%s\n', viewpoint{1:i});
    fprintf(fW, '%s\n', tline); % add the line with the closing bracket
    fprintf(fW, '\n'); % add newline

  % process Inlines, possibly inside a Transform (usually defining initial
  % offset of parts within assemblies)
  elseif ~isempty(strfind(tline, 'Transform')) || ~isempty(strfind(tline, 'Inline')) % Check if the line contains Transform or Inline
    
    % Transform or Inline?
    if ~isempty(strfind(tline, 'Transform'))
      tr = true;
    else
      tr = false;
    end
    
    % read lines until the line with '.wrl' found
    i = 0;
    while (isempty(strfind(lower(tline), '.wrl')) && li <= lcount) % safety check to supplant EOF check
      i = i+1;
      nodelines{i} = tline; %#ok<AGROW>
      tline = lines{li}; li = li + 1; 
    end
    % the last line - URL line of (nested) Inline stays in tline
    
    % '.wrl' not found till the EOF
    if isempty(strfind(lower(tline), '.wrl'))
      if tr
        error('VR:badfilestructure', 'Valid URL field not found for an Inline node within the Transform defined at line: %d', li-i );
      else  
        error('VR:badfilestructure', 'Valid URL field not found for the Inline node defined at line: %d', li-i );
      end
    end
    
    % parse the URL line to extract the file name to be used in the DEF name
    % typical URL line:
    % 'url [ "PendulumAxis.wrl" ]' or also '[ "gripdir/grip.wrl" ]'
    % divide the relevant line parts into 2 tokens - 'path/name' and '.wrl'
    nodeName = regexpi(tline, '"\s*(.+)(\.wrl)', 'tokens', 'once');

    [ipath, iname] = fileparts(nodeName{1});  
    iext = nodeName{2};
    
    % in case of multiple references to the same file, create a unique name
    % for each Inline instance in the form 'SourceFile_n'
    nodeNameRep = validateName(iname, hint);
        
    % if there is another inlined file, just include it's inlines,
    % otherwise include the actual part inline
    % relative part, if any, of the inline node file needs to be added to all URL's
    % contained in the Inline file
    if ~parseInlineFile(fW, mainpath, ipath, [iname iext], hint);
    
      % wrap the Inline/Transform node with another Transform with unique DEF name 
      fprintf(fW, '%s\n', ['DEF ' nodeNameRep ' Transform {']);  % Here a unique DEF name used
      fprintf(fW, '%s\n', 'children [');

      % copy the read Inline/Transform lines to the output, indent 2 spaces
      fprintf(fW, '  %s\n', nodelines{1:i});

      % to strip any spaces around inlined file name in URL (produced by
      % the SolidWorks export filter), reconstruct the URL from obtained
      % regexp tline tokens
      fprintf(fW, '  %s\n', ['url [ "' nodeName{1} nodeName{2} '" ]']);
      % close the Inline node
      fprintf(fW, '  %s\n', '}' );

      % close the original transform node, if the Inline was inside a Transform
      if tr
        fprintf(fW, '%s\n', '  ]');
        fprintf(fW, '%s\n', '  }');
        % fprintf(fW, '\n'); % add newline
      end

      % close the newly created transform node
      fprintf(fW, '%s\n', ']');
      fprintf(fW, '%s\n', '}');
      fprintf(fW, '\n'); % add newline
 
    end
  end

end

fclose(fW);

end


function inlineFound = parseInlineFile(fH, mainpath, relpath, inlineFile, hint)
inlineFound = false;

fR = fopen(fullfile(mainpath, relpath, inlineFile), 'rt');
if eq(fR, -1)
  warning('VR:cantopeninlinefile', 'Could not open the inlined file %s', inlineFile);
  return
end

lines = {};

% read inline file into lines{}, check for more inline nodes 
% in the first 5 lines of the file
i = 0;
while true
  tline = fgetl(fR);
  if ~ischar(tline)
    break
  end
  lines{end+1} = tline; %#ok<AGROW>
  if ~inlineFound
    i = i+1;
    if regexpi(tline, 'inline')
      inlineFound = true;
    elseif i>5
      % No inline found in the first 5 lines, so return
      fclose(fR);
      return
    end
  end
end
fclose(fR);

% found inlines so need to process and write into fH file
% loop through the lines read from the input file
% look for: header, Viewpoints, Inlines and Transforms

% strip the '.wrl' from the Inline filename again
inlineName = regexpi(inlineFile, '\s*(.+)(\.wrl)', 'tokens', 'once');
[~, iname] = fileparts(inlineName{1});  

% write the Transform that wraps all the Inlines found in this Inline
% useful for those that want to manipulate objects in a hierarchical way
% all nodes inside this Transform will be indented to be distinguished 
% from the nodes at the main hierarchy level

% in case of multiple references to the same file, create a unique name
% for each Inline instance in the form 'SourceFile_n'
% ignore any hints in case of this (inactive, not associated with an own geometry) grouping node
nodeNameRep = validateName(iname, '');  

fprintf(fH, '%s\n', ['DEF ' nodeNameRep ' Transform {']);
fprintf(fH, '%s\n', 'children [');
fprintf(fH, '\n'); % add newline

lcount = length(lines);
li = 1;
while (li <= lcount)

  % process the next line from the input file, whole file has been read
  % already into lines{}
  tline = lines{li}; li = li + 1;

  % process file header
  if strncmp(tline, '#VRML', 5) % Check if the line is a header comment

    % ignore it

  % process Viewpoints
  % CAD tools don't export Viewpoints into the group Inline files now, 
  % but might be the case in the future
  elseif regexp(tline, 'Viewpoint', 'once') % check if the line contains a Viewpoint
    i = 0;
    while (isempty(strfind(tline,'}')) && li <= lcount) % safety check to supplant EOF check
      i = i+1;
      viewpoint{i} = tline; %#ok<AGROW>
      tline = lines{li}; li = li + 1;
    end

    % closing bracket not found till the EOF
    if isempty(strfind(tline,'}'))
      error('VR:badfilestructure', 'Closing bracket not found for the Viewpoint node defined in file %s at line: %d', inlineFile, li-i );
    end

    % write the Viewpoint lines to the output, indent 2 spaces
    fprintf(fH, '  %s\n', viewpoint{1:i});
    fprintf(fH, '  %s\n', tline); % add the line with the closing bracket
    fprintf(fH, '\n'); % add newline

  % process Inlines, possibly inside a Transform (usually defining initial
  % offset of parts within assemblies)
  elseif ~isempty(strfind(tline, 'Transform')) || ~isempty(strfind(tline, 'Inline')) % Check if the line contains Transform or Inline

    % Transform or Inline?
    if ~isempty(strfind(tline, 'Transform'))
      tr = true;
    else
      tr = false;
    end

    i = 0;
    while (isempty(strfind(lower(tline), '.wrl')) && li <= lcount) % safety check to supplant EOF check
      i = i+1;
      nodelines{i} = tline; %#ok<AGROW>
      tline = lines{li}; li = li + 1;
    end
    % the last line - URL line of nested Inline stays in tline

    % '.wrl' not found till the EOF
    if isempty(strfind(lower(tline), '.wrl'))
      if tr
        error('VR:badfilestructure', 'Valid URL field not found for an Inline node within the Transform defined in file %s at line: %d', inlineFile, li-i );
      else
        error('VR:badfilestructure', 'Valid URL field not found for the Inline node defined in file %s at line: %d', inlineFile, li-i );
      end
    end

    % parse the URL line to extract the file name to be used in the DEF name
    % typical URL line:
    % 'url [ "PendulumAxis.wrl" ]' or also '[ "gripdir/grip.wrl" ]'
    % divide the relevant line parts into 2 tokens - 'path/name' and '.wrl'
    nodeName = regexpi(tline, '"\s*(.+)(\.wrl)', 'tokens', 'once');
    
    [ipath, iname] = fileparts(nodeName{1});  
    iext = nodeName{2};
   
    % in case of multiple references to the same file, create a unique name
    % for each Inline instance in the form 'SourceFile_n'
    nodeNameRep = validateName(iname, hint);

    % parse Inline files recursively, if Inline contains another level of
    % Inlines, also add them to the main VRML file fH
    % compose the relative path from passed relative path and path added in
    % this Inline's URL
    if ~parseInlineFile(fH, mainpath, fullfile(relpath, ipath), [iname iext], hint);

      % wrap the Inline/Transform node with another Transform with unique DEF
      % name, indent 2 spaces
      fprintf(fH, '  %s\n', ['DEF ' nodeNameRep ' Transform {']);  % Here a unique DEF name used
      fprintf(fH, '  %s\n', 'children [');

      % copy the read Inline/Transform lines to the output, indent 4 spaces
      fprintf(fH, '    %s\n', nodelines{1:i});

      % to strip any spaces around inlined file name in URL (produced by
      % the SolidWorks export filter), reconstruct the URL from obtained
      % regexp tline tokens
      fprintf(fH, '    %s\n', ['url [ "' fullfile(relpath, ipath, [iname iext]) '" ]']);

      % close the Inline node
      fprintf(fH, '    %s\n', '}' );

      % close the original transform node, if the Inline was inside a Transform
      if tr
        fprintf(fH, '  %s\n', '  ]');
        fprintf(fH, '  %s\n', '  }');
      end

      % close the newly created transform node
      fprintf(fH, '  %s\n', ']');
      fprintf(fH, '  %s\n', '}');
      fprintf(fH, '\n'); % add newline

    end
  end
end
  
% close the Inlined file group Transform node
fprintf(fH, '%s\n', ']');
fprintf(fH, '%s\n', '}');
fprintf(fH, '\n'); % add newline

end

% build structure of unique DEF names constructed from part file names
% optional 3rd argument is reset flag
function newName = validateName(name, hint, varargin)

% persistent arrays to store the names used for the nodes and their count
persistent usedNames count

% if called with the reset flag true, initialize persistent variables
if nargin == 3 && varargin{1} == true 
  usedNames = {};
  count = [];
  return
end

% If the 'solidworks' hint supplied, we need to add a -1 or increment 
% the suffix if there is already a number
if strcmp(hint, 'solidworks')
  % find whether there is a '-' followed immediately by a group of digits
  % at the end of the name 
  dashLoc = regexpi(name, '-\d+$');
  if isempty(dashLoc)
    name = [name '-1'];
  else
    num = str2double(name(dashLoc(end)+1:end));
    name = [name(1:dashLoc(end)-1) '-' num2str(num+1)];
  end
end
    
x = strmatch(name, usedNames, 'exact');

% assign to the output argument an input name if unique, otherwise add
% the '_n' suffix
if isempty(x)
  newName = name;
else
  count(x) = count(x)+1;
  newName = [name '_' num2str(count(x))];
end

% build arrays
usedNames{end+1} = newName;
count(end+1) = 0;
end
