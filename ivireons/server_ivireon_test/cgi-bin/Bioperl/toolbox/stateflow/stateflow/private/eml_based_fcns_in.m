function emlBasedFcns = eml_based_fcns_in(objectId, allFlag)
% Copyright 2002-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/20 20:50:03 $

if(nargin<2)
   allFlag = '';
end

emlBasedFcns= [];
charts = charts_in(objectId);

for i=1:length(charts)
  emlBasedFcns = [emlBasedFcns, eml_based_fcns_in_chart(charts(i))];
end

return;

function emlBasedFcns = eml_based_fcns_in_chart(chart)

allStates = sf('get',chart,'chart.states');
emlFcns = sf('find',allStates,'state.type','FUNC_STATE','state.eml.isEML',1);
emlTTs  = sf('find',allStates,'state.type','FUNC_STATE','state.truthTable.isTruthTable',1,'state.truthTable.useEML',1);
emlBasedFcns = [emlFcns emlTTs];
return;
