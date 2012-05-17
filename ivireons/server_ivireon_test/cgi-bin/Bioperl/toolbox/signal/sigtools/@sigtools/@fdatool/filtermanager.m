function varargout = filtermanager(this, mode, varargin)
%FILTERMANAGER    Load the filter manager.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2006/12/27 21:30:29 $

h = getcomponent(this, '-class', 'siggui.filtermanager');

if isempty(h)

    % If we haven't already called the filter manager, generate the object
    % and add it to FDATool as a component.
    h = siggui.filtermanager;
    addcomponent(this, h);
end

if ~isrendered(h)
    render(h);
    centerfigonfig(this, h.figurehandle);

    % Add a listener to the 'NewFilter' event which tells us when a new
    % Filter has been made Current.  Make sure we do this after the render
    % to avoid bugs.
    l = [ ...
        handle.listener(h, 'NewFilter', {@newfilter_listener, h}); ...
        handle.listener(this, 'FilterUpdated', {@filterupdated_listener, h}); ...
        ];
    set(l, 'CallbackTarget', this);
    setappdata(h.FigureHandle, 'filtermanager_listener', l);
end

switch lower(mode)
%     case 'save'
%         sn = getstate(this);
%         sc = h.Data.elementat(h.CurrentFilter);
%         sn.currentName = sc.currentName;
%         h.Data.replaceelementat(sn, h.CurrentFilter);
%         send(h, 'NewData');
    case {'saveas', 'save'}
        l = getappdata(this, 'filtermanager_listener');

        % Disable the listener because we dont want FDATool to update with the
        % same filter thats already in there.
        set(l, 'Enabled', 'Off');
        
        % Make sure that we have a filter name.
        sn = getstate(this);
        if isempty(sn.currentName)
            sn.CurrentName = 'Filter';
        end
        
        if isfield(sn, 'filtermanager')
            sn = rmfield(sn, 'filtermanager');
        end

        sn.mcode = copy(sn.mcode);

        indx = addfilter(h, sn, varargin{:});
        
        if ~isempty(indx)
            
            % After we add the new filter, make sure it is one of the selected and
            % set the CurrentFilter to the end (the new filter).
            set(h, 'SelectedFilters', indx);
            set(h, 'CurrentFilter', indx);
            
            set(this, 'FileDirty', true);
        end
        set(l, 'Enabled', 'On');
    case 'init'
        % NO OP
    otherwise
        set(h, 'Visible', 'On');
        figure(h.FigureHandle);
end

if nargout
    varargout = {h};
end

% ------------------------------------------------------------------------
function filterupdated_listener(this, eventData, hm)

l = getappdata(this, 'filtermanager_listener');

% Disable the listener because we dont want FDATool to update with the
% same filter thats already in there.
set(l, 'Enabled', 'Off');

if strcmpi(hm.Overwrite, 'on')
    replaceState(hm, this);
else
    set(hm, 'SelectedFilters', []);
end

set(l, 'Enabled', 'On');

% ------------------------------------------------------------------------
function newfilter_listener(this, eventData, hm)

% When the current filter is set to 0, it means nothing is selected.  This
% should have no effect on FDATool.
if hm.CurrentFilter == 0
    return;
end

sendstatus(this, 'Loading filter ...')

l = getappdata(hm.FigureHandle, 'filtermanager_listener');

% Disable the listener because we dont want FDATool to update with the
% same filter thats already in there.
set(l, 'Enabled', 'Off');

data = get(hm, 'Data');

setstate(this, data.elementat(hm.CurrentFilter));

% Replace the data stored at the current filter index with the new state
% from FDATool.  This will capture any changes into the filter manager that
% FDATool might want to make to the data.  g345289
replaceState(hm, this);

sendstatus(this, 'Loading filter ... done')

set(l, 'Enabled', 'On');

% -------------------------------------------------------------------------
function replaceState(hm, this)

s = getstate(this);
s_old = hm.data.elementat(hm.CurrentFilter);
s.currentName = s_old.currentName;
if isfield(s, 'filtermanager')
    s = rmfield(s, 'filtermanager');
end
hm.data.replaceelementat(s, hm.CurrentFilter);
send(hm, 'NewData');

% [EOF]
