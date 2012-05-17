function childAddedCbk(src, evd)

% Copyright 2003-2006 The MathWorks, Inc.

hgroup = src;
ch = evd.Child;

if (strcmpi(ch.type, 'uicontrol'))
    if (strcmpi(ch.style, 'radiobutton') || ...
            strcmpi(ch.style, 'togglebutton'))
        if ~isempty(get(ch, 'Callback'))
            warning('MATLAB:childAddedCbk:CallbackWillBeOverwritten', ...
                sprintf('Callback for uicontrol of style %s will be overwritten when added to a UIBUTTONGROUP.\n Use the SelectionChangeFcn property on the button group instead.', ch.style));
        end
        set(ch, 'callback', {@manageButtons, hgroup});

        listeners = get(hgroup, 'Listeners');
        listeners{end+1} = handle.listener(ch, findprop(ch, 'Value'), ...
            'PropertyPostSet', @valueChangedCbk);
        set(hgroup, 'Listeners', listeners);

        if isempty(get(hgroup, 'SelectedObject')) || ( get(ch,'Value') == 1 )
            set(hgroup, 'SelectedObject', double(ch));
        else
            set(ch, 'Value', 0);
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This gets fired twice (on and off) BEFORE the callback is fired.
function valueChangedCbk(src, evd)                                  %#ok
ctrl = evd.AffectedObject;
hgroup = get(ctrl, 'Parent');

if isappdata(hgroup, 'inSelectedObjectSet')
    % Change value w/o changing SelectedObject. Used to prevent reentry.
    return
end

oldctrl = get(hgroup, 'SelectedObject');
set(hgroup, 'OldSelectedObject', oldctrl);

if (evd.NewValue == 0)
    if (ctrl == get(hgroup, 'SelectedObject'))
        set(hgroup, 'SelectedObject', []);
    end
else
    set(hgroup, 'SelectedObject', ctrl);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function manageButtons(src, evd, hgroup)                            %#ok
ctrl = src;
% Get the previous SelectedObject from the global variable set in
% the valueChangedCbk function (above)
oldctrl = get(hgroup, 'OldSelectedObject');
set(hgroup, 'OldSelectedObject', []);

selchanged = true;
if (ctrl == oldctrl)
    set(ctrl, 'Value', 1);
    selchanged = false;
else
    set(hgroup, 'SelectedObject', ctrl);
end

if (~selchanged)
    return
end
cbk = get(hgroup, 'SelectionChangeFcn');
if ~isempty(cbk);
    source = double(hgroup);
    evdata.EventName = 'SelectionChanged';
    evdata.OldValue = double(oldctrl);
    evdata.NewValue = ctrl;

    hgfeval(cbk, source, evdata);
end
