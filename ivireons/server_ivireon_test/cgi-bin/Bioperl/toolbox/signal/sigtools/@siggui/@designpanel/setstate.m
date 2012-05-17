function setstate(this, s)
%SETSTATE Set the designpanel's state

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.6 $  $Date: 2007/12/14 15:18:19 $

error(nargchk(2,2,nargin,'struct'));

set(this, 'PreviousState', s, 'isLoading', true);

try
    set(this, lclconvertstatestruct(this, s));
catch
    set(this, 'isLoading', false);
    errstr = ['The session you are loading appears to be from a MATLAB ', ...
        'that has the Filter Design Toolbox.  Not all settings can be loaded.'];
    error(generatemsgid('SigErr'),errstr);
end

for hindx = allchild(this)
    setcomponentstate(this, s, hindx);
end

% Force fire the event of the filter order so that the min/specify frames
% will appear.
hFO = find(this, '-class', 'siggui.filterorder');
send(hFO, 'UserModifiedSpecs', handle.EventData(hFO, 'UserModifiedSpecs'));

if isfield(s, 'isDesigned')
    set(this, 'isDesigned', s.isDesigned);
end

set(this, 'isLoading', false);

% -------------------------------------------------------------
%   Functions for backwards compatibility
% -------------------------------------------------------------

% -------------------------------------------------------------
function sout = lclconvertstatestruct(this, sin)

if isfield(sin, 'type'),

    sout.ResponseType   = sin.type;
    sout.DesignMethod   = processmethod(sin.method);
    sout.StaticResponse = sin.StaticResponse;
else
    fout = {'Tag', 'Version', 'Components'};
    if isfield(sin, 'FilterType'),
        sin.ResponseType = sin.FilterType;
        fout = {fout{:}, 'FilterType'};
    end
    sout = rmfield(sin, fout);
end

if ~isfield(sout, 'SubType');

    hFT = getcomponent(this, '-class', 'siggui.selector', 'Name', 'Response Type');

    sout.SubType = sout.ResponseType;
    filtertypes  = getallselections(hFT);
    for indx = 1:length(filtertypes)
        subs = getsubselections(hFT, filtertypes{indx});

        idx = find(strcmpi(subs, sout.SubType));

        if ~isempty(idx),
            sout.ResponseType = filtertypes{indx};
            break;
        end
    end
end
sout = reorderstructure(sout, 'ResponseType', 'SubType');


% -------------------------------------------------------------
function method = processmethod(method)

switch method
    case 'cheb2'
        method = 'filtdes.cheby2';
    case 'cheb1'
        method = 'filtdes.cheby1';
    otherwise

        if isempty(findstr(method, '.')),
            method = ['filtdes.' method];
        end
end

% [EOF]
