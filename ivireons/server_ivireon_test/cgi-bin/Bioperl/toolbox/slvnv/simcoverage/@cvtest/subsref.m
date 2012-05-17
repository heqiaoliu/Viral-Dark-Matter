function value = subsref( cvtest, property)

%   Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/05/14 18:02:19 $

id = cvtest.id;

switch length(property)
case 1
	if ~isequal(property.type,'.'), invalid_subscript; end
	switch lower(property.subs)
	case 'id'
		value = id;
	case 'rootpath',
		value = cv('get',id,'testdata.rootPath');
	case 'label',
		value = cv('get',id,'testdata.label');
	case 'modelcov',
		value = cv('get',id,'testdata.modelcov');
	case 'setupcmd',
		value = cv('get',id,'testdata.mlSetupCmd');
	case 'settings',
	    metricNames = cvi.MetricRegistry.getAllMetricNames;
	    value = [];
        for metric = metricNames(:)'
            cm = metric{1};
            if strcmpi(cm, 'testobjectives') 
                cm = 'designverifier';
            end
            value.(cm) = getMetricValue(id, metric{1});
        end
   	case 'modelrefsettings',
            value.enable = cv('get',id, 'testdata.mldref_enable');
            value.excludeTopModel = cv('get',id, 'testdata.mldref_excludeTopModel');
            value.excludedModels = cv('get',id, 'testdata.mldref_excludedModels');
    case 'emlsettings',
           value.enableExternal = cv('get',id, 'testdata.covExternalEMLEnable');
    case 'options',
           value.forceBlockReduction = cv('get',id, 'testdata.forceBlockReductionOff');
    	
	otherwise
		error('SLVNV:simcoverage:subsref:InvalidPropName','Invalid  cvtest property name: "%s"',sprintf('.%s',property.subs));
	end
case 2
    if ~isequal(property(1).type,'.')
        invalid_subscript; 
    end
    if ~isequal(property(2).type,'.')
        invalid_subscript; 
    end
    switch lower(property(1).subs)
    case 'settings'  
        metric = property(2).subs;
        if strcmpi(metric, 'designverifier') 
            metric = 'testobjectives';
        end
        value = getMetricValue(id, metric);
    case 'modelrefsettings'
        field = property(2).subs;
        value = cv('get',id,['testdata.mldref_' field]);
    case 'emlsettings'
        value = cv('get',id,'testdata.covExternalEMLEnable');
    case 'options',
        value = cv('get',id,'testdata.forceBlockReductionOff');        
    otherwise
        invalid_subscript;
    end
otherwise
	invalid_subscript;
end
%=========================
function value = getMetricValue(id, metricName)
    
    enumVal = cvi.MetricRegistry.getEnum(metricName);
    if enumVal<0
      invalid_subscript;
    end
    value = cv('get',id,['testdata.settings.' metricName]);


%========================
function invalid_subscript
	error('SLVNV:simcoverage:subsref:InvalidSubscript','Invalid subscripted reference to a cvtest object.');


