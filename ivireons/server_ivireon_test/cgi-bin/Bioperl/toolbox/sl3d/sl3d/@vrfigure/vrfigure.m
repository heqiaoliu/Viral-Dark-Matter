function f = vrfigure(world, position, videopreview)
%VRFIGURE Create a new virtual reality figure.
%   F = VRFIGURE(WORLD) creates a new virtual reality figure
%   showing the specified world and returns an appropriate
%   VRFIGURE object.
%
%   F = VRFIGURE(WORLD, POSITION) creates a new virtual reality
%   figure at the specified position.
%
%   F = VRFIGURE returns an empty VRFIGURE object which does not
%   have a visual representation.
%
%   F = VRFIGURE([]) returns an empty vector of type VRFIGURE.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2010/03/22 04:25:04 $ $Author: batserve $

% create an invalid VRFIGURE
if nargin==0
  f = struct('handle', 0, 'figure', 0);
  f = class(f, 'vrfigure');
  return;
end

% return VRFIGURE 0x0 array for VRFIGURE([])
if isempty(world)
  f = struct('handle', {}, 'figure', {});
  f = class(f, 'vrfigure');
  return;
end
        
% for internal use: create a VRFIGURE object referencing existing figures
if isa(world, 'double')

  % use the supplied handle
  f = struct('handle', num2cell(world), 'figure', 0);
    
  % add the class information
  f = class(f, 'vrfigure');
  return;
end

% for internal use: create a VRFIGURE object referencing existing vr.figure
if isa(world, 'vr.figure')
  % use the supplied vr.figure
  f = struct('handle', 0, 'figure', num2cell(world));
    
  % add the class information
  f = class(f, 'vrfigure');
  return;
end
    
% now the argument must be a VRWORLD
if ~isa(world, 'vrworld')
  error('VR:invalidinarg', 'Argument must be of type VRWORLD.');
end

% handle position
if nargin>1
  if iscell(position)
    if numel(position) ~= numel(world)
      error('VR:invalidinarg', 'Cell array of positions must have the same length as array of worlds.');
    end
    pos = position;
  else
    pos(1:numel(world)) = {position};
  end
else
  pos(1:numel(world)) = {vrgetpref('DefaultFigurePosition')};
end

% initialize variables
f = struct('handle', cell(1,numel(world)), 'figure', cell(1,numel(world)));
f = class(f, 'vrfigure');

if nargin<3
  videopreview = 0;
end

% "internalv5" is the default viewer
if vr.figure.isDefaultViewer
   % loop through worlds
  for i=1:numel(world)
    f(i).figure = vr.figure(world(i), 'Position', pos{i}, 'Videopreview', videopreview);  
    f(i).handle = 0;  
  end

% "internalv4" is the default viewer
else
  % preload OpenGL library
  vr.canvas.preloadOpenGL(false);
  
  % loop through worlds
  for i=1:numel(world)

    % warn about contexts not shared on Macintosh
    worldid = get(world(i), 'id');
    [~, figs5] = vrsfunc('VRT3ListViews', worldid);
    if ~isempty(figs5)
      throwAsCaller(MException('VR:contextsharing', ...
              ['Due to renderer limitations, VRFIGURE objects cannot be created ', ...
               'when the DefaultViewer preference is set to ''internalv4'' and a VR.CANVAS object ', ...
               'already exists for the same virtual world. It is necessary to set the DefaultViewer ', ...
               'preference to ''internal'' if coexistence of VR.CANVAS and VRFIGURE objects is required.'] ));
    end

    % create the figure
    f(i).handle = vrsfunc('VRT3ViewScene', worldid, pos{i}, videopreview);
    f(i).figure = 0;

    % set figure description and position - the position is being set again because of X11
    set(f(i), 'Name', get(world(i), 'Description'), 'Position', pos{i});  % title is the world description

    % set default properties from preferences
    vr.figure.setDefaultProperties(f(i));
  end
end
