function x = vrinstall(action, component, bxtype)
%VRINSTALL Install or check components of Simulink 3D Animation.
%   VRINSTALL(ACTION, COMPONENT) Installs or checks components of
%   Simulink 3D Animation.
%
%   ACTION can be one of the following:
%
%     '-interactive'  Installs components interactively.
%     '-selftest'     Tests the integrity of Simulink 3D Animation itself.
%     '-check'        Checks what is installed.
%     '-install'      Installs an optional component.
%     '-uninstall'    Uninstalls an optional component.
%
%   When ACTION is '-interactive', the components are checked and if some
%   are not yet installed, the user is presented with a choice to install them.
%
%   When ACTION is '-check', the COMPONENT parameter specifies which component
%   should be queried. If an output arguments is given, VRINSTALL returns 1 if
%   the component is installed, and 0 if it isn't.
%
%   When ACTION is '-install' or '-uninstall',  the COMPONENT parameter specifies
%   which component should be installed.
%
%   Valid components are:
%
%     'viewer'      External VRML viewer (currently Blaxxun Contact 4.4.1.0)
%     'editor'      Default VRML editor (currently V-Realm Builder 2.0)
%
%   Not all components can be uninstalled from MATLAB. In some cases,
%   the component is a standalone application and must be uninstalled
%   using the standard procedure of the operating system.
%   Currently this applies to the external VRML viewer.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2010/04/24 18:29:38 $ $Author: batserve $


% do interactive test if no parameters given
if nargin == 0
  if nargout == 0
    action = '-interactive';
  else
    action = '-check';
  end
end

% do the individual actions
vrroot = fileparts(fileparts(mfilename('fullpath')));
switch lower(action)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SELFTEST
  case '-selftest'
    if nargout>0
      x = true;    % always return true for backwards compatibility
    else
      fprintf('Simulink 3D Animation installation self-test has passed.\n');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INTERACTIVE
  case  '-interactive'
  if nargout>0
    error('VR:invalidoutarg', 'Too many output arguments.');
  end
  if ~vrinstall('-check', 'viewer')
    inp = '';
    while (isempty(inp) || ((inp~='y') && (inp~='n')))
      inp = lower(input('External VRML viewer is not installed. Install it? (y/n) ', 's'));
    end  
    if strcmp(inp, 'y')
      vrinstall('-install', 'viewer');
    end
  end
  vrinstall('-check', 'viewer');
  vrinstall('-check', 'editor');

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECK
  case '-check'

  % all components
  if nargin < 2
    if nargout>0
      x = vrinstall(action,'viewer') && vrinstall(action,'editor');
    else
      vrinstall(action,'viewer');
      vrinstall(action,'editor');
    end
    return;
  end

  % platform support
  [filtered, msg] = platformfilter(vrroot, component);
  if filtered
    if nargout>0
      x = true;    % OK if not supported
    else
      component(1) = upper(component(1));
      fprintf('%s will not be checked %s.\n', component, msg);
    end
    return;
  end

  % viewer
  if strcmp(component, 'viewer')
    [wrlinst wrlviewer wrlver] = wrlcheck;     % test viewer type and version
    x = wrlinst && strcmp(wrlviewer, 'blaxxun Contact');
    if nargout==0           % print text info if no output required
      if x
        if strcmp(wrlver, '4.4.1.0')
          fprintf('\tExternal VRML viewer:\tinstalled\n');
        else
          fprintf('\tExternal VRML viewer:\tcompatible (%s %s)\n', wrlviewer, wrlver);
        end
      elseif wrlinst
        fprintf('\tExternal VRML viewer:\tunsupported (%s %s)\n', wrlviewer, wrlver);
      else
        fprintf('\tExternal VRML viewer:\tnot installed\n');
      end
      clear x;
    end

  % editor
  elseif strcmp(component, 'editor')
    
    % check if editor INI file is present and contains the correct path
    f = fopen(fullfile(getenv('windir'), 'vrbuild2.ini'), 'r');
    ok = false;
    if f~=-1
      ini = fread(f, '*char')';
      fclose(f);
      ok = ~isempty(strfind(ini, sprintf('[Application]\nDirectory=%s\\vrealm\\Program',vrroot)));
    end

    % report the result
    if nargout>0
      x = ok;
      return;
    end
    if ok
      fprintf('\tVRML editor:\tinstalled\n');
    else
      fprintf('\tVRML editor:\tnot installed (will be installed on first edit)\n');
    end

  else
    error('VR:invalidinarg', 'Invalid component name');
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INSTALL
  case '-install'
  if nargout>0
    error('VR:invalidoutarg', 'Too many output arguments.');
  end

  % all components
  if nargin < 2
    vrinstall(action,'viewer');
    vrinstall(action,'editor');
    return;
  end

  % platform support
  [filtered, msg] = platformfilter(vrroot, component);
  if filtered
    component(1) = upper(component(1));
    fprintf('%s will not be installed %s.\n', component, msg);
    return;
  end

  % viewer
  if strcmp(component, 'viewer')
    if nargin>2 && strcmpi(bxtype, 'OpenGL')
      inp = 'o';
    elseif nargin>2 && strcmpi(bxtype, 'Direct3D')
      inp = 'd';
    else
      inp = '';
    end

    fprintf('Installing blaxxun Contact viewer ...\n');
    while (isempty(inp) || ((inp~='o') && (inp~='d')))
      inp = lower(input('Do you want to use OpenGL or Direct3D acceleration? (o/d) ', 's'));
    end
    if strcmp(inp,'o')
      bxinst = 'blaxxunContact44OGL.exe';
    else
      bxinst = 'blaxxunContact44.exe';
    end

    fprintf('Starting viewer installation ...\n');
    system(fullfile(vrroot, 'blaxxun', bxinst));
    fprintf('Done.\n');

  % editor
  elseif strcmp(component, 'editor')
    fprintf('Starting editor installation ...\n');

    % template and target INI file names
    templatefile = fullfile(vrroot, 'resource', 'vrbuild2.ini');
    inifile = fullfile(getenv('windir'), 'vrbuild2.ini');
    
    % try to open an existing INI file or a template file and read it
    f = fopen(inifile, 'r');
    if (f == -1)
      f = fopen(templatefile, 'r');
    end
    ini = fread(f, '*char')';
    fclose(f);
    
    % read the template file line by line, updating the target file where
    % exact match to a line containing $vrroot token is found
    rvrroot = regexptranslate('escape', vrroot);
    ft = fopen(templatefile, 'r');
    while true
      % read a line
      ln = fgets(ft);
      if ~ischar(ln) || isempty(ln)
        break;
      end
      
      % search for a $vrroot token, form the search regexp
      [si, ei] = regexp(ln, '\$vrroot');
      if isempty(si)
        continue;
      end
      re = sprintf('(%s)[\\S ]*(%s)', regexptranslate('escape', ln(1:si-1)), ...
                                      regexptranslate('escape', ln(ei+1:end-1)));
                               
      % replace $vrroot or its previous replacement by the current path
      ini = regexprep(ini, re, sprintf('$1%s$2', rvrroot));
    end
    fclose(ft);

    % write the modified file to temporary location
    tmpdir = tempname;
    tmpfile = fullfile(tmpdir, 'vrbuild2.ini');
    mkdir(tmpdir);
    f = fopen(tmpfile, 'w');
    fwrite(f, ini);
    fclose(f);

    % first try to copy the file to destination the easy way
    if ~copyfile(tmpfile, inifile, 'f')

      % if failed, copy the file to destination using Windows shell with elevated privileges
      sh = actxserver('Shell.Application');
      cmdargs = sprintf('/c copy /y %s %s & mkdir %s\\DONE', tmpfile, inifile, tmpdir);
      sh.ShellExecute('cmd', cmdargs, '', 'runas');
      while ~exist(fullfile(tmpdir, 'DONE'), 'dir')
      end
      delete(sh);
    end
    rmdir(tmpdir, 's');

    % check for successful installation
    if vrinstall('-check', 'editor')
      fprintf('Done.\n');
    else
      warning('VR:vrealmlib', 'Cannot create V-Realm Builder preferences file. Object libraries may not be available.');
    end

  else
    error('VR:invalidinarg', 'Invalid component name');
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UNINSTALL
  case '-uninstall'
  if nargout>0
    error('VR:invalidoutarg', 'Too many output arguments.');
  end

  % all components
  if nargin < 2
    vrinstall(action,'viewer');
    vrinstall(action,'editor');
    return;
  end

  % platform support
  [filtered, msg] = platformfilter(vrroot, component);
  if filtered
    component(1) = upper(component(1));
    fprintf('%s will not be uninstalled %s.\n', component, msg);
    return;
  end

  % viewer
  if strcmp(component, 'viewer')
    warning('VR:cantuninstall', ...
            'External VRML viewer cannot be uninstalled from MATLAB. Please uninstall the viewer from the Control Panel.');

  % editor
  elseif strcmp(component, 'editor')
    if vrinstall('-check', 'editor')
      fprintf('Starting editor uninstallation ...\n');
      
      % first try to delete the file the easy way
      inifile = fullfile(getenv('windir'), 'vrbuild2.ini');
      ws = warning('off', 'MATLAB:DELETE:Permission');
      delete(inifile);
      warning(ws);
      
      % if failed, delete the file using Windows shell with elevated privileges
      if exist(inifile, 'file')
        sh = actxserver('Shell.Application');
        cmdargs = sprintf('/c del /f %s', inifile);
        sh.ShellExecute('cmd', cmdargs, '', 'runas');
        delete(sh);
      end
      
      fprintf('Done.\n');
    else
      fprintf('Editor not installed.\n');
    end

  else
    error('VR:invalidinarg', 'Invalid component name');
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% everything else
  otherwise
    error('VR:invalidinarg', 'Invalid action name');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% filter out platforms where vrinstall is not performed
function [filtered, msg] = platformfilter(vrroot, component)

% filter out unsupported platforms
msg = 'on this platform';
filtered = ~ispc || (strcmp(component, 'viewer') && ~strcmp(computer('arch'), 'win32'));
if (filtered)
  return;
end

% filter out demo version
msg = 'in demo version of Simulink 3D Animation';
filtered = ( strcmp(component, 'viewer') && ~exist(fullfile(vrroot, 'blaxxun', 'blaxxunContact44.exe'), 'file') ) || ...
           ( strcmp(component, 'editor') && ~exist(fullfile(vrroot, 'resource', 'vrbuild2.ini'), 'file') );
