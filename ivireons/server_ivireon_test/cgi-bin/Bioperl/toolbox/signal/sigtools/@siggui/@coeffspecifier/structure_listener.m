function structure_listener(this, eventData)
%STRUCTURE_LISTENER Listens to the SelectedStructure property of the Coefficient Specifier

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2005/06/16 08:45:35 $

specs = get(this, 'AllStructures');
set(this.Handles.selectedstructure, ...
    'Value', find(strcmpi(specs.strs, this.SelectedStructure)));

update_labels(this, eventData);
update_editboxes(this, eventData);
update_checkbox(this, eventData);

sendfiledirty(this);

% [EOF]
