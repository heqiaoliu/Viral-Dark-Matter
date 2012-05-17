
%   Copyright 2009 The MathWorks, Inc.

function table = getSldvMetricDescrTable

persistent pSldvDescr


if isempty(pSldvDescr) 
	pSldvDescr = { ...
	    'Design Verifier Test Objective', ...
	    'cvmetric_Sldv_test', ...
	    'TO' , ...
        0, ...        
	    'Test Objective'; ...
        ...
	    'Design Verifier Proof Objective', ...
	    'cvmetric_Sldv_proof', ...
	    'PO' , ...
        0, ...        
	    'Proof Objective'; ...
        ...
	    'Design Verifier Test Condition', ...
	    'cvmetric_Sldv_condition', ...
	    'TC' , ...
        0, ...        
	    'Test Condition'; ...
        ...
	    'Design Verifier Assumption', ...
	    'cvmetric_Sldv_assumption', ...
	    'PA' , ...
         0, ...        
	    'Proof Assumption'; ...
      }; 
     pSldvDescr = setMetricEnums(pSldvDescr);
end

table = pSldvDescr;

%==============================
function descrTable = setMetricEnums(descrTable)
    s = size(descrTable);
    for idx = 1:s(1)
        mn = descrTable{idx,2};
        metricedataId = cv('find', 'all', 'metricdescr.name', mn);
        descrTable{idx,4} = cv('get', metricedataId, '.enumVal'); 
    end
