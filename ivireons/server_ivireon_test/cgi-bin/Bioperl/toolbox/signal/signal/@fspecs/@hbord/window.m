function Hd = window(this, win, varargin)
%WINDOW   Design a window filter.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:48:43 $

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
    winstr = sprintf('%s\n\nwindow(h, ''Window'', %s)', ...
        'parameters after specifying the ''Window'' property, e.g. ', winstr);

    warning(generatemsgid('deprecatedFeature'), ...
        sprintf('%s\n%s\n%s\n\n%s', ...
        'Passing the window function parameters as separate inputs is a', ...
        'deprecated feature and may be removed in a future version.  Pass window', ...
        winstr, ...
        'See ''help(h, ''window'')'' for more information.'));
    
    % If we have a structure, set it into the object.
    if length(varargin) > 0,
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
if ishp(this),
    Hd = firlp2hp(Hd);
    % Reset the contained FMETHOD.
    Hd.setfmethod(d);
end


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
