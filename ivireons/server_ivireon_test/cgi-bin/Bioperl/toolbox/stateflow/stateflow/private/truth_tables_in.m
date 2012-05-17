function ttFcns = truth_tables_in(objectId)
ttFcns = [];
charts = charts_in(objectId);
for i=1:length(charts)
  ttFcns = [ttFcns,truth_tables_in_chart(charts(i))];
end

function ttFcns = truth_tables_in_chart(chart)
    allStates = sf('FunctionsIn',chart);
    ttFcns = sf('find',allStates,'state.type','FUNC_STATE','state.truthTable.isTruthTable',1);

% Copyright 2002-2006 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $  $Date: 2008/02/20 01:35:43 $
