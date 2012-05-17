function out = getnset(h, fcn, out)
%GETNSET

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:28:15 $

out = feval(fcn, h, out);

% -------------------------------------------------------------------------
function selection = setselection(hObj, selection)

options = getenabledselections(hObj);

% If no new selection is given, return the available selections
msg = '';
if nargin == 1,
    out = options;
    return;
elseif isempty(selection),
    if isempty(options),
        selection = '';
    else
        msg = 'Cannot set to empty when selections are available.';
    end
else
    
    indx = strmatch(selection, options);
    
    switch length(indx)
    case 0
        if isempty(strmatch(selection, getallselections(hObj)));
            msg = 'Selection is not available.';
        else
            msg = 'Selection is disabled.';
        end
    case 1
        selection = options{indx};
    otherwise
        % See if we have an exact match, i.e. iirlpnorm and iirlpnormc
        if isempty(find(strcmpi(selection, options))),
            msg = 'Cannot determine which selection to make.  Found the following matches:';
            msg = [msg char(10)];
            for i = 1:length(indx);
                msg = [msg '  ''' options{indx(i)} ''''];
            end
        end
    end       
end

if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% Get the correct subselection
if isrendered(hObj),
    
    h = get(hObj, 'Handles');
    
    hPop = findobj(h.popup, 'Tag', selection);
    
    if ~isempty(hPop),
        indx = get(hPop,'Value');
        subs = get(hPop,'UserData');
        if indx > length(subs), indx = 1; end
        subselect = subs{indx};
    else
        subselect = '';
    end
else
    subselects = getsubselections(hObj);
    if isempty(subselects),
        subselect = '';
    else
        subselect = subselects{1};
    end
end

% Only set the new selection if it doesn't match the old.
% When these methods become the overloaded sets we should no longer need this.
if ~strcmpi(subselect, hObj.Subselection),
    set(hObj, 'privSubSelection', subselect);
end

set(hObj, 'privSelection', selection);

send(hObj, 'NewSelection', ...
    sigdatatypes.sigeventdata(hObj, 'NewSelection', selection));

% -------------------------------------------------------------------------
function subselect = setsubselection(hObj, subselect)

options = getsubselections(hObj);

% If there is only one input argument return the options
if nargin == 1,
    out = options;
    return;
end

msg = '';
% If Subselection is empty set it, but only if there are no options
if isempty(subselect)
    if isempty([options{:}]),
        subselect = '';
    else
        msg = 'Cannot set subselection to '''' if a subselection is available.';
    end
else
    indx = strmatch(subselect,options);
    switch length(indx)
    case 0
        msg = 'That subselection is not available.';
    case 1
        subselect = options{indx};
    otherwise
        
        % See if we have an exact match, i.e. iirlpnorm and iirlpnormc
        if isempty(find(strcmpi(subselect, options))),
            
            msg = ['Subselection is not specific enough.  Found these matches:' char(10)];
            for i = 1:length(indx)
                msg = [msg '  ''' options{indx(i)} ''''];
            end
        end
    end
end

if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

set(hObj, 'privSubSelection', subselect);

% Send the NewSubSelection event
send(hObj, 'NewSubSelection', ...
    sigdatatypes.sigeventdata(hObj, 'NewSubSelection', subselect));

% -------------------------------------------------------------------------
function out = getselection(h, out)

out = get(h, 'privSelection');

% -------------------------------------------------------------------------
function out = getsubselection(h, out)

out = get(h, 'privSubSelection');

% [EOF]
