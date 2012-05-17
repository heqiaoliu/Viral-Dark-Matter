function ted_the_editors(machineId)
%TED_THE_EDITORS( MACHINEID )

%   Jay R. Torgerson
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2008/12/01 08:08:22 $

charts = sf('get', machineId, '.charts');
for chart = charts(:)',
    sf('LoseFocusFcn', chart);
    % Update any truthtable editors that are open
    truthTables = truth_tables_in(chart);
    for j = 1:length(truthTables)
        truth_table_man('update_data',truthTables(j),'stop_editing');
    end
end;
