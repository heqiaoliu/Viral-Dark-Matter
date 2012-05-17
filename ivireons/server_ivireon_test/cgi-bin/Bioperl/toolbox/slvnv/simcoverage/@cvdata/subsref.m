function value = subsref( cvdata, property)

%   Bill Aldrich
%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/10/24 19:41:03 $

id = cvdata.id;

if (id ~= 0) && (~cv('ishandle', id) || isempty(cv('get',id,'.isa')) || ... 
              cv('get',id,'.isa')~= cv('get','default','testdata.isa'))
	error('SLVNV:simcoverage:subsref:NonExistentData', [ 10 ...
        'Coverage object refers to non-existent data (ID=%d).  The coverage data that' 10 ...
        'is referenced in a cvdata object is removed from memory when its model is' 10 ...  
        'closed and the cvdata object cannot be used afterwards.'], id); 	
		
elseif id>0,
    switch length(property)
    case 1
    	if ~isequal(property.type,'.'), invalid_subscript; end
    	switch lower(property.subs)
    	case 'id'               
    		value = id;
    	case 'test'             
    	 	value = cvtest(id);
    	case 'rootid'   
            rootId = get_root(id);
            if rootId
                value = rootId;
            else
                value = [];
            end
    	case 'checksum'  
            rootId = get_root(id);
            if rootId
                value.u1 = cv('get',rootId,'root.checksum.u1');
                value.u2 = cv('get',rootId,'root.checksum.u2');
                value.u3 = cv('get',rootId,'root.checksum.u3');
                value.u4 = cv('get',rootId,'root.checksum.u4');
            else
                value = [];
            end         
       	case 'starttimeenum'  
            value = cv('get',id,'testdata.startTime');     
    	case 'stoptimeenum'         
            value = cv('get',id,'testdata.stopTime');     

    	case 'starttime'  
            value = datestr(cv('get',id,'testdata.startTime'));     
    	case 'stoptime'         
            value = datestr(cv('get',id,'testdata.stopTime'));     
    	case 'metrics'
    	    metricNames = cvi.MetricRegistry.getAllMetricNames;
    	    value = [];
            for metric = metricNames(:)'
                if strcmpi(metric{1}, 'testobjectives')
                    value.testobjectives  = getAllToMetricValues(id);
                else
                    value.(metric{1}) = getMetricValue(id, metric{1});
                end
            end
            
            value.testobjectives  = getAllToMetricValues(id);

    	case 'modelinfo'
    	    fieldNames = {'modelVersion','creator','lastModifiedDate','inlineParams','blockReductionStatus','conditionallyExecuteInputs','logicBlkShortcircuit'};
    	    value = [];
            for fn = fieldNames(:)'
                value.(fn{1}) = cv('get',id,['.' fn{1}]);
            end
    	otherwise
    		error('SLVNV:simcoverage:subsref:InvalidProperty','Invalid  cvtest property name: "%s"',sprintf('.%s',property.subs));
    	end
    case 2
    	if ~isequal(property(1).type,'.'), invalid_subscript; end
        switch lower(property(1).subs)
        case 'checksum'  
            if ~isequal(property(2).type,'.'), invalid_subscript; end
            rootId = get_root(id);
            switch lower(property(2).subs)
            case 'u1'
                if rootId
                    value = cv('get',rootId,'root.checksum.u1');
                else
                    value = [];
                end
            case 'u2'
                if rootId
                    value = cv('get',rootId,'root.checksum.u2');
                else
                    value = [];
                end
            case 'u3'
                if rootId
                    value = cv('get',rootId,'root.checksum.u3');
                else
                    value = [];
                end
            case 'u4'
                if rootId
                    value = cv('get',rootId,'root.checksum.u4');
                else
                    value = [];
                end
            otherwise
                invalid_subscript
            end
        case 'metrics'
            if ~isequal(property(2).type,'.'), invalid_subscript; end
            metricName = property(2).subs;
            if strcmpi(metricName, 'testobjectives')
                value = getAllToMetricValues(id);
            else
                value = getMetricValue(id, metricName);
            end
            
            
        case 'modelinfo'
            if ~isequal(property(2).type,'.'), invalid_subscript; end
            par = property(2).subs;
            value = cv('get',id,['.' par]);
        otherwise
            invalid_subscript

        end
        case 3
           	if ~strcmpi(property(1).type,'.') && ...
                ~strcmpi(property(1).subs, 'metrics') && ...
                ~strcmpi(property(2).type,'.') && ... 
                ~strcmpi(property(2).subs, 'testobjectives') && ...
                ~strcmpi(property(3).type, '.')
                invalid_subscript; 
            end
            
            
            metricdataIds = cv('get',id, 'testdata.testobjectives');
            if ~isempty(metricdataIds)
                metricEnumVal = cvi.MetricRegistry.getEnum(property(3).subs);
                if metricdataIds(metricEnumVal) ~= 0
                    value = cv('get', metricdataIds(metricEnumVal), '.data.rawdata');
                else
                    value = [];
                end
            else
                value = [];
            end
            
    otherwise
        invalid_subscript
    end
else    % id==0
    rootID = cvdata.localData.rootId;
    if ~cv('ishandle', rootID)
        error('SLVNV:simcoverage:subsref:NonExistentData', [ 10 ...
        'Coverage object refers to non-existent root data (rootID=%d).  The coverage data that' 10 ...
        'is referenced in a cvdata object is removed from memory when its model is' 10 ...  
        'closed and the cvdata object cannot be used afterwards.'], rootID);    
    else
        switch length(property)
        case 1
            if ~isequal(property.type,'.'), invalid_subscript; end
            switch lower(property.subs)
            case 'id'               
                value = id;
            case 'test'             
                value = [];
            case 'rootid'   
                value = cvdata.localData.rootId;
            case 'checksum'  
                value = cvdata.localData.checksum;
            case 'starttime'  
                value = datestr(cvdata.localData.startTime);     
            case 'stoptime'         
                value = datestr(cvdata.localData.stopTime);     
            case 'starttimeenum'  
                value = cvdata.localData.startTime;     
            case 'stoptimeenum'         
                value = cvdata.localData.stopTime;     
            case 'metrics'
                value = cvdata.localData.metrics; 
            case 'modelinfo'
                value = cvdata.localData.modelinfo; 
            otherwise
                error('SLVNV:simcoverage:subsref:InvalidPropertyName','Invalid  cvtest property name: "%s"',sprintf('.%s',property.subs));
            end
        case 2
            if ~isequal(property(1).type,'.'), invalid_subscript; end
            switch lower(property(1).subs)
            case 'checksum'  
                if ~isequal(property(2).type,'.')
                    invalid_subscript; 
                end
                switch lower(property(2).subs)
                case 'u1'
                    value = cvdata.localData.checksum.u1;
               case 'u2'
                    value = cvdata.localData.checksum.u2;
                case 'u3'
                    value = cvdata.localData.checksum.u3;
                case 'u4'
                    value = cvdata.localData.checksum.u4;
                otherwise
                    invalid_subscript
                end
            case 'metrics'
                if ~isequal(property(2).type,'.'), invalid_subscript; end
                par = property(2).subs;
                value = cvdata.localData.metrics.(par);
            case 'modelinfo'
                if ~isequal(property(2).type,'.'), invalid_subscript; end
                par = property(2).subs;
                value =cvdata.localData.modelinfo.(par);
            otherwise
                invalid_subscript
            end
       case 3
           	if ~strcmpi(property(1).type,'.') && ...
                ~strcmpi(property(1).subs, 'metrics') && ...
                ~strcmpi(property(2).type,'.') && ... 
                ~strcmpi(property(2).subs, 'testobjectives') && ...
                ~strcmpi(property(3).type, '.')
                invalid_subscript; 
            end
            if ~isfield(cvdata.localData.metrics.testobjectives, property(3).subs)
                value = [];
            else
                value = cvdata.localData.metrics.testobjectives.(property(3).subs);
            end
        otherwise
            invalid_subscript
        end
    end
end
%=========================
function value = getAllToMetricValues(id)
    value = [];
    metricdataIds = cv('get',id, 'testdata.testobjectives');
    metricdataIds(metricdataIds == 0) = [];
    if ~isempty(metricdataIds) 
        for idx = 1:numel(metricdataIds)
            if metricdataIds(idx) ~= 0
                data = cv('get', metricdataIds(idx), '.data.rawdata');
                metricName = cv('get', metricdataIds(idx), '.metricName');
                value.(metricName) = data;
            end
        end
    end
%=========================
function value = getMetricValue(id, metricName)
    
    enumVal = cvi.MetricRegistry.getEnum(metricName);
    if enumVal<0
      invalid_subscript;
    end
    value = cv('get',id,['testdata.data' metricName]);
      

%=========================

function invalid_subscript
	error('SLVNV:simcoverage:subsref:InvalidSubscript','Invalid subscripted reference to a cvtest object.');


function rootId = get_root(id)
    rootId = cv('get',id,'.linkNode.parent');
    if ~cv('ishandle',rootId) || cv('get','default','root.isa') ~= cv('get',rootId,'.isa')
        warning('SLVNV:simcoverage:subsref:UnresolvedRootBlock','Root block not resolved');
        rootId = 0;
    end
