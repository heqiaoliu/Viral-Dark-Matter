function siggui_warning(hObj, title, wstr, wid)
%WARNING Display a warndlg
%   WARNING(H) Display a warndlg using 'Warning' as the title and lastwarn
%   as the string.
%
%   WARNING(H, TITLE) Display a warndlg using TITLE as the title and lastwarn
%   as the string.
%
%   WARNING(H, TITLE, WSTR) Display a warndlg using TITLE as the title and
%   WSTR as the string.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2010/03/04 16:32:44 $

error(nargchk(1,4,nargin,'struct'));

if nargin < 4
    if nargin < 3,
        [wstr, wid] = lastwarn;
    else
        wid = '';
    end
    if nargin < 2
        title = 'Warning';
    end
end

% Reset mouse pointer and status line.
hFig = get(hObj, 'figureHandle');
setptr(hFig, 'arrow');

wid = fliplr(strtok(fliplr(wid), ':'));

% When we have the ID system working for all warnings we can do this:
%
switch lower(wid),
    case {'syntaxchanged', 'pathwarning'}
        % NO OP
    otherwise

        if any(strcmpi(wstr, {'negative data ignored.'}))
            return;
        end

        h_warn = warndlg(wstr, title);

        h = get(hObj, 'Handles');

        if isfield(h, 'warn'),
            h.warn(end+1) = h_warn;
        else
            h.warn = h_warn;
        end

        set(hObj, 'Handles', h);
end

% [EOF]
