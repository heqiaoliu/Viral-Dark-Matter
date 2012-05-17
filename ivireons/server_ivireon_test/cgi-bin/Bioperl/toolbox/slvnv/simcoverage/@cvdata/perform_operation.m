function metricStruct = perform_operation(lhs_cvdata,rhs_cvdata,opStr,opChar)
%PERFORM_OPERATION - Produce the data from a binary operation on cvdata objects
%
%   METRICSTRUCT = PERFORM_OPERATION(LHS_CVDATA,RHS_CVDATA,OPSTR)  A data
%   operation expressed as the string OPSTR in the form u=f(lhs,rhs) is 
%   performed on the raw execution counts in the cvdata objects LHS_CVDATA
%   and RHS_CVDATA.  The raw counts from each metric are aggregated and
%   the collection of metrics is returned in METRICSTRUCT.

%   Bill Aldrich
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $

% NOTE: Agruments should have been verified before calling this function


if ~valid(lhs_cvdata)
    error(cv('Private','errmsg_invalid_cvdata', 1));
end
if ~valid(rhs_cvdata)
    error(cv('Private','errmsg_invalid_cvdata',2));
end

[lhs_metricNames lhs_toMetricNames] = cvi.ReportUtils.getMetricNames(lhs_cvdata);
[rhs_metricNames rhs_toMetricNames] = cvi.ReportUtils.getMetricNames(rhs_cvdata);

metricNames = union(lhs_metricNames, rhs_metricNames);
toMetricNames = union(lhs_toMetricNames, rhs_toMetricNames);

metricStruct = [];

ref.type = '.';
ref.subs = 'rootID';
rootId = subsref(lhs_cvdata,ref);

ref.subs = 'metrics';
lhsMetrics = subsref(lhs_cvdata,ref);
rhsMetrics = subsref(rhs_cvdata,ref);


% Loop through each possible metric
for metricI = metricNames(:)'
    metric = metricI{1};
    if  ~strcmpi(metric, 'testobjectives')
        lhs = lhsMetrics.(metric);
        rhs = rhsMetrics.(metric);
        metricData =  processMetric(rootId, metric, lhs, rhs, opStr , opChar);
        if ~isempty(metricData) && ...
            ~strcmpi(metric,'sigrange') && ~strcmpi(metric,'sigsize') 
                metricEnumVal = cvi.MetricRegistry.getEnum(metric);    
                metricData = cv('ProcessData',rootId, metricEnumVal, metricData);
        end
        metricStruct.(metric) = metricData;
    end
end
if ~isempty(toMetricNames)
    ref(1).type = '.';
    ref(1).subs = 'metrics';
    ref(2).type = '.';
    ref(2).subs = 'testobjectives';
    ref(3).type = '.';
    tmpMtricStruct = [];
    for metricI = toMetricNames(:)'
        metric = metricI{1};
        ref(3).subs = metric;
        lhs = subsref(lhs_cvdata,ref);
        rhs = subsref(rhs_cvdata,ref);
        metricData = processMetric(rootId,  metricI{1}, lhs, rhs, opStr , opChar);
        if ~isempty(metricData)
            metricenumValue = cvi.MetricRegistry.getEnum(metric);    
            metricdataId = cv('new', 'metricdata', '.metricName', metric, '.metricenumValue',metricenumValue);
            cv('set',metricdataId ,'.data.rawdata', metricData,'.size', numel(metricData)); 
            metricData = cv('ProcessTOData',rootId, metricdataId);
            cv('delete',metricdataId ); 
        end
        tmpMtricStruct.(metric) = metricData;

    end
    metricStruct.testobjectives = tmpMtricStruct;
end
%=================================
function  u = processMetric(rootId,  metric, lhs, rhs, opStr , opChar)
    
    metricEnumVal = cvi.MetricRegistry.getEnum(metric);    
    % Get raw input data
    u = [];
    % Check if the operation can be performed
    if (isempty(lhs) || isempty(rhs))
        u = [];
        if (opChar == '+')
            if (isempty(lhs) && ~isempty(rhs))
                u=rhs;
            else
                if (~isempty(lhs) && isempty(rhs))
                    u=lhs;
                end; %if
            end; %if
        end; %if
        if (opChar == '-')
            if (isempty(lhs) && ~isempty(rhs))
                u=zeros(1, length(rhs));
            else
                if (~isempty(lhs) && isempty(rhs))
					u=lhs;
                end; %if
            end; %if
        end; %if
    else
        % Special case for MCDC coverage
        if( strcmp(metric,'mcdc'))
            u = cv('BitOp',lhs,opChar,rhs);
            u = adjust_variable_size_data(rootId, metricEnumVal, u, lhs, rhs); 

        elseif strcmpi(metric,'sigrange') || strcmpi(metric,'sigsize') 
            minlhs = lhs(1:2:(end-1));
            minrhs = rhs(1:2:(end-1));
            maxlhs = lhs(2:2:end);
            maxrhs = rhs(2:2:end);
            u = zeros(size(lhs));
            
            switch(opChar)
            case '+',
                u(1:2:(end-1)) = min([minlhs minrhs]'); %#ok<UDIM> % min 
                u(2:2:end) = max([maxlhs maxrhs]'); %#ok<UDIM> % max
                
            case '*',
                minout = max([minlhs minrhs]')'; %#ok<UDIM> % min
                maxout = min([maxlhs maxrhs]')'; %#ok<UDIM> % max
                u(1:2:(end-1)) = minout; % min
                u(2:2:end) = maxout; % max
                infIdx = find(maxout<minout);
                if ~isempty(infIdx)
                    u(2*infIdx - 1) = inf; % min
                    u(2*infIdx) = -inf; % max
                end

            case '-',
                % This operation is not completely well defined because we
                % don't distinguish between open and closed intervals.  
                %
                % Base the result on the following axioms:
                % range - point = range
                % point - range = empty if range overlaps, pt otherwise.
                % range - range = range difference
                % empty - anything = empty
                %
                empty_lhs = maxlhs<minlhs;
                
                emptyIdx = empty_lhs | (~empty_lhs & minrhs<=minlhs & maxrhs>=maxlhs);
                
                inter_min = max([minlhs minrhs]')'; %#ok<UDIM> % min
                inter_max = min([maxlhs maxrhs]')'; %#ok<UDIM> % max
                
                hasMinOverlap = inter_min==minlhs;
                hasMaxOverlap = inter_max==maxlhs;
                 
                
                minout = inter_max;
                minout(~hasMinOverlap) = minlhs(~hasMinOverlap);
                maxout = inter_min;
                maxout(~hasMaxOverlap) = maxlhs(~hasMaxOverlap);
                
                minout(emptyIdx) = inf;
                maxout(emptyIdx) = -inf;
                
                u(1:2:(end-1)) = minout; % min
                u(2:2:end) = maxout; % max
            end
            
            
        else
            % Generic case
            eval(opStr);
            u = adjust_variable_size_data(rootId, metricEnumVal, u, lhs, rhs); 
        end

    end
    
%================================    
 function u = adjust_variable_size_data(rootId, metricEnumVal, u, lhs, rhs)

     cvId = cv('get',rootId,'.topSlsf');
    if cv('MetricGet', cvId , metricEnumVal, '.hasVariableSize')
        allMetrics = cvi.MetricRegistry.getAllEnums;    
        
        allSlsfObjs = [cv('DecendentsOf',cvId) cvId];        
        [metricObjs varShallowIdxs varDeepIdxs] = cv('MetricGet', allSlsfObjs, metricEnumVal,'.baseObjs',...
                '.dataCnt.varShallowIdx','.dataCnt.varDeepIdx');
        u  = get_max_idx(varShallowIdxs, u, lhs, rhs);            
        u  = get_max_idx(varDeepIdxs, u, lhs, rhs);            
        switch (metricEnumVal)
            case allMetrics.decision
                fieldTxt = '.dc.activeOutcomeIdx';
            case allMetrics.condition
                fieldTxt = '.coverage.activeCondIdx';
            case allMetrics.mcdc
                fieldTxt = '.dataBaseIdx.activeCondIdx';
            otherwise
                fieldTxt = '';
        end
        if ~isempty(fieldTxt)
            u =  fix_metrics(metricObjs, u, lhs, rhs, fieldTxt);
        end
    end
%================================    
 function u =  fix_metrics(metricObjs, u, lhs, rhs, fieldTxt)    
    activeCondIdx = cv('get',metricObjs, fieldTxt)';
    u = get_max_idx(activeCondIdx, u, lhs, rhs);
    
%================================
function u = get_max_idx(activeIdx, u, lhs, rhs)
    activeIdx(activeIdx < 0) = [];
    if ~isempty(activeIdx)
        activeIdx = activeIdx + 1;
        u(activeIdx) = max(lhs(activeIdx), rhs(activeIdx));
    end
