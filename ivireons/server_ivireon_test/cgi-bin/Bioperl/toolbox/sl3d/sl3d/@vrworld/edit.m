function edit(w)
%EDIT Edit the virtual world.
%   EDIT(W) opens VRML file associated with virtual world referenced by
%   the VRWORLD handle W in a VRML editor. The editor to use is chosen
%   based on the 'Editor' preference.
%
%   See also VRGETPREF, VRSETPREF.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2010/05/10 17:54:39 $ $Author: batserve $

% check arguments
if length(w)>1
  error('VR:invalidinarg', 'Argument cannot be an array.');
end

% get world file name
if ~isempty(w)
  wfile = get(w, 'FileName');
else
  wfile = '';
end

% get editor type or command line
cmdline = vrgetpref('Editor');
if ~ispc && strcmpi(cmdline, '*VREALM')  % handle V-Realm as built-in outside Windows
  cmdline = '*BUILTIN';
end

% form the correct action based on editor type
switch cmdline
  case {'', '*BUILTIN'}
    if isempty(which('vr.edit'))
      throwAsCaller(MException('VR:notpermittedindemo', ...
        'Built-in editor is not available in the demonstration version of Simulink 3D Animation.'));
    end
    editfn = @vr.edit;

  case '*MATLAB'
    editfn = @edit;

  case '*VREALM'
    if ~exist(fullfile(matlabroot, 'toolbox' ,'sl3d' ,'vrealm' ,'program' ,'vrbuild2.exe'), 'file')
      throwAsCaller(MException('VR:notpermittedindemo', ...
        'V-Realm Builder is not available in the demonstration version of Simulink 3D Animation.'));
    end
    cmdline = '%matlabroot\toolbox\sl3d\vrealm\program\vrbuild2.exe %file';
    editfn = [];

  otherwise
    editfn = [];
end

% call built-in editor
if ~isempty(editfn)
  if ~isempty(wfile)
    editfn(wfile);
  else
    editfn();
  end
  return;
end

% install the editor once per session to correctly handle different versions
persistent installed
if isempty(installed)
  if  ~vrinstall('-check', 'editor')
    evalc('vrinstall -install editor');
  end
  installed = true;
end

% on a PC, wrap the tokens containing spaces by double quotes
if ispc
  if any(isspace(matlabroot))
    cmdline = quotetoken(cmdline, '%matlabroot');
  end
  if any(isspace(wfile))
    cmdline = quotetoken(cmdline, '%file');
  end
end

% form the command line
cmdline = [strrep(strrep(cmdline, '%matlabroot', matlabroot), '%file', wfile) ' &'];

% go!
system(cmdline);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = quotetoken(cmdline, kword)
% Wraps a command-line token containing a keyword by double quotes

% read the individual space-separated tokens
toks = textscan(cmdline, '%s');
toks = toks{1};

% wrap the tokens by double quotes if it contains the keyword and is not wrapped yet
for i=1:length(toks)
  t = toks{i};
  if ~isempty(strfind(t, kword)) && (t(1)~='"' || t(end)~='"')
    toks{i} = ['"' t '"'];
  end
end

% concatenate the tokens back to single string
y = sprintf('%s ', toks{:});
y(end) = '';
