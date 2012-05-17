
%   Copyright 2009 The MathWorks, Inc.


function [metricenumVals metricdescrIds] = registerMetric(metrics)
%can be a metric name or a class handle from cvmetric package
metricdescrIds =[];
metricenumVals = [];
if isempty(metrics)
    return;
end
metricNames = [];
if iscell(metrics) && ischar(metrics{1})
    if ischar(metrics)
        metrics = {metrics}; 
    end
 
    for idx = 1:numel(metrics)
        metricHandle = strToCvmetric(metrics{idx});
        checkPackage(metricHandle);
        metricNames{end+1} = cvi.MetricRegistry.cvmetricToStr(metricHandle); %#ok<AGROW>
    end
    
else
    
    s1 = size(metrics); %numel does not work see g490353
    for idx = 1:s1(2)
        if iscell(metrics)
            metricHandle = metrics{idx};
        else
            metricHandle = metrics(idx);
        end
        checkPackage(metricHandle );
        metricNames{end+1} = cvi.MetricRegistry.cvmetricToStr(metricHandle ); %#ok<AGROW>
    end
end


[metricdescrIds metricenumVals] = registerMetricenum(metricNames);

%=========================================
function checkPackage(cvmetricHandles)

mc = metaclass(cvmetricHandles);

if ~strcmpi(mc.ContainingPackage.Name, 'cvmetric')
    error('SLVNV:simcoverage:subsasgn:InvalidTestObjectiveMetric','Invalid test objective metric.');
end

        
%=========================================
function [metricdescrIds metricenumVals] = registerMetricenum(metricNames)

allmetricdescrIds = cv('find', 'all', '.isa', cv('get', 'default', 'metricdescr.isa'));
metricdescrIds = [];
metricenumVals = [];
for idx = 1:numel(metricNames)
    [metricdescrId enumVal allmetricdescrIds] = addMetricdescr(metricNames{idx}, allmetricdescrIds);
    metricdescrIds(end+1) = metricdescrId ; %#ok<AGROW>
    allmetricdescrIds(end+1) = metricdescrId ; %#ok<AGROW>
    metricenumVals(end+1) = enumVal ; %#ok<AGROW>
end
%============================
function [metricdescrId enumVal allmetricdescrIds] = addMetricdescr(metricName, allmetricdescrIds)
    metricdescrId = cv('find', allmetricdescrIds, '.name', metricName);
    if isempty(metricdescrId)
         metricdescrId = cv('new','metricdescr', '.name', metricName);
         ddEnumVals= cvi.MetricRegistry.getDDEnumVals;
         enumVal = numel(allmetricdescrIds) + ddEnumVals.MTRC_TESTOBJECTIVE;
         cv('set',metricdescrId, '.enumVal', enumVal);
    else
        enumVal = cv('get', metricdescrId, '.enumVal');
    end
%============================
function cvmetricHandle = strToCvmetric(metricName)

metricName = strrep(metricName,'_','.');

cvmetricHandle = evalin('base', metricName);
 
