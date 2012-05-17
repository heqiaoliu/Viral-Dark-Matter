function visible_listener(this, eventData)
%VISIBLE_LISTENER Listener to the Visible property of FDATool

% Author(s): J. Schickler
% Copyright 1988-2008 The MathWorks, Inc.
% $Revision: 1.11.4.6 $ $Date: 2009/01/05 18:02:05 $

hFig     = get(this,'FigureHandle');
visState = get(this,'Visible');

h = get(this, 'Handles');

hc = allchild(this);

if isappdata(this, 'tipoftheday')
    hTip = getappdata(this, 'tipoftheday');
else
    hTip = -1;
end

if strcmpi(visState, 'On'),

    ht = findobj(h.menus.main, 'tag', 'targets');
    if isempty(allchild(ht)), h.menus.main = setdiff(h.menus.main, ht); end

    set(convert2vector(h.menus.main), 'Visible', 'on');
    set(convert2vector(h.toolbar), 'Visible', 'On');

    drawnow;

    % When turning visible on eliminate the dialog children.
    hc = find(hc, '-depth', 0, '-not', '-isa', 'siggui.dialog');
else
    if ishghandle(hTip)
        delete(hTip);
    end
    deletewarndlgs(this);
    set(hFig,'Visible',visState);
end

set(hc, 'Visible', visState);

if strcmpi(visState, 'on'),
%     figure(hFig);

    h.recessedFr = h.recessedFr(2:end);
    h = convert2vector(rmfield(h, 'staticresp'));
    set(h, 'visible', 'on');
    set(hFig, 'Visible', 'On');
    if ishghandle(hTip)
        figure(hTip);
    end
end

% [EOF]