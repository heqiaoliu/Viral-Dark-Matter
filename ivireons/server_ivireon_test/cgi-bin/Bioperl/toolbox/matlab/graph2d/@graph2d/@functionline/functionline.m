function h = functionline(fun, varargin)
% FUNCTIONLINE Create a line from a function.
%    H = FUNCTIONLINE(FUN) creates a line based on the function FUN. FUN
%    accepts vector input X and returns a vector output that is FUN evaluated
%    at X.
%
%    H = FUNCTIONLINE(FUN,'-userargs',{P1,P2,...}) will pass the user 
%    arguments P1, P2,... as a comma separated list to FUN, e.g.
%    feval(FUN,X,P1,P2,...).
%
%    H = FUNCTIONLINE(FUN,'-userargs',{P1,P2,...},PROP1,VALUE1,PROP2,VALUE2,...)
%    will create a line with properties set to the given values, e.g. 'color', 'b'.

% Note: unlike constantline, we only allow y as the dependent variable because
%    if both types of functionlines, y=f(x) and x=f(y) were plotted in one figure, 
%    the listeners on the limits could go into an infinite loop of updating.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2005/06/21 19:29:20 $

pkg = findpackage('graph2d'); % get handle to graph2d package
hgpkg = findpackage('hg');    % get handle to hg package

if nargin < 2
   userargs = {};
end
if isequal(fun, 'parent')
   % This condition should only happen when we are being
   % called by the FIG-file loader which always passes
   % our constructor ('parent', parent) arguments.
   fun = '';
   curraxes = varargin{1};
   varargin = {};
   userargs = {};
   loadFromFig = 1;
else
   loadFromFig = 0;
   if ~isempty(varargin)
      if isequal(varargin{1},'-userargs')
         userargs = varargin{2};
         varargin(1:2) = [];
      else
         userargs = {};
      end
   end
   
   parent = find(strncmpi('parent',varargin,6));
   if ~isempty(parent)
      curraxes = varargin{parent+1};
   else
      curraxes = gca;
   end
end

% Construct the function line (curve) - calls the built-in constructor
if ~isempty(varargin)
   h = graph2d.functionline('xdata',[],'ydata',[],varargin{:});
else
   h = graph2d.functionline('xdata',[],'ydata',[]);
end

% Initialize
h.function = fun;       % Function to be evaluated
h.userargs = userargs;  % Cell array of user args

% Install a listener for the axes limits
axesC = hgpkg.findclass('axes');
xlimP = axesC.findprop('xlim');
h.listenerAxes = handle.listener(get(h,'parent'), xlimP, 'PropertyPostSet', {@localUpdateLine, h});

fline = findclass(pkg,'functionline');
hprop = findprop(fline, 'UserArgs');
h.listenerUserArgs = handle.listener(h, hprop, 'PropertyPostSet', {@localUpdateLine, h});

hprop = findprop(fline, 'Granularity');
h.listenerGranularity = handle.listener(h, hprop, 'PropertyPostSet', {@localUpdateLine, h});

if loadFromFig
   % This means we are loading from a file.
   % We want to turn off all of our listeners until we have been
   % fully constructed.  The listeners are turned on in the
   % postdeserialize.m method. The update method will be called
   % in the postdeserialize method.
   h.listenerAxes.enable = 'off';
   h.listenerUserArgs.enable = 'off';
   h.listenerGranularity.enable = 'off';
else
  % Draw the line
  update(h);
end

%-----------------------------------------------------------
function localUpdateLine(src, eventData, hFline)
% LOCALUPDATELINE Callback to update functionline when axes limits change.

update(hFline);
