function stl2vrml(source, destination)
%STL2VRML convert STL files to VRML file format.
%   STL2VRML(SOURCE) converts given STL file to a VRML file.
%
%   If SOURCE is a Physical Modeling XML file, STL2VRML converts all 
%   STL files referenced in the XML file. It also creates a main assembly 
%   VRML file which contains Inline references to all converted individual 
%   VRML files. All Inlines are wrapped by Transform nodes with DEF names 
%   corresponding to the part names defined in their respective STL source 
%   files. 
%
%   VRML files have the same name as corresponding STL files and the 
%   .WRL extension. They are placed into the current directory.
%
%   STL2VRML(SOURCE, DESTINATION) creates the converted VRML files in the
%   DESTINATION directory. If DESTINATION directory does not exist, 
%   STL2VRML attempts to create it.
%
%   This function converts both ASCII and binary STL files.
%   The resulting files are VRML97 compliant, UTF-8 encoded text files.
%
%   Notes:
%      You can use the created assembly files as templates for creating 
%      virtual scenes in which you can work with objects of the converted
%      assemblies. Usually, it is necessary to add lights, viewpoints,
%      surrounding objects, modify part materials, define navigation 
%      speeds, etc. in order to work with the scene effectively further.
%
%      Individual STL files are converted according to the STL convention 
%      - parts are placed in the global coordinate system.
%      When Physical Modeling XML file is specified as an input argument, 
%      resulting VRML assembly file reflects the initial positions of parts
%      defined in the XML file. 
%
%   Recommendation for SolidWorks users:
%      Do not use white characters when naming assemblies and components. 
%      This rule ensures that the assembly VRML file has the same tree 
%      structure as the related source in SolidWorks. Assembly VRML file 
%      can be then processed by VRPHYSMOD function to obtain Simulink model
%      with VRML visualization.
%
%   See also VRCADCLEANUP, VRPHYSMOD.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/05/10 17:54:22 $ $Author: batserve $

% test number of input arguments
error(nargchk(1, 2, nargin, 'struct'));

if (nargin == 1)
  destination = pwd;
end

if ~ischar(source) || isempty(source)
  throwAsCaller(MException('VR:invalidinarg', 'Input argument must be a non-empty string.'));
end

% test for file existence
if ~exist(source, 'file')
  throwAsCaller(MException('VR:filenotexist', 'The file %s does not exist.', source));
end

% create the destination directory if it doesn't exist
if ~exist(destination, 'dir')
  try
    mkdir(destination);
  catch ME
    throwAsCaller(ME);
  end
end

%  process file with STL, XML and any other extension
[fpath, ~, ext] = fileparts(source); 
if strcmpi(ext, '.STL')
  
  try
    % convert STL file  
    convertToWRL(source, destination, []);
  catch ME
    throwAsCaller(ME);
  end  
  
elseif strcmpi(ext, '.XML')
 
  % dom document
  document = xmlread(source);
  root = document.getDocumentElement;
  if ~strcmp(char(root.getNodeName), 'PhysicalModelingXMLFile')
    % it is not valid SimMechanics XML file 
    throwAsCaller(MException('VR:xmlnotvalid', 'XML file ''%s'' is not a Physical Modeling XML File.', source)); 
  end

  sources = {};
  fullnames = {};  

  % default assembly file name
  rootname = 'main_assembly';
  % obtain assembly name
  childNodes = root.getChildNodes;
  for j=0:childNodes.getLength-1
    nodename = char(childNodes.item(j).getNodeName);  
    if strcmp(nodename, 'name') || strcmp(nodename, 'modelName')
      rootname = [strrep(char(childNodes.item(j).getTextContent), '"', ''), '_assembly'];
      break;
    end
  end

  % each body has one child element named 'geometryFileName'
  % this element contains the name of appropriate STL file (or is empty)
  stlGeomElements = root.getElementsByTagName('geometryFileName');
  for j=0:stlGeomElements.getLength-1
    stlfbarename = strrep(char(stlGeomElements.item(j).getTextContent), '"', '');
    % convert STL file to wrl file
    [fullname, stlfbarename] = convertToWRL([fpath filesep stlfbarename], destination, stlGeomElements.item(j));
    if ~isempty(fullname)
      fullnames{end+1} = fullname;  %#ok<AGROW>
      sources{end+1} = stlfbarename;  %#ok<AGROW>
    end
  end          

  % create main vrml file and populate it
  mainfname = fullfile(destination, [rootname, '.wrl']);
  mainw = vrworld('');
  % open empty world
  open(mainw);
  % save empty main file
  save(mainw, mainfname);
  % close the world, delete it and open it again (this way the world knows 
  % its file name and relative URLs of dynamically added Inlines work OK)
  close(mainw); 
  delete(mainw);  
  mainw = vrworld(mainfname);
  open(mainw); 
  
  % create hierarchic vrml tree and inline appropriate vrml files
  for i=1:numel(fullnames)
    % split stl name to vrml tree levels
    splitlevels = regexp(fullnames{i}, '\:\-\:|\:\:', 'split');
    % delete empty strings
    ind = ~strcmp(splitlevels, '');
    splitlevels = splitlevels(ind);
    % parent node of newly created node
    parent = [];
    % create vrml tree path
    for j=1:numel(splitlevels)
      splitlevels{j} = strrep(splitlevels{j}, ' ', '-');
      if ~vrsfunc('VRT3NodeExists', get(mainw, 'Id'), splitlevels{j})
        % node does not exist, create it
        if j == numel(splitlevels)
          
          % create parental transform for resulting Inline  
          if isempty(parent)
            transform = vrnode(mainw, splitlevels{j}, 'Transform');
          else
            transform = vrnode(parent, 'children', splitlevels{j}, 'Transform');
          end
          
          % last level -- inline existing wrl file
          inline = vrnode(transform, 'children', [splitlevels{j}, '_Inline'], 'Inline');
          
          % set url to Inline node
          [~, inlineUrl, ~] = fileparts(sources{i});
          % url target is wrl file with the same name as the STL file
          setfield(inline, 'url', [inlineUrl, '.wrl']);  %#ok<STFLD,SFLD>
        else
           % it is tree path level
           if isempty(parent)
             parent = vrnode(mainw, splitlevels{j}, 'Transform');
           else
             parent = vrnode(parent, 'children', splitlevels{j}, 'Transform');
           end
        end
      else
        % node exists
        if ~strcmp(get(vrnode(mainw, splitlevels{j}), 'Type'), 'Transform')
          % there can be only one inline node of the given name
          close(mainw); delete(mainw);
          throwAsCaller(MException('VR:multiplenodes', ...
            'Inline node ''%s'' already exists. Multiple nodes with identical names not allowed.', splitlevels{j}));
        end
        % remember it as parent
        parent = vrnode(mainw, splitlevels{j});
      end
    end
  end

  % save main file
  save(mainw, mainfname);
  close(mainw); delete(mainw);
  return;
  
  % end % XML processing
  
else
  
  throwAsCaller(MException('VR:invalidinarg', 'Input argument must be a XML or STL file.'));
  
end

end % stl2vrml


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fullname, source] = convertToWRL(source, destination, fileNameNode)

[fpath, barename, ~] = fileparts(source);

% SimMechanics Link generated geometries need to be transformed
transformIt = true;
if isempty(barename)
  % it is not SimMechanics Link but CAD Translator XML file (older version)
  % geometryFileName attribute is empty
  transformIt = false;
    
  % try to obtain stl file name from xml tree structure  
  walkNode = fileNameNode;
  while ~strcmp(char(walkNode.getNodeName), 'PhysicalModelingXMLFile')
    walkNode = walkNode.getParentNode();
    walkNodeName = char(walkNode.getNodeName);
    if strcmp(walkNodeName, 'Body') || strcmp(walkNodeName, 'Subsystem') || ...
         strcmp(walkNodeName, 'SimMechanics')
      childNodes = walkNode.getChildNodes;
      for i=0:childNodes.getLength-1
        if strcmp(char(childNodes.item(i).getNodeName), 'name')
          prepstr = strrep(char(childNodes.item(i).getTextContent), '"', '');
          if strcmp(prepstr, 'RootPart')
            % root part doesn't contain name of STL file  
            fullname = '';
            return;
          end
          if isempty(barename)
            barename = prepstr;
          else
            barename = [prepstr, ' ', barename]; %#ok<AGROW>
          end  
          break;
        end
      end
    end
  end  
  blankIndex = strfind(barename, ' ');
  if ~isempty(blankIndex)
    % replace first blank  
    barename = [barename(1:blankIndex(1)-1), ' - ', barename(blankIndex(1)+1:end)];
  end
  % full file name
  source = fullfile(fpath, [barename, '.STL']);
end

% try to open file
fid = fopen(source, 'r', 'ieee-le');
if fid == -1
  throwAsCaller(MException('VR:stlopen', sprintf('Could not open ''%s'' STL file.', strrep(source, '\', '\\'))));     
end

% decide which file format it is
stl = fread(fid, 1000, '*char')';

% replace CR and LF with space
stl(stl==char(10) | stl==char(13)) = ' ';  

% decide STL file format
ascii = false;
if numel(strfind(stl, 'facet')) && numel(strfind(stl, 'endfacet'))
  ascii = true;
end

% rewind file
frewind(fid);  

% it is an ASCII file  
if ascii   
  % read file to string
  stl = fread(fid, Inf, '*char')';  

  % close STL file
  fclose(fid);       

  % replace CR and LF with space
  stl(stl==char(10) | stl==char(13)) = ' ';

  solid = strfind(stl, 'solid');
  facet = strfind(stl, 'facet');
  endsolid = strfind(stl, 'endsolid');

  if isempty(solid) || isempty(facet) || isempty(endsolid)
    throwAsCaller(MException('VR:invalidstl', sprintf('Invalid ''%s'' STL file.', source)));  
  end    
  
  fullname = '';
  if solid(1)+6 <= facet(1)
    fullname = strtrim(stl(solid(1)+6:facet(1)-1));
  end
  
  % scan the file to get the array of facet and vertex values
  [face_data, position] = textscan(stl(facet(1):endsolid(1)), 'facet normal %f%f%f outer loop vertex %f%f%f vertex %f%f%f vertex %f%f%f endloop endfacet', 'CollectOutput', true);
  if position+facet(1) ~= endsolid(1)
    warning('VR:stlread', 'Could not reach end of ''%s'' STL file, result can be incomplete.', source);
  end
  face_data = face_data{:}';
  [~, face_count] = size(face_data);

% it is binary file  
else    
  % read header
  header = strtrim(fread(fid, 80, '*char')');  

  ind = strfind(header, 'solid');
  if isempty(ind)
      ind=1;
  else
      ind = ind + 5;
  end

  % get solid name
  fullname = strtrim(header(ind:end));

  % faces count
  face_count = fread(fid, 1, 'uint32');
  try  
    face_data = fread(fid, 12*face_count, '12*float32', 2)';
  catch ME
    fclose(fid);  
    throwAsCaller(MException('VR:invalidstl', sprintf('Invalid ''%s'' STL file.', source)));    
  end
  face_data = reshape(face_data, 12, []);
  
  % close STL file
  fclose(fid);    
end


% create vrml file and fill it with data
ind = strfind(barename, '.');
if isempty(ind)
  wrlfname = [barename, '.wrl'];
else
  wrlfname = [barename(1:ind(end)-1), '.wrl'];
end

% create empty vrworld
w = vrworld('');
open(w);

materialProps = [];
% obtain tree structure and color from XML file
if ~isempty(fileNameNode)
  fullname = '';
  walkNode = fileNameNode;
  while ~strcmp(char(walkNode.getNodeName), 'PhysicalModelingXMLFile')
    walkNode = walkNode.getParentNode();
    walkNodeName = char(walkNode.getNodeName);
    if strcmp(walkNodeName, 'Body') || strcmp(walkNodeName, 'Subsystem') || ...
         strcmp(walkNodeName, 'SimMechanics')
      childNodes = walkNode.getChildNodes;
      for i=0:childNodes.getLength-1
        if strcmp(char(childNodes.item(i).getNodeName), 'name')
          prepstr = strrep(char(childNodes.item(i).getTextContent), '"', '');
          if isempty(fullname)
            fullname = prepstr;
          else  
            fullname = [prepstr, '::', fullname]; %#ok<AGROW>
          end  
          break;
        end
      end
    end
  end
  % obtain color
  walkNode = fileNameNode.getParentNode.getFirstChild;
  while ~isempty(walkNode)
    if strcmp(char(walkNode.getNodeName), 'MaterialProp')             
      attribs = walkNode.getChildNodes;
      for i=0:attribs.getLength-1
        node = attribs.item(i);  
        if node.getNodeType == org.w3c.dom.Node.ELEMENT_NODE
          materialProps.(char(node.getNodeName)) = str2num(char(node.getTextContent)); %#ok<ST2NM>
        end
      end
      break;
    end
    walkNode = walkNode.getNextSibling;
  end
end

% name in STL file can be empty 
% and there cannot be empty name of IndexedFaceSet node
if isempty(fullname) 
  [~, fullname] = fileparts(source);
end

% prepare fullname 
if isempty(fileNameNode)
  % SolidWorks root-component separator ' - '  
  fullname = regexprep(fullname, '\s+\-\s+', '::');
  % SolidWorks part separator is a blank character
  % but blanks can be in part names, too - so the result can be
  % abmiguous - see the note in the help text 
  fullname = strrep(fullname, ' ', '::');
end

% name must be a valid VRML name
name = strrep(fullname, '::', '__');
name = strrep(name, ' ', '-');

translation = [0 0 0];
rotation = [0 0 1 0];
% try to obtain translation and rotation of object in World coordinates
if ~isempty(fileNameNode)
  walkNode = fileNameNode.getParentNode.getFirstChild;
  while ~isempty(walkNode)
    if strcmp(char(walkNode.getNodeName), 'frames')             
      frames = walkNode.getChildNodes;    
      for i=0:frames.getLength-1
        frame = frames.item(i);  
        if frame.getNodeType == org.w3c.dom.Node.ELEMENT_NODE && ...
             strcmp(char(frame.getElementsByTagName('name').item(0).getTextContent), '"CS1"')
          tagNames = {'positionOrigin', 'positionReferenceFrame', 'orientationReferenceFrame', ...
                      'positionUnits', 'orientationType', 'orientationUnits'}; 
          tagValues = {'"WORLD"', '"WORLD"', '"WORLD"', '"m"', '"3x3 Transform"', '"rad"'};        
          prereqsOK = true;
          for j=1:numel(tagNames)
            if ~strcmp(char(frame.getElementsByTagName(tagNames{j}).item(0).getTextContent), tagValues{j}); 
              warning('VR:stlnoposrot', ['Could not translate and rotate geometry based on ''%s'' STL file,', ...
                      'resulting object can be rendered incorrectly.'], source);
              prereqsOK = false;
              break;
            end
          end
          if prereqsOK
            translation = str2num(strrep(char(frame.getElementsByTagName('position').item(0).getTextContent),'"','')); %#ok<ST2NM>
            rotation = vrrotmat2vec(reshape(str2num(strrep(char(frame.getElementsByTagName('orientation').item(0).getTextContent),'"','')), 3, [])); %#ok<ST2NM>
          end
          break;  
        end
      end      
      break;
    end
    walkNode = walkNode.getNextSibling;
  end
end

wrapper = w;
if any(translation ~= [0 0 0]) || any(rotation ~= [0 0 1 0])
  % Wrapping transform which translates and rotates child shape
  wrapper = vrnode(w, [name, '_Wrapper'], 'Transform');
  
  % geometries are not rotated and translated -- do it 
  if transformIt
    setfield(wrapper, 'rotation', rotation); %#ok<SFLD,STFLD>
    setfield(wrapper, 'translation', translation) %#ok<STFLD,SFLD>
  end
end

ifsparent = w;
if (any(translation ~= [0 0 0]) || any(rotation ~= [0 0 1 0])) || ~isempty(materialProps)
  % add shape
  if isa(wrapper, 'vrworld')
    shape = vrnode(wrapper, [name, '_Shape'], 'Shape');  
  else
    shape = vrnode(wrapper, 'children', [name, '_Shape'], 'Shape');
  end
  ifsparent = shape;
  
  appearance = vrnode(shape, 'appearance', '', 'Appearance');
  material = vrnode(appearance, 'material', [name, '_Material'], 'Material');  
  if ~isempty(materialProps) 
    % add information about material
    setfield(material, 'ambientIntensity', materialProps.ambient, ...
                       'diffuseColor', materialProps.color * materialProps.diffuse, ...
                       'emissiveColor', materialProps.color * materialProps.emission, ...
                       'shininess', materialProps.shininess, ...
                       'specularColor', materialProps.color * materialProps.specular, ...
                       'transparency', materialProps.transparency); %#ok<STFLD>
  else
    % add information about VRML default material  
    setfield(material, 'ambientIntensity', 0.2, ...
                       'diffuseColor', [0.8 0.8 0.8], ...
                       'emissiveColor', [0 0 0], ...
                       'shininess', 0.2, ...
                       'specularColor', [0 0 0], ...
                       'transparency', 0); %#ok<STFLD>  
  end  
end

% add geometry
if isa(ifsparent, 'vrworld')
  ifs = vrnode(ifsparent, name, 'IndexedFaceSet'); 
else
  ifs = vrnode(ifsparent, 'geometry', name, 'IndexedFaceSet');  
end  

% normal per face
setfield(ifs, 'normalPerVertex', false); %#ok<STFLD,SFLD>

% add geometry attributes  
normal = vrnode(ifs, 'normal', [name, '_Normal'], 'Normal');
coord = vrnode(ifs, 'coord', [name '_Coordinate'], 'Coordinate');

setfield(normal, 'vector', face_data(1:3,:)'); %#ok<STFLD,SFLD>
setfield(coord, 'point',  reshape(face_data(4:12,:),3,[])'); %#ok<STFLD,SFLD>

coordIndex = zeros(1,face_count*4);
for i=1:face_count
  coordIndex(1, 4*(i-1)+1:4*(i-1)+4) = [3*(i-1), 1+3*(i-1), 2+3*(i-1), -1];   
end
setfield(ifs, 'coordIndex', int32(coordIndex')); %#ok<STFLD,SFLD>

try
  save(w, fullfile(destination, wrlfname));  
  close(w); delete(w);
catch ME
  close(w); delete(w);
  throwAsCaller(ME);    
end

end % convertToWRL



