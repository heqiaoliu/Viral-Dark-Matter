function movetofront(hThis)
% Move the marker and textbox so that it always renders on top.

%   Copyright 1984-2005 The MathWorks, Inc.

hAxes = getaxes(hThis);

% Only do Z-Stacking on 2-D plots
if is2D(hAxes) && get(hThis,'EnableZStacking')
	localZStacking(hThis);
else
	localChildOrderStacking(hThis);
end

% Datatip is visible only if inside axes limits
inBounds = localDoClip(hThis);

% ToDo: The code below is replicated in updatePositionAndString
if strcmp(get(hThis,'Visible'),'on')
	hMarker = hThis.MarkerHandle;
	hTextBox = hThis.TextBoxHandle;
	if (ishandle(hMarker) && ishandle(hTextBox))
		if inBounds
			set(hMarker,'Visible','on');
			if strcmp(get(hThis,'ViewStyle'),'datatip')
				set(hTextBox,'Visible','on');
			end
		else
			set(hMarker,'Visible','off');
			set(hTextBox,'Visible','off');
		end
	end
end

%------------------------------------------------------------%
function inBounds = localDoClip(hThis,pos)

% See if the cursor position is empty or outside the
% axis limits
hDataCursorInfo = get(hThis,'DataCursorHandle');
if ishandle(hDataCursorInfo)
	pos = get(hDataCursorInfo,'Position');
else
	return;
end

hAxes = get(hThis,'HostAxes');
inBounds = false;
xlm = get(hAxes,'xlim'); ylm = get(hAxes,'ylim'); zlm = get(hAxes,'zlim');
if ~isempty(pos) && ...
		pos(1) >= min(xlm) && pos(1) <= max(xlm) && ...
		pos(2) >= min(ylm) && pos(2) <= max(ylm)
	if length(pos) > 2
		if ~is2D(hAxes)
			if pos(3) >= min(zlm) && pos(3) <= max(zlm)
				inBounds = true;
			end
		else
			if pos(3) < min(zlm)
				set(hAxes,'zlim',[pos(3),max(zlm)]);
			elseif pos(3) > max(zlm)
				set(hAxes,'zlim',[min(zlm),pos(3)]);
			end
			inBounds = true;
		end
	else
		inBounds = true;
	end
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

% Make sure the axes is pushed to the top of the rendering stack so it
% always appears above all other axes except the scribe axes.Used by the
% Control Toolbox.
if get(hThis,'EnableAxesStacking')
	hSiblings = allchild(get(hAxes,'Parent'));

	% Push scribe related axes to the very top
	hScribeAxes = findall(hSiblings,'flat','type','axes','tag','scribeOverlay');
	hColorbarAxes = findall(hSiblings,'flat','type','axes','tag','Colorbar');
	hLegendAxes = findall(hSiblings,'flat','type','axes','tag','legend');

	% Ensure that the scribe related axes always appear on top
	% Adding try/catch just in case some other code
	% has external listeners on child order which could cause
	% problems.
	try
		axes(double(hAxes));
		for n = 1:length(hColorbarAxes), axes(hColorbarAxes(n)); end
		for n = 1:length(hLegendAxes), axes(hLegendAxes(n)); end
		for n = 1:length(hScribeAxes), axes(hScribeAxes(n)); end
	end

	% uistack will cause the toolbar to flicker (g246041)
	%uistack([double(hAxes), hColorbarAxes', hLegendAxes', hScribeAxes']);
end

%----------------------------------------------%
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