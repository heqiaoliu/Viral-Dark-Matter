function save(world, filename, export)
%SAVE Save the virtual world to a VRML file.
%   SAVE(WORLD, FILENAME) saves the virtual world referred to
%   by VRWORLD handle W to the VRML file FILENAME.
%
%   The resulting file is a VRML97 compliant, UTF-8 encoded text file.
%   Lines are indented using spaces. Line ends are encoded as CR-LF
%   or LF according to the local system default. Values are separated
%   by spaces.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/04/15 15:51:24 $ $Author: batserve $


% use this overloaded SAVE only if the first argument is of type VRWORLD
if ~isa(world, 'vrworld')
  builtin('save',world,filename);
  return;
end

if nargin<2
  warning('VR:obsoletesave', ...
         ['The form "save(world)" is now obsolete and performs no action for security reasons.\n', ...
          'To get equivalent functionality, please use "save(world,get(world,''FileName''))" instead.']);
  return;
end

if nargin<3
  export = false;
end

% check arguments
if ischar(filename)
  filename = {filename};
elseif ~iscellstr(filename)
  error('VR:invalidinarg', 'File name must be a string or a cell array of strings.');
end
if numel(world) ~= numel(filename)
  error('VR:invalidinarg', 'There must be a file name for each world.');
end

% save all the worlds in a loop
for i = 1:numel(world)
  vrsfunc('SaveScene', get(world, 'Id'), filename{i}, export);
end
