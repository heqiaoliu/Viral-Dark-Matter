function abstractxpdestwvars_construct(this)
%ABSTRACTXPDESTWVARS_CONSTRUCT   Perform the common construct.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:27:18 $

% Create an ExportAs property (if defined in the info struct)
addexportasprop(this);

% Return the labels and names so that we can create a
% siggui.labelsandvalues object with the correct number of values.
[lbls,names] = parse4vec(this);

hlnv = siggui.labelsandvalues('maximum',length(lbls));

l = handle.listener(hlnv, hlnv.findprop('Values'), 'PropertyPostSet', @values_listener);
set(l, 'CallbackTarget', this);
set(this, 'ValuesListener', l);

addcomponent(this, hlnv);

set(this,'VariableLabels',lbls,...
    'VariableNames',names);

% ---------------------------------------------------------------------
function values_listener(this, eventData)

send(this, 'UserModifiedSpecs');
savenames(this);

% [EOF]
