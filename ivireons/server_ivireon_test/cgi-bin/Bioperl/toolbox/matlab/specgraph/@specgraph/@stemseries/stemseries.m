function h = stemseries(varargin)
%STEMSERIES stemseries constructor
%  H = STEMSERIES(PARAM1, VALUE1, PARAM2, VALUE2, ...) creates
%  a stemseries in the current axes with given param-value pairs.
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
h = specgraph.stemseries('parent',parent);
h.initialized = 1;

hMarker= line('hittest','off',...
	  'parent',double(h),'marker','o','linestyle','none');
set(h,'MarkerHandle',hMarker);

hStem = line('hittest','off',...
	  'parent',double(h));
  set(h,'StemHandle',hStem);

hasbehavior(hMarker,'legend',false);

% find existing baseline, if any
dbaseline = getappdata(parent,'SeriesBaseLine');
baseline = handle(dbaseline);
if isempty(dbaseline) || ~ishandle(dbaseline)
    % create a baseline if necessary
    hasZData = any(strcmpi(args,'ZData'));
    hasYData = any(strcmpi(args,'YData'));
    if hasYData && ~hasZData
        baseline = specgraph.baseline('parent',double(parent));
        dbaseline = double(baseline);
        setappdata(parent,'SeriesBaseLine',dbaseline);
    end
else
  baseline = handle(dbaseline);
end

% add baseline listeners
if ~isempty(baseline) && ishandle(baseline)
   h.baseline = double(baseline);
   l1 = handle.listener(baseline,...
                     baseline.findprop('BaseValue'),...
                     'PropertyPostSet',{@LdoBaseLineChanged,h});
   l2 = handle.listener(baseline,...
                     baseline.findprop('Visible'),...
                     'PropertyPostSet',{@LdoBaseLineChanged,h});
   l3 = handle.listener(h,...
                        h.findprop('Visible'),...
                        'PropertyPostSet',{@LdoVisibleChanged,h});
   h.baselineListener = [l1 l2 l3];
   h.basevalue = get(baseline,'BaseValue');
end

setappdata(double(h),'LegendLegendInfo',[]);
% Allow the series to participate in legends:
hA = get(double(h),'Annotation');
hA.LegendInformation.IconDisplayStyle = 'On';

if ~isempty(args)
  set(h,args{:})
end

hlist = handle.listener(h,'ObjectBeingDestroyed',@LdestroyBaseLine);
setappdata(double(h),'StemDestroyedListener',hlist);

% Call the create function:
hgfeval(h.CreateFcn,double(h),[]);

function LdoBaseLineChanged(hSrc, eventData, h)
baseline = eventData.affectedObject;
set(h,'BaseValue',get(baseline,'BaseValue'));
set(h,'ShowBaseLine',get(baseline,'Visible'));

function LdoVisibleChanged(hSrc, eventData, h)
h = eventData.affectedObject;
baseline = h.BaseLine;
if ishandle(baseline) && isa(handle(baseline),'specgraph.baseline')
  parent = handle(get(h,'Parent'));
  if strcmp(get(parent,'BeingDeleted'),'off')
    peers = find(parent,'BaseLine',baseline);
    vis = 'off';
    for k=1:length(peers)
      if strcmp(get(peers(k),'Visible'),'on')
        vis = 'on';
        break;
      end
    end
    set(baseline,'Visible',vis)
  end
end

function LdestroyBaseLine(hSrc, eventData)
if ishandle(hSrc)
  parent = handle(get(hSrc,'Parent'));
  if strcmp(get(parent,'BeingDeleted'),'off')
    baseline = hSrc.BaseLine;
    if ishandle(baseline) && isa(handle(baseline),'specgraph.baseline')
      peers = find(parent,'BaseLine',baseline);
      if isequal(peers,hSrc)
        delete(baseline);
      end
    end
  end
end