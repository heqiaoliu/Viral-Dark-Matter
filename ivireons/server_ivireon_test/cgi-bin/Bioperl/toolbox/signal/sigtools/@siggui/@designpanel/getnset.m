function out = getnset(h, op, value)
%GETNSET Perform specific gets and sets for the design panel

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2007/12/14 15:18:17 $

out = feval(op, h, value);

% ----------------------------------------------------------------------
function out = getcfs(h, type)

hDM = get(h, 'CurrentDesignMethod');

out.value = [];
out.units = 'Normalized (0 to 1)';

if ~isempty(hDM),
    out.units = get(hDM, 'freqUnits');
    if ~strncmpi(out.units, 'normalized', 10),
        out.value = get(hDM, 'Fs');
    end
end

% ----------------------------------------------------------------------
function out = setresponsetype(h, type)
%SETFILTERTYPE set the filter type property

hFT = getcomponent(h, '-class', 'siggui.selector', 'Name', 'Response Type');

set(hFT, 'Selection', type);

out = '';

% ----------------------------------------------------------------------
function out = getresponsetype(h, type)
%GETFILTERTYPE Get the current filter type

hFT = getcomponent(h, '-class', 'siggui.selector', 'Name', 'Response Type');

out = get(hFT, 'Selection');

% ----------------------------------------------------------------------
function out = setsubtype(h, type)

hFT = getcomponent(h, '-class', 'siggui.selector', 'Name', 'Response Type');

set(hFT, 'SubSelection', type);
out = '';

% ----------------------------------------------------------------------
function out = getsubtype(h, type)

hFT = getcomponent(h, '-class', 'siggui.selector', 'Name', 'Response Type');

out = get(hFT, 'SubSelection');
if isempty(out),
    out = get(hFT, 'Selection');
end

% ----------------------------------------------------------------------
function out = setdesignmethod(h, type)
%SETDESIGNMETHOD Set the current designmethod

hDM = getcomponent(h, '-class', 'siggui.selector', 'Name', 'Design Method');

iirms = getsubselections(hDM, 'iir');
firms = getsubselections(hDM, 'fir');

if any(strcmpi(type, iirms)),
    set(hDM, 'selection', 'iir');
    set(hDM, 'subselection', type);
elseif any(strcmpi(type, firms)),
    set(hDM, 'selection', 'fir');
    set(hDM, 'subselection', type);
else
    error(generatemsgid('NotSupported'),'That method is not available.');
end

out = '';

% ----------------------------------------------------------------------
function out = getdesignmethod(h, type)
%GETDESIGNMETHOD Return the constructor to the current design method

hDM = getcomponent(h, '-class', 'siggui.selector', 'Name', 'Design Method');

if ~isempty(hDM),
    out = get(hDM, 'SubSelection');
else
    out = '';
end
