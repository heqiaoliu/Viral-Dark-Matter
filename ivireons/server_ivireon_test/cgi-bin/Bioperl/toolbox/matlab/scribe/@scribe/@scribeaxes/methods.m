function val = methods(this,fcn,varargin)
% METHODS - methods for scribe axes class

%   Copyright 1984-2006 The MathWorks, Inc. 

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    val = get(m,'Name');
    return;
end

args = {fcn,this,varargin{:}};
if nargout == 0
  feval(args{:});
else
  val = feval(args{:});
end

%--------------------------------------------------------------------%
function stackScribeLayers(h,evdata)

stackScribeLayersWithChild(h,double(get(evdata,'Child')),false);

%--------------------------------------------------------------------%
function stackScribeLayersWithChild(h,child,force)

fig = ancestor(h,'figure');

% send underlay to bottom (last child) 
% and overlay to top (first child)
% handle when one or both don't exist

if strcmp(get(child,'Tag'),'scribeUnderlay')
  su = child;
else
  su=getappdata(fig,'Scribe_ScribeUnderlay');
end

if strcmp(get(child,'Tag'),'scribeOverlay')
  so = child;
else
  so=getappdata(fig,'Scribe_ScribeOverlay');
end
ch = allchild(fig);
types = get(ch,'Type');
ch2 = ch(strcmp('axes',types) | strcmp('uipanel',types) | strcmp('uicontainers',types));

didChange = false;
if ~isempty(so) && ishandle(so) && ...
      (~isempty(get(so,'Children')) || force)
  soind = find(ch2 == so);
  if ~isempty(soind) && soind ~= 1
    soind = find(ch == so);
    ch(soind) = [];
    ch = [so;ch];
    didChange = true;
  end
end

if ~isempty(su) && ishandle(su) && ...
      (~isempty(get(su,'Children')) || force)
  suind = find(ch2 == su);
  if ~isempty(suind) && suind ~= length(ch)
    suind = find(ch == su);
    ch(suind) = [];
    ch = [ch;su];
    didChange = true;
  end
end

if didChange
  % since setting the children will fire the remove/add child
  % listeners lets turn those off during the set since they end up
  % deleting context menus and other children.
  scribefiglisten(fig,'off');
  set(fig,'children',ch);
  scribefiglisten(fig,'on');
end
