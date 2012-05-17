function Hd = window(this, win, varargin)
%WINDOW   Design a window filter.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:27:12 $

d = getdesignobj(this);

if ~isfield(d, 'window')
    error(generatemsgid('invalidDesign'), ...
        'Window is not defined for these specifications.');
end

d = feval(d.window);

if nargin < 2
    % NO OP
elseif isprop(d, win)
    varargin = {win, varargin{:}};
elseif isstruct(win)
    set(d, win);
else
    winstr = getwinstr(win);
    warning(generatemsgid('deprecatedFeature'), ...
        ['Passing the window function parameters as separate inputs is a '...
        'deprecated feature and may be removed in a future version.  Pass window'...
        'parameters after specifying the ''Window'' property, e.g. \n'...
        'window(h, ''Window'', %s)\n'...
        'See ''help(h, ''window'')'' for more information.'], winstr);

    % If we have a structure, set it into the object.
    if ~isempty(varargin),
        if isstruct(varargin{1})
            set(d, varargin{1});
            varargin(1) = [];
        end
    end
    set(d, 'Window', win);
end


% If we have any more PV pairs set them into the design object.
if length(varargin) > 1, set(d, varargin{:}); end

Hd = design(d, this);

% -------------------------------------------------------------------------
function winstr = getwinstr(win)

if isa(win, 'function_handle')
    winstr = ['@', func2str(win)];
elseif iscell(win)
    winstr = ['{' getwinstr(win{1})];
    for indx = 2:length(win)
        if ischar(win{indx})
            winstr = sprintf('%s, %s', winstr, win{indx});
        else
            winstr = sprintf('%s, %g', winstr, win{indx});
        end
    end
    winstr = [winstr '}'];
elseif isnumeric(win)
    winstr = 'WINDOW_VECTOR';
else
    winstr = ['''' win ''''];
end


% [EOF]
