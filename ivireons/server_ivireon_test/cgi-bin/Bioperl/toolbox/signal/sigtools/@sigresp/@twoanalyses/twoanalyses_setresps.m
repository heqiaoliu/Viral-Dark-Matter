function out = twoanalyses_setresps(this, out)
%SETRESPS Perform the preset operations on the new analyses.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/12/14 15:21:00 $

if isempty(out), 
    hPrm = [];
else
    if ~isa(out, 'sigresp.freqaxis') && ~isa(out, 'sigresp.timeaxis'),
        error(generatemsgid('GUIErr'),'Responses must be of the same type (freqaxis or timeaxis)');
    end
    
    % The responses should always have grid and legend off.  The TWORESPS
    % object will take care of it.
    set(out, 'Legend', 'Off');
    set(out(2), 'Grid', 'Off');
    set(out(1), 'Grid', this.Grid);
    
    % Get the parameters from the responses and combine them.  Make sure
    % that the common parameters show up first in the same order as they
    % were in the first response.  Make sure that the "non common"
    % parameters show up in the same order that they are in their
    % individual responses by sorting the indx from setxor.  If the order
    % didn't matter we could just say "union(prm1, prm2)".
    prm1 = get(out(1), 'Parameter');
    prm2 = get(out(2), 'parameter');
    [commonprm, indx] = intersect(prm1, prm2);
    [noncommonprm, indx1, indx2] = setxor(prm1, prm2);
    hPrm = [prm1(sort(indx)); prm1(sort(indx1)); prm2(sort(indx2))];
    
    % TWORESPS does not extend from SIGCONTAINER so it must handle the
    % notification listener itself.  In order for it to inherit from
    % SIGCONTAINER the entire FILTRESP package would have to inherit from
    % SIGCONTAINER.
    this.ChildListener = [ ...
        handle.listener(out, 'Notification', ...
        @(hSrc, ed) lclnotification_listener(this, ed)); ...
        handle.listener(out, 'DisabledListChanged', ...
        @(hSrc, ed) lcldisabledlist_listener(this, ed))];
    
    d = union(get(out(1), 'DisabledParameters'), get(out(2), 'DisabledParameters'));
    for indx = 1:length(d)
        disableparameter(this, d{indx});
    end
end

set(this, 'Parameters', hPrm);

% -------------------------------------------------------------------------
function lclnotification_listener(this, eventData)

% We do not want to resend 'Computing ... done' statuses.  This status is
% sent from the TWORESPS object itself, not the contained objects.

if strcmpi(eventData.NotificationType, 'StatusChanged'),
    if strcmpi(eventData.Data.StatusString, 'Computing Response ... done'),
        return;
    end
end

send(this, 'Notification', eventData);

% -------------------------------------------------------------------------
function lcldisabledlist_listener(this, eventData)

d = get(eventData, 'Data');

if strcmpi(d.type, 'disabled'),
    disableparameter(this, d.tag);
else
    enableparameter(this, d.tag);
end

% [EOF]
