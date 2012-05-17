function update_eml_data(machineId)
%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2005/06/24 11:31:50 $

% Change to "eml_fcns_in()" if the lock for em tt block is implemented in eM editor.
emlFcns = eml_based_fcns_in(machineId);

for j = 1:length(emlFcns)
    eml_man('update_data', emlFcns(j));
    eml_man('update_layout_data', emlFcns(j));
end
