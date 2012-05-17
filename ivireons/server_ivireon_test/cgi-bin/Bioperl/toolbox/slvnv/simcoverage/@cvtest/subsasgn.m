function cvtest = subsasgn( cvtest, property, value)


%   Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/05/14 18:02:18 $

id = cvtest.id;

switch length(property)
case 1
	if ~isequal(property.type,'.'), invalid_subscript; end
	
	% If this is a settings. property check that the metric is 
	% visible
    if strncmpi('settings.',property.subs,10)
        metric = lower(property.subs(11:end));
        enumVal = cvi.MetricRegistry.getEnum(metric);
        if enumVal>-1
            cv('set',id,['testdata.settings.' metric],value);
        end
    elseif strncmpi('mdlrefsettings.', property.subs,16)
        field = lower(property.subs(17:end));
        cv('set',id,['testdata.mldref_' field],value);
    else
        
    	switch lower(property.subs)
    	case 'id'
    		read_only(property.subs);
    	case 'label',
    		cv('set',id,'testdata.label',value);
    	case 'modelcov',
    		read_only(property.subs);
    	case 'setupcmd',
    		cv('set',id,'testdata.mlSetupCmd',value);
    	case 'settings',
    	    metNames = fieldnames(value);
            for idx = 1:length(metNames)
                metricName  = metNames{idx};
                if strcmpi(metricName, 'designverifier')
                   metricName = 'testobjectives';
                end
                setMetric(cvtest, metricName, value.(metNames{idx}));
            end
        case 'modelrefsettings',
            enableStr = value.enable;
            if ~ischar(enableStr)
                enableStr = 'on';
            end
            cv('set',id, 'testdata.mldref_enable',  enableStr);
            cv('set',id, 'testdata.mldref_excludeTopModel', value.excludeTopModel);
            cv('set',id, 'testdata.mldref_excludedModels', value.excludedModels);
            
        case 'emlsettings',
           cv('set',id, 'testdata.covExternalEMLEnable',  value.enableExternal);
        case 'options',
           cv('set',id, 'testdata.forceBlockReductionOff',  value.forceBlockReduction);
           
    	otherwise
    		error('SLVNV:simcoverage:subsasgn:InvalidProperty','Invalid cvtest property name: "%s"',sprintf('.%s',property.subs));
    	end
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
        metricName = property(2).subs;
        if strcmpi(metricName, 'designverifier')
           metricName = 'testobjectives';
        end
        setMetric(cvtest, metricName, value);
    case 'modelrefsettings'  
            field = property(2).subs;
            if strcmpi(field, 'enable') &&  ~ischar(value)
                value = 'on';
            end
            cv('set',id,['testdata.mldref_' field], value);
    case 'emlsettings'  
            cv('set',id,'testdata.covExternalEMLEnable',value);
    case 'options'
           cv('set',id, 'testdata.forceBlockReductionOff',  value);

    otherwise
        invalid_subscript;
    end
otherwise
	invalid_subscript;
end

%======================
function invalid_subscript
	error('SLVNV:simcoverage:subsasgn:InvalidSubscript','Invalid subscripted reference to a cvtest object.');

function read_only(propName)
    error('SLVNV:simcoverage:subsasgn:ReadOnlyProperty','The property "%s" is read only',sprintf('.%s',propName));
