function startscribeobject(objtype,fig)
%STARTSCRIBEOBJECT Initialize insertion of annotation.

%   Copyright 1984-2009 The MathWorks, Inc.

% At first time creation load scribe classes to speed up
% subsequent creation. Perhaps some helper functions could
% do this in other places, too.
persistent firsttime;
if isempty(firsttime)
  firsttime = 0;
  if ~feature('HGUsingMATLABClasses')
      oldptr = get(fig,'pointer');
      set(fig,'pointer','watch');
      drawnow expose;
      % load scribe classes
      dummy = scribe.scriberect(fig); delete(dummy);
      dummy = scribe.scribeellipse(fig); delete(dummy);
      dummy = scribe.line(fig); delete(dummy);
      dummy = scribe.arrow(fig); delete(dummy);
      dummy = scribe.doublearrow(fig); delete(dummy);
      dummy = scribe.textarrow(fig); delete(dummy);
      dummy = scribe.textbox(fig); delete(dummy);
      set(fig,'pointer',oldptr);
  end
end
plotedit(fig,'on');

hPlotEdit = plotedit(fig,'getmode');

objtypes = {'rectangle','ellipse','textbox','doublearrow','arrow','textarrow','line'};
if (strcmpi(objtype, 'none'))
    tindex = 0;
   if isappdata(fig, 'StartScribeObject')
       %See comment on line 41(Turning off the other toggles will call ...)
       %to understand why this is important
       return
   end
else
    tindex = find(strcmpi(objtype,objtypes));
end
if isempty(tindex)
    error('MATLAB:startscribeobject:UnknownObjectType','unknown object type');
end

% turn off other toggles
setappdata(fig, 'StartScribeObject', 1);
t = {...
 uigettool(fig,'Annotation.InsertRectangle'),...
 uigettool(fig,'Annotation.InsertEllipse'),...
 uigettool(fig,'Annotation.InsertTextbox'),...
 uigettool(fig,'Annotation.InsertDoubleArrow'),...
 uigettool(fig,'Annotation.InsertArrow'),...
 uigettool(fig,'Annotation.InsertTextArrow'),...
 uigettool(fig,'Annotation.InsertLine'),...
 uigettool(fig,'Annotation.Pin')};
ntoggles = length(t);
for k=1:ntoggles-1
    if k~=tindex && ~isempty(t{k})
        set(t{k},'state','off');
    end
end
rmappdata(fig, 'StartScribeObject');

% Specify the object to be created
hMode = hPlotEdit.ModeStateData.CreateMode;
hMode.ModeStateData.ObjectName = objtype;

% Revert to the default mode if there is nothing to be done.
if tindex == 0
    activateuimode(hPlotEdit,'');
    return;
end

% If the mode is already started (i.e. we are switching objects, skip this
% step.
if ~isactiveuimode(hPlotEdit,'Standard.ScribeCreate');
    activateuimode(hPlotEdit,hMode.Name);
end

