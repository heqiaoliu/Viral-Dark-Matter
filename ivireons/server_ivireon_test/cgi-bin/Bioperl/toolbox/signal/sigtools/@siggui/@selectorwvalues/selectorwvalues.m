function this = selectorwvalues(name, tags, labels, select, subselect, values)
%SELECTORWVALUES   Construct a SELECTORWVALUES object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 15:19:25 $

error(nargchk(3,6,nargin,'struct'));

if nargin > 3,
    if iscell(select)
        values    = select;
        select    = '';
        subselect = '';
    elseif nargin > 4,
        if iscell(subselect),
            values = subselect;
            subselect = '';
        end
    else
        subselect = '';
        values    = {};
    end
else
    values = {};
    select = '';
    subselect = '';
end

this = siggui.selectorwvalues;

% Set up the object
set(this, 'Identifiers', tags);
set(this, 'Strings', labels);
set(this, 'Version', 1.0);
set(this, 'Name', name);

if isempty(subselect),
    subselects = getsubselections(this);
    subselect  = subselects{1};
end
if isempty(select)
    selects = getallselections(this);
    select  = selects{1};
end

% Set the objects original selection
set(this, 'Selection', select);

if ~isempty(subselect),
    set(this, 'SubSelection', subselect);
end

% hsel = siggui.selector(name, tags, labels, varargin{:});
hlnv = siggui.labelsandvalues('Maximum', length(tags), ...
    'Values', values, ...
    'Labels', labels, ...
    'HiddenLabels', 1:length(tags));

% addcomponent(this, [hsel hlnv]);
addcomponent(this, hlnv);

l = [ ...
        handle.listener(hlnv, 'UserModifiedSpecs', @usermodifiedspecs_listener); ...
        handle.listener(this, this.findprop('Strings'), 'PropertyPostSet', ...
        @strings_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'Listeners', l);

% -------------------------------------------------------------------------
function strings_listener(this, eventData)

% Sync the labels and the strings.
hlnv = getcomponent(this, '-class', 'siggui.labelsandvalues');
set(hlnv, 'Labels', this.Strings);

% -------------------------------------------------------------------------
function usermodifiedspecs_listener(this, eventData)

send(this, 'UserModifiedSpecs', eventData);

% [EOF]
