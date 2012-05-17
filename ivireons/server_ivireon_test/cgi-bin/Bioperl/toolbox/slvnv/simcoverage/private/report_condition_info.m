function cvstruct = report_condition_info(cvstruct,conditions, options)
% CONDITION_INFO - Synthesize decision coverage data
% for a list of condition objects.

% Copyright 1990-2008 The MathWorks, Inc.
% $Revision: 1.1.6.7 $  $Date: 2008/11/13 18:38:49 $

    global gcondition gFrmt;
    condCnt = length(conditions);
    
    % Preallocate the structure entries
    cvstruct.conditions = struct( ...
                            'cvId',                 num2cell(conditions), ...
                            'text',                 cell(1,condCnt), ...
                            'trueCnts',             cell(1,condCnt), ...
                            'falseCnts',            cell(1,condCnt), ...
                            'covered',              cell(1,condCnt));
    
    for i = 1:condCnt
        condId = conditions(i);
        cvstruct.conditions(i).text = cvi.ReportUtils.fix_html(cv('TextOf',condId,-1,[],gFrmt.txtDetail)); 
        [trueCountIdx, falseCountIdx, activeCondIdx,hasVariableSize]  = cv('get',condId,'.coverage.trueCountIdx','.coverage.falseCountIdx', '.coverage.activeCondIdx','.hasVariableSize');
        cvstruct.conditions(i).trueCnts = gcondition(trueCountIdx+1,:);
        cvstruct.conditions(i).falseCnts = gcondition(falseCountIdx+1,:);
        cvstruct.conditions(i).isActive = true;
        cvstruct.conditions(i).isVariable = hasVariableSize;
        if (hasVariableSize)
            cvstruct.conditions(i).isActive =  any(gcondition(activeCondIdx+1,:));
        end
        cvstruct.conditions(i).covered = cvstruct.conditions(i).trueCnts(end)>0 & cvstruct.conditions(i).falseCnts(end)>0;
    end



    
