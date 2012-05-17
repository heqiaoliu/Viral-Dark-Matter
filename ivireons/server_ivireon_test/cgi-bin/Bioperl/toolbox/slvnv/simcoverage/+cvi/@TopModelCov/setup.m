function [coveng modelcovId] = setup(modelH, varargin)

%   Copyright 2008 The MathWorks, Inc.

try

modelcovId =  cvmodel(modelH);

%if topModelCovId passed, means top model carries coveng
%thus, this modelcov does not need coveng
if isempty(varargin)
    coveng = cv('get', modelcovId, '.topModelCov');
    if isempty(coveng)
        coveng = cvi.TopModelCov(modelH);
        cv('set',modelcovId, '.topModelCov', coveng);
    else %
        coveng.oldModelcovIds = coveng.getAllModelcovIds;
        if ~isempty(coveng.oldModelcovIds)
            for cm = coveng.oldModelcovIds(:)'
                if ~cv('ishandle', cm)
                    coveng.oldModelcovIds =  [];
                end
            end
        end
        cv('set', modelcovId, '.refModelcovIds', []);        
    end
    topModelcovId = modelcovId;
    coveng.multiInstanceNormaModeSfMap = [];
else
    topModelcovId = varargin{1};
end
if ~cv('Private', 'cv_autoscale_settings', 'isForce', modelH)
    cv('Private', 'cvslhighlight' , 'revert', modelH);
end
cv('set', modelcovId, '.topModelcovId', topModelcovId); 


catch MEx 
    rethrow(MEx);
end


%================================
function id = cvmodel(slHandle)
	id  = get_param(slHandle, 'CoverageId');
	if id~=0
        return;
	end

    % Check if an existing modelcov object has the same name
    modelName = get_param(slHandle,'Name');
    modelIds = cv('find','all','modelcov.name',modelName);

    if length(modelIds)>1
        error('SLVNV:simcoverage:cvmodel:MoreThanOneId','Internal coverage tool error, more than one id for same model');
    end

    if isempty(modelIds)
    	id  = cv('new', 'modelcov' ...
    				,'.name',		modelName ...
    				,'.handle',		slHandle ...
    			 );
	else
        id = modelIds;
        cv('set',id,'modelcov.handle',slHandle);
    end
	set_param(slHandle,'CoverageId',id);
 