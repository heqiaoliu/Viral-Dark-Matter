function description  = getCoverageDef(blockH, cvmetric)

    metricName = cvi.MetricRegistry.cvmetricToStr(cvmetric);
    metricName  = convertLegacyNames(metricName);
    metricEnum =  cvi.MetricRegistry.getEnum(metricName);  
    modelName = get_param(bdroot(blockH), 'name');
    modelcovId = cv('find', 'all', 'modelcov.name', modelName );
    rootId = cv('get', modelcovId, '.rootTree.child');
    blockCvId = cv('Private', 'find_block_cv_id', rootId, blockH);
    description  = [];
    switch metricName
        case 'decision'
            description = decision_details(blockCvId, metricEnum); 
        case 'condition'
            description = condition_details(blockCvId, metricEnum); 
        case 'mcdc'
            description = mcdc_details(blockCvId, metricEnum); 

    end
%==============================        

function res = convertLegacyNames(metricName)
names = {'condition', 'decision', 'mcdc', 'tableExec', 'sigrange', 'sigzise'} ;
res = metricName;
for idx = 1:numel(names)
    if ~isempty(findstr(metricName, names{idx}))
        res = names{idx};
        return;
    end
end
%==============================        
function description = table_details(blockCvId, metricEnum)
txtDetail = 1;
description = 'not ready';

%==============================        
function description = mcdc_details(blockCvId, metricEnum)
txtDetail = 1;
description = [];
   
mcdcentries = cv('MetricGet', blockCvId, metricEnum, '.baseObjs');
for mcdcId =  mcdcentries(:)'
    mcdcEntry.text = cv('TextOf',mcdcId,-1,[],txtDetail); 
    conditions  = cv('get',mcdcId ,'.conditions');

    for i=1:length(conditions)
        condId = conditions(i);
        condEntry.text = cv('TextOf',condId,-1,[],txtDetail); 
        mcdcEntry.condition(i) = condEntry;
    end
    if isempty(description)
        description = mcdcEntry;
    else
        description(end+1) = mcdcEntry; %#ok
    end
end           


%==============================        
function description = condition_details(blockCvId, metricEnum)
    txtDetail = 1;
    description = [];

    conditions = cv('MetricGet', blockCvId, metricEnum, '.baseObjs');
    for condId =  conditions(:)'
        condEntry.text = cv('TextOf',condId,-1,[],txtDetail); 
        if isempty(description)
            description = condEntry;
        else
            description(end+1) = condEntry; %#ok
        end
    end           

%==============================        
function description = decision_details(blockCvId, metricEnum)
    txtDetail = 1;
    description = [];

    decisions = cv('MetricGet', blockCvId, metricEnum, '.baseObjs');
    for decId = decisions(:)'
        d= [];
        outcomes  = cv('get',decId,'.dc.numOutcomes');
        d.text = cv('TextOf',decId,-1,[],txtDetail); 
        for i = 1:outcomes;

            out.text = cv('TextOf',decId,i-1,[],txtDetail);
            if ~isfield(d,'outcome')
                d.outcome = out;
            else
                d.outcome(end+1) = out;
            end
        end

        if isempty(description)
            description.decision = d;
        else
            description.decision(end+1) = d;
        end
    end
