function w = vrworld(filename, createmode)
%VRWORLD Create a virtual world.
%   W = VRWORLD(FILENAME) creates a virtual world associated with VRML file
%   FILENAME and returns its handle. If the virtual world already exists a
%   handle to the existing virtual world is returned.
%
%   W = VRWORLD(FILENAME, 'reuse') has the same functionality 
%   as W = VRWORLD(FILENAME).
%
%   W = VRWORLD(FILENAME, 'new') creates a virtual world associated with
%   VRML file FILENAME and returns its handle. A new virtual world object
%   is always created, regardless if a world associated with the same
%   VRML file already exists or not.
%
%   W = VRWORLD('') creates an empty VRWORLD which is not associated 
%   with any VRML file.
%
%   W = VRWORLD creates an invalid VRWORLD handle.
%
%   W = VRWORLD([]) returns an empty array of VRWORLD handles.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2010/05/10 17:54:40 $ $Author: batserve $

% create an invalid VRWORLD if no arguments
if nargin==0
  This = struct('id', 0);
  w = class(This, 'vrworld');
  return;
end

% return VRWORLD 0x0 array for VRWORLD([])
if isempty(filename) && isa(filename, 'double')
  This = struct('id', {});
  w = class(This, 'vrworld');
  return;
end

% validate input arguments
if nargin<2
  createmode = 'reuse';
end

if ~ischar(createmode)
  throwAsCaller(MException('VR:invalidinarg', 'CREATEMODE must be a string.'));
end

createmode = lower(createmode);
if ~any(strcmp(createmode, {'reuse', 'new', 'edit'}))
  throwAsCaller(MException('VR:invalidinarg', 'Value for CREATEMODE must be ''new'' or ''reuse''.'));
end 

% argument is a number: return a VRWORLD representing that scene number
if isa(filename, 'double')
  This = struct('id', num2cell(filename));
  w = class(This, 'vrworld');
  return;
end

if ~ischar(filename)
  throwAsCaller(MException('VR:invalidinarg', 'FILENAME must be a string.'));
end

if ~isempty(filename) 
  % add '.wrl' extension if no extension
  [p,n,e] = fileparts(filename);
  if isempty(e)
    filename = fullfile(p, [n '.wrl']);
  end
end

% try finding the file on MATLABPATH, consider the path absolute if not found
foundname = which(filename);
if isempty(foundname)
  foundname = filename;
end

% load it or use previously loaded version
[previd, editFlag] = vrsfunc('VRT3SceneByFilename', foundname);
if editFlag && strcmp(createmode, 'reuse')
  createmode = 'new';
end
if previd~=0 && ~strcmp(createmode, 'new') && ~strcmp(createmode, 'edit')
  This.id = previd;
else 
  This.id = vrsfunc('VRT3LoadScene', foundname, strcmp(createmode, 'edit'));
end
w = class(This, 'vrworld');

% set world defaults only for newly created world
if previd==0
  % read preferences that start with 'DefaultWorld'
  prefs = vrgetpref;
  prefnames = fieldnames(prefs);
  prefs = struct2cell(prefs);
  prefidx = strncmp(prefnames, 'DefaultWorld', 12);
  prefnames = prefnames(prefidx);
  prefs = prefs(prefidx);

  if strcmp(createmode, 'edit')
    % do not allow time events (set always TimeSource to external)
    prefs{strcmp(prefnames, 'DefaultWorldTimeSource')} = 'external';
  end

  % remove the 'DefaultWorld' string from the preference name
  for i=1:numel(prefnames)
    prefnames{i} = prefnames{i}(13:end);
  end

  % set world defaults
  set(w, prefnames, prefs');
end
