function [h, old_props] = hgloadStructDbl(hgS, fullpath, versionNum, DoAll, OverrideProps)
%hgloadStructDbl Convert a structure to double handles.
%
%  hgloadStructDbl converts a saved structure into a set of new handles.
%  This function is called when MATLAB is using double HG handles.

%  Copyright 2009 The MathWorks, Inc.


numHandles = numel(hgS);
if numHandles == 0
  warning('MATLAB:hgload:EmptyFigFile','Empty Figure file');
  if nargin > 0, h = []; end
  if nargin > 1, old_props = {}; end
  return;
end
parent = zeros(numHandles, 1);

% If we loaded only one top-level object, and it was a figure,
% add the FileName property to handle struct so that it is seen
% by the CreateFcns of figure and its children.
if (numHandles == 1) && strcmpi(hgS.type,'figure') 
    hgS.properties.FileName = fullpath; 
end

for i = 1:numHandles
    switch(hgS(i).type) 
    case 'root'
        parent = 0;
    case 'figure' 
        parent(i) = 0;
    case {'axes' 'uimenu' 'uicontextmenu' 'uicontrol' 'uitoolbar', 'scribe.legend'}
        parent(i) = gcf;
    case {'uipushtool' 'uitoggletool'}
        parent(i) = gctb;
    otherwise
        parent(i) = gca;
    end
end

flags = {'convert'};
if DoAll
    flags(2) = {'all'};
end

% Replace property values on all objects, and return any prior values
old_props = cell(size(hgS));
if ~isempty(OverrideProps) 
    new_prop_names = fieldnames(OverrideProps);
    for ih = 1:numHandles
        prev_vals = [];
        for inp = 1:length(new_prop_names)
            this_prop = new_prop_names{inp};
            if isfield(hgS(ih).properties,this_prop)
                prev_vals.(this_prop) = hgS(ih).properties.(this_prop);
            end
            hgS(ih).properties.(this_prop) = OverrideProps.(this_prop);
        end
        old_props{ih} = prev_vals;
    end
end


% Extract legends from pre V7 figures
SPossibleFigures = hgS;
IsRootLoad = (numel(hgS)==1 && strcmpi(hgS(1).type, 'root'));
if IsRootLoad
    % If the root has been saved we need to operate on the next level of
    % structure which will contain figures.
    SPossibleFigures = hgS(1).children;  
end

legs = cell(1,numel(SPossibleFigures));
if versionNum < 70000 
    for k=1:numel(SPossibleFigures)
        if strcmpi(SPossibleFigures(k).type,'figure')
            [SPossibleFigures(k),legs{k}] = convert_old_figure_struct(SPossibleFigures(k));
        end
    end
end

if IsRootLoad
    hgS(1).children = SPossibleFigures;
else
    hgS = SPossibleFigures;
end

% register graph2d.lineseries class with UDD
lineseries('init');

% This app data is used by scribe. It needs to be set on the currnt root
% and also injected into any saved root objects in order to make sure it
% persists during the load
setappdata(0,'BusyDeserializing',1);
hgS = arrayfun(@localInjectBusyDeserializing, hgS);

h = struct2handle(hgS, parent, flags{:});

if isappdata(0, 'BusyDeserializing');
    % This appdata can already have been removed by recursive loads.
    rmappdata(0,'BusyDeserializing');
end

% Loop through all handles and restore behavior objects.
% Ignore user interface widgets since they don't use behavior objects
findall(h, '-not',{'type','uimenu'},...
    '-and','-not',{'type','uitoggletool'},...
    '-and','-not',{'type','uipushtool'},...
    '-and','-not',{'type','uitoolbar'},...
    '-and','-not',{'type','uipanel'},...
    '-function',@localRestoreBehaviorObjects);

localDeserializeAnnotations(h);
                  
%If axes were linked before the save, relink them.
allAxes = findall(h,'Type','axes');
targets = cell(1,length(allAxes));
props = cell(1,length(allAxes));
maxGroup = 0;
for i = 1:length(allAxes)
    if isappdata(allAxes(i),'graphics_linkaxes_targets')
        num = getappdata(allAxes(i),'graphics_linkaxes_targets');
        targets{num} = [targets{num} allAxes(i)];
        if isempty(props{num})
            props{num} = getappdata(allAxes(i),'graphics_linkaxes_props');
        end
        rmappdata(allAxes(i),'graphics_linkaxes_targets');
        rmappdata(allAxes(i),'graphics_linkaxes_props');
        if num > maxGroup, maxGroup = num; end
    end
end
targets = targets(1:maxGroup);
props = props(1:maxGroup);
for i = 1:maxGroup
    linkaxes(targets{i},props{i});
end

% adjustments for figures
hFigures = findall(h, 'type', 'figure');
for i = 1:length(hFigures)
    figload_reset(hFigures(i));
end

if length(h)==numHandles && versionNum < 70000
    % Can only restore old legend data if all the handles loaded correctly,
    % otherwise we don't know which legend data applies to which handle
    
    if IsRootLoad
        % Get the newest children from the root
        hPossibleFigures = allchild(h);
        hPossibleFigures = hPossibleFigures(1:numel(legs));
    else
        hPossibleFigures = h;
    end
    
    for k=1:numel(hPossibleFigures)
        if strcmpi(get(hPossibleFigures(k),'type'),'figure') ...
                && ~isempty(legs{k}) && ~isempty(fieldnames(legs{k}))
            update_children(hPossibleFigures(k),legs{k});
        end
    end 
end

%---------------------------------------------------------------%
function [s,legs] = convert_old_figure_struct(s)

legs = struct;
nlegs = 0;
if ~isempty(s.children)
    % create 2 shortened lists of children
    % one not including legends 
    % and one not including legends or children with hvis off.
    newch = s.children(1); % not legend
    newch(1) = [];
    newch_hvis = s.children(1); % not legend or uimenu
    newch_hvis(1) = [];
    for k=1:length(s.children)
        % determine whether child is a legend
        if isfield(s.children(k).properties,'Tag') && ...
            strcmpi(s.children(k).properties.Tag,'legend') && ...
            any(strcmpi(s.children(k).type,{'graph2d.legend','scribe.legend'}))
            % add to list to be readded only if it has user data
            if isfield(s.children(k).properties,'UserData')
                nlegs = nlegs + 1;
                legs(nlegs).ud = s.children(k).properties.UserData;
            end
        else
            % if not a legend
            newch(end+1) = s.children(k);
            % get handle visibility
            hvis = 'on';
            if isfield(s.children(k).properties,'HandleVisibility')
                hvis = s.children(k).properties.HandleVisibility;
            end                
            if ~strcmpi(hvis,'off')
            % if not a legend and handle visibility is not off
                newch_hvis(end+1) = s.children(k);
            end
        end
    end
    s.children = newch;
    % from shortened list of children (no legends or hv off),
    % find child indices for assigning
    % plothandles when replacing legend
    % hvis off children are not included because get(children) on fig
    % created after struct2handle will not include them
    if nlegs>0
      oklegs = true(1,length(legs));
      for k = 1:length(legs)
        legs(k).phindex = 0;
        for m=1:length(newch_hvis)
          if isequal(newch_hvis(m).handle,legs(k).ud.PlotHandle)
            legs(k).phindex = m;
          end
        end
        if legs(k).phindex == 0
          warning('MATLAB:hgload:InvalidLegendPeer',...
                  [ 'Cannot determine which plot is associated with legend. ' ...
                    'Ignoring legend data.']);
          oklegs(k) = false;
        end
      end
      legs = legs(oklegs);
    end
end

%---------------------------------------------------------------%
function update_children(fig,legs)

% children are in backward order from struct list
ch = flipud(get(fig,'children'));
for k=1:length(legs)
    legs(k).ud.PlotHandle = ch(legs(k).phindex);
end
for k=1:length(legs)
    ud = legs(k).ud;
    lpos = ud.legendpos;
    lstr = ud.lstrings;
    pos = ud.LegendPosition;
    ax = ud.PlotHandle;
    leg=legend(ax,lstr,lpos);
    if ~isempty(pos) && pos(3)>0 && pos(4)>0
        set(leg,'position',pos);
    end
end

%---------------------------------------------------------------%
function tb = gctb

% find the first uitoolbar in the current figure, creating one if
% necessary

tb = findobj(gcf,'type','uitoolbar');
if ~isempty(tb)
    tb = tb(1);
else
    tb = uitoolbar;
end

%---------------------------------------------------------------%
function figload_reset(fig)
% fix some problems with loading figures 
% saved with scribe functions on
% and colorbar problems with figures saved in r11.
[ lmsg lid ] = lastwarn;
ws = warning('query','MATLAB:handle:hg2');
warning('off','MATLAB:handle:hg2')

l = double(find(handle(fig),'Tag','legend','-class','scribe.legend'));

warning(ws.state,ws.identifier)
lastwarn( lmsg, lid );

% make sure scribe mode, rotate3d and zoom are off
% for figures saved before r12.1
plotedit(fig,'off');
rotate3d(fig,'off');
zoom(fig,'off');

% clear out legend/colorbar and subplot data that can confuse
% deserialization
axlist = findall(fig,'Type','axes');
for k=1:length(axlist)
  ax = axlist(k);
  safeRemoveAppData(ax,'SubplotDeleteListener');
  safeRemoveAppData(ax,'SubplotInsets');
  parent = get(ax,'Parent');
  grid = getappdata(parent,'SubplotGrid');
  if ~isempty(grid) && any(grid(:) == ax)
      % got a subplot so call subplot to install listeners
      m = size(grid,1);
      n = size(grid,2);
      p = find(ax == reshape(flipud(grid)',1,m*n));
      % remove ax from grid to avoid early exit from subplot
      grid(grid == ax) = 0;
      setappdata(parent,'SubplotGrid',grid);
      % Since we only want to add listeners to the subplot, prevent the
      % subplot command from moving the axes.
      subplot(m,n,p,ax,'PreventMove');   
  end
  safeRemoveAppData(ax,'LegendColorbarLayoutDirty');
  safeRemoveAppData(ax,'inLayout');
  safeRemoveAppData(ax,'InSubplotLayout');
end

% run post deserialize method on any charting objects
axlist = localDataAxes(axlist);
for k=1:length(axlist)
  ax = axlist(k);
  chlist = findobj(ax);
  for j=1:length(chlist)
    try %#ok
        [ lmsg lid ] = lastwarn;
        ws = warning('query','MATLAB:handle:hg2');
        warning('off','MATLAB:handle:hg2')
        
        ch = handle(chlist(j));
        
        warning(ws.state,ws.identifier)
        lastwarn( lmsg, lid );
        
        if ismethod(ch,'postdeserialize')
            postdeserialize(ch);
        end
    end
  end
end

% if ScribeClearModeCallback is there, remove it
safeRemoveAppData(fig,'ScribeClearModeCallback');

% if there are any legends, reset them
% this is needed because patches set their cdata
% based on the cdata of the plot axes children
% which may not exist or have their correct cdata
% when a legend is generated by struct2handle
if ~isempty(l)
    for j=1:length(l)
        legend(l(j));
    end
end

% if there are any data children
% make the first one that is an axes the currentaxes
% otherwise last thing saved is currentaxes
dc=axlist;
if ~isempty(dc)
    foundaxes=0;
    j=1;
    while ~foundaxes && j<(length(dc)+1)
        if strcmpi(get(dc(j),'type'),'axes')
            set(fig,'currentaxes',dc(j));
            foundaxes=1;
        end
        j=j+1;
    end
end

% run postdeserialize on any other figure children.
% Currently this should include scribe layer,
% legend and colorbar
allChil = allchild(fig);
axlist = findall(fig,'Type','axes');
axlist = union(axlist,allChil);
for k=length(axlist):-1:1
  ax = axlist(k);
  if isappdata(ax,'PostDeserializeFcn')
    feval(getappdata(ax,'PostDeserializeFcn'),ax,'load')
  else
      [ lmsg lid ] = lastwarn;
      ws = warning('query','MATLAB:handle:hg2');
      warning('off','MATLAB:handle:hg2')

      if ismethod(handle(ax),'postdeserialize')
          try %#ok
              postdeserialize(handle(ax));
          end
      end
      warning(ws.state,ws.identifier)
      lastwarn( lmsg, lid );
  end
end

% Deserialize any datatips that were present in the figure
hDCM = datacursormode(fig);
hDCM.deserializeDatatips;

%---------------------------------------------------------------%
function axlist = localDataAxes(axlist)

nondatachild = logical([]);
for i=length(axlist):-1:1
  nondatachild(i) = isappdata(axlist(i),'NonDataObject');
end
axlist(nondatachild) = [];

%---------------------------------------------------------------%
function safeRemoveAppData(h,str)
if isappdata(h,str)
  rmappdata(h,str);
end

%---------------------------------------------------------------%
function localDeserializeAnnotations(h)
% Restore the annotation properties:
% Find all the objects that have an annotation property:
ret = findall(h,'-function',@(h)(isprop(handle(h),'Annotation')));

for i=1:numel(ret)
    if ~isappdata(ret(i),'SerializedAnnotationV7')
        continue;
    end
    annProps = getappdata(ret(i),'SerializedAnnotationV7');
    hA = get(ret(i),'Annotation');
    try
        fNames = fieldnames(annProps);
        % Loop through the annotation properties
        for j = 1:numel(fNames)
            currProp = fNames{j};
            if isprop(hA,currProp)
                % First, remove any properties in the substructure that are not
                % valid:
                hVal = get(hA,currProp);
                hStruct = annProps.(currProp);
                hStructOut = hStruct;
                structNames = fieldnames(hStruct);
                for k = 1:numel(structNames)
                    if ~isprop(hVal,structNames{k})
                        hStructOut = rmfield(hStructOut,structNames{k});
                    end
                end
                % Set the properties
                set(hVal,hStructOut);
            end
        end
    catch E
        % We tried to set the properties.
    end
    rmappdata(ret(i),'SerializedAnnotationV7');
end

%---------------------------------------------------------------%
function ret = localRestoreBehaviorObjects(h)
% Restore behavior objects from the serialized structure data
% H is a handle within the HG tree
% The output argument is not currently used by find.

ret = false; 
if ~ishandle(h)
    return;
end

h = double(h); % appdata requires double type

% If object has serialized behavior objects
if isappdata(h,'SerializedBehaviorV7')
    appdata = getappdata(h,'SerializedBehaviorV7');
    b = handle([]);

    % Loop through the appdata and create a new behavior objects representing
    % the appdata
    for n = 1:length(appdata)

        if isfield(appdata,'class') && isfield(appdata,'properties')

            % Try/catch just in case the serialized data is corrupted
            try %#ok
                
                % Create behavior object by eval'ing it's class name
                % Example: eval('graphics.zoombehavior')
                b(n) = feval(appdata(n).class);

                % Set the behaviors properties by passing in a
                % structure. Each field corresponds to a property name
                set(b(n),appdata(n).properties);
            
            end
        end % if
    end % for

    % Set the vector of behavior objects to the property
    for n = 1:length(b)
        hgaddbehavior(h,b(n));
    end
    rmappdata(h,'SerializedBehaviorV7');
    ret = true;
end


%---------------------------------------------------------------%
function hgS = localInjectBusyDeserializing(hgS)
if strcmp(hgS.type, 'root')
    hgS.properties.ApplicationData.BusyDeserializing = 1;    
end

