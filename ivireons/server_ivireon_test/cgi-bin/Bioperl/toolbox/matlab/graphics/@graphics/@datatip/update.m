function update(hThis,target)
% Update datatip position and string based on target

% Copyright 2002-2006 The MathWorks, Inc.

if nargin<2
    hAxes = get(hThis,'HostAxes');
    setappdata(hAxes,'datatip_fireDataTipUpdate',false);
    target = get(hAxes,'CurrentPoint');
    rmappdata(hAxes,'datatip_fireDataTipUpdate');
end

% Create new data cursor if necessary
if ishandle(hThis.DataCursorHandle)
    hNewDataCursor = get(hThis,'DataCursorHandle');
else
    hNewDataCursor = graphics.datacursor;
end

% Update cursor based on target (should
% be a static method)
updateDataCursor(hNewDataCursor,hThis.Host,hNewDataCursor,target); 

% Update datatip based on cursor
updatePositionAndString(hThis,hNewDataCursor);

% Move the datatip to the front
% Move the datatip to the front
hAxes = getaxes(hThis);

% Only do Z-Stacking on 2-D plots
if is2D(hAxes) && get(hThis,'EnableZStacking')
	localZStacking(hThis);
else
	localChildOrderStacking(hThis);
end

%----------------------------------------------%
function localZStacking(hThis)
% Change z-height of datatips to get stacking effect

ZStackMinimum = get(hThis,'ZStackMinimum');

% Get all the datatips in this axes
hAxes = getaxes(hThis);
AllTips = [];
hKids = findall(hAxes,'type','hggroup');
for n = 1:length(hKids)
	h = handle(hKids(n));
	if isa(h,'graphics.datatip') && ~isequal(h,hThis)
		AllTips = [hKids(n); AllTips];
	end
end

if ~isempty(AllTips)

	% Get current stacking order
	Z = zeros(size(AllTips));
	for ct = 1:length(AllTips)

		h = AllTips(ct);
		pos = get(h,'Position');
		if length(pos)>2
			if pos(3) < ZStackMinimum
				Z(ct) = ZStackMinimum;
			else
				Z(ct) = pos(3);
			end
		else
			Z(ct) = ZStackMinimum;
		end
	end

	[Z,sort_ind] = sort(Z);
	AllTips = AllTips(sort_ind);

	% Loop through, restacking datatips
	for ct=1:length(AllTips)
		h = AllTips(ct);
		new_z_value = ZStackMinimum + ct -1;
		pos = get(h,'Position');

		pos(3) = new_z_value;

		%hListeners = get(h,'SelfListenerHandles');
		%set(hListeners,'Enable','off');
		set(h,'Position',pos);
		%set(hListeners,'Enable','off');
	end
end

% Make this datatip appear on top
pos = get(hThis,'Position');
pos(3) = get(hThis,'ZStackMinimum') + length(AllTips);
set(hThis,'Position',pos);

function localChildOrderStacking(hThis)
% Change child order of datatip parent to get stacking effect

hAxes = getaxes(hThis);
kids = handle(get(hAxes,'children'));
kids(kids == hThis) = [];

% This causes the datatip text box to appear below the axes title
temp = [double(hThis); double(kids)];
set(hAxes,'children',temp);

% Force text box to appear on top in zbuffer by
% leaving the units property to 'pixels'
hText = hThis.TextBoxHandle;
set(hText,'units','pixels');
