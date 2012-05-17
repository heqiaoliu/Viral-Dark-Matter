function env = vrclimex_init(phase)
%VRCLIMEX_INIT Simulink 3D Animation main module pre-initialization.
%   ENV = VRCLIMEX_INIT(PHASE) ensures that all prerequisities for loading
%   the Simulink 3D Animation main module are met. It returns an
%   environment structure to be used by the main module loader.
%
%   Not to be called directly.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/02/08 23:02:15 $ $Author: batserve $

% dispatch phases
env = feval(sprintf('phase%d', phase));



%%%%%%%%% PHASE 1
function env = phase1     %#ok<DEFNU> called by switchboard

% VR client main module path
env.vrclimex_path = which('vrclimex');

% unsupported if there's no vrclimex.dll 
if isempty(env.vrclimex_path)
  error('VR:unsupported', 'Simulink 3D Animation is not supported on this platform.');
end

% preload the OpenGL library; signal any error to vr.canvas
[msg, loaded] = evalc('feature(''OpenGLLoadStatus'',1)');
env.openglloaded = logical(loaded);
if ~env.openglloaded
  if isempty(msg)
    msg = 'Unknown error loading OpenGL.';
  end
  vr.canvas.preloadOpenGL([], msg);
end

% Orbisnap binary directory
vr_root = fileparts(fileparts(env.vrclimex_path));
env.orbisnap_dir = fullfile(vr_root, 'orbisnap', 'bin');
if ispc
  env.orbisnap_dir = fullfile(env.orbisnap_dir, computer('arch'));
end

% main page and resource directory
env.mainpage_dir = [fullfile(vr_root, 'mainpage') filesep];
env.resource_dir = [fullfile(vr_root, 'resource') filesep];

% preferences
env.preferences = vrgetpref;
env.preferences.Verbose = vrgetpref('Verbose');  % undocumented, normally not returned

% detect execution mode
env.isdeployed = isdeployed;
env.isinbat = (~isempty(which('qeinbat')) && qeinbat) || (~isempty(which('vrisinbat')) && vrisinbat);

% create a window to allow timers to initialize
% needed only for deployed application on Windows
if env.isdeployed && ispc
  fig = figure('Visible', 'off');
  drawnow;
  close(fig);
end



%%%%%%%%% PHASE 2
function env = phase2     %#ok<DEFNU> called by switchboard

% initialize Java classes that need native libraries
com.mathworks.toolbox.sl3d.vrcanvas.VRGLCanvas.loadNativeLibrary(which('vrclimex'));
env = [];
