function h = errorbarseries(varargin)
%ERRORBARSERIES errorbarseries constructor
%  H = ERRORBARSERIES(PARAM1, VALUE1, PARAM2, VALUE2, ...) creates
%  a errorbarseries in the current axes with given param-value pairs.
%  This function is an internal helper function for Handle Graphics
%  and shouldn't be called directly.
  
%   Copyright 1984-2008 The MathWorks, Inc. 

args = varargin;
args(1:2:end) = lower(args(1:2:end));
parentind = find(strcmp(args,'parent'));
if isempty(parentind)
  parent = gca;
else
  parent = args{parentind(end)+1}; % take last parent specified
  args(unique([parentind parentind+1]))=[];
end
h = specgraph.errorbarseries('parent',parent);

% Add a listener to the "XScale" property of the parent:
hParent = handle(parent);
hList = handle.listener(hParent,findprop(hParent,'XScale'),'PropertyPostSet',...
    {@localMarkDirty,h});
h.ParentListener = hList;

h.initialized = 1;
l1 = line('hittest','off',...
	  'parent',double(h));
l2 = line('hittest','off',...
	  'parent',double(h));
hasbehavior(l1,'legend',false);
setappdata(double(h),'LegendLegendInfo',[])
% Allow the series to participate in legends:
hA = get(double(h),'Annotation');
hA.LegendInformation.IconDisplayStyle = 'On';
if ~isempty(args)
  set(h,args{:})
end

% Call the create function:
hgfeval(h.CreateFcn,double(h),[]);

%-------------------------------------------------------------------%
function localMarkDirty(obj,evd,h) %#ok<INUSL>
% Force a refresh of the series
h.dirty = 'invalid';