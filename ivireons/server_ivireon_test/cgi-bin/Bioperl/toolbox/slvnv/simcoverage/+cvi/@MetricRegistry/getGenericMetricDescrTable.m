
%   Copyright 2009 The MathWorks, Inc.

function table = getGenericMetricDescrTable

table = [];
return;

%here comes the new metric description
persistent pGenericDescr


if isempty(pGenericDescr) 
	pGenericDescr = { ...
	    0, ...
	    'cvmetric_Structural_SaturateToMin', ...
	    'SMin' , ...
        0, ...        
	    'Saturate To Minimum'; ...
	    0, ...
	    'cvmetric_Structural_SaturateToMax', ...
	    'SMax' , ...
        0, ...        
	    'Saturate To Maximum'; ...
      }; 
     pGenericDescr = setMetricEnums(pGenericDescr);
end

table = pGenericDescr;

%==============================
function descrTable = setMetricEnums(descrTable)
    s = size(descrTable);
    for idx = 1:s(1)
        mn = descrTable{idx,2};
        metricedataId = cv('find', 'all', 'metricdescr.name', mn);
        descrTable{idx,4} = cv('get', metricedataId, '.enumVal'); 
    end

