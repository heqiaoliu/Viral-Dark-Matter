function thisrender(this, varargin)
%THISRENDER   Render the selectorwvalues object
%   H.THISRENDER(HFIG, POS, CTRLPOS, VALUEWIDTH)

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:25:37 $

sz = gui_sizes(this);

if nargin > 1,
    if isnumeric(varargin{end}) && prod(size(varargin{end})) == 1,
        valwidth = varargin{end};
        varargin(end) = [];
    else
        valwidth = 60*sz.pixf;
    end
    if length(varargin),
        if length(varargin{1}) == 1,
            hFig = varargin{1};
            varargin(1) = [];
        else
            hFig = gcf;
        end
    else
        hFig = gcf;
    end
    if length(varargin),
        pos = varargin{1};
        if length(varargin) > 1,
            ctrlpos = varargin{2};
        else
            ctrlpos = pos;
        end
    end
else
    hFig = gcf;
    pos = [10 10 200 100]*sz.pixf;
    valwidth = 60*sz.pixf;
    ctrlpos = pos;
end

% Not sure why, but there is a 7 pixel diff between the spacing.
valpos     = ctrlpos;
valpos(1)  = valpos(1)+valpos(3)-valwidth-2*sz.uuhs+2*sz.pixf;
valpos(3)  = valwidth+sz.uuhs-2*sz.pixf;

selector_render(this, hFig, pos, ctrlpos)

% Make sure the labels dont get cut off.
for indx = 1:length(this.Strings)
    pos = getpixelpos(this, 'radio', indx);
    
    pos(3) = ctrlpos(3)-sz.rbwTweak;
    
    setpixelpos(this, 'radio', indx, pos);
end

hlnv = getcomponent(this, '-class', 'siggui.labelsandvalues');

render(hlnv, this.FigureHandle, valpos, 0, 1);

l = [ ...
        handle.listener(this, this.findprop('AllowNonCurrentEditing'), ...
        'PropertyPostSet', @allownoncurrentediting_listener); ...
        handle.listener(this, 'NewSelection', @allownoncurrentediting_listener); ...
    ];
set(l, 'CallbackTarget', this);

% Make sure that we do not overwrite the super class listeners.
set(this, 'WhenRenderedListeners', [this.WhenRenderedListeners(:); l]);

allownoncurrentediting_listener(this);

% -------------------------------------------------------------------------
function allownoncurrentediting_listener(this, eventData)

if strcmpi(this.AllowNonCurrentEditing, 'On'),
    dvals = [];
else
    indx = find(strcmpi(this.identifiers, this.Selection));
    dvals = setdiff(1:length(this.Identifiers), indx);
end

hlnv = getcomponent(this, '-class', 'siggui.labelsandvalues');
set(hlnv, 'DisabledValues', dvals);

% [EOF]
