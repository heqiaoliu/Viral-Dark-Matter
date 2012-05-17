function cvstruct = report_decision_info(cvstruct,decisions, options)
% DECISION_INFO - Synthesize decision coverage data
% for a all the decision objects.

% Copyright 1990-2008 The MathWorks, Inc.
% $Revision: 1.1.6.9 $  $Date: 2008/11/13 18:38:52 $

    global gdecision gFrmt;


    for i=1:length(decisions)
        decId = decisions(i);
        decData = [];
        decData.cvId = decId;
        decData.text = cvi.ReportUtils.fix_html(cv('TextOf',decId,-1,[],gFrmt.txtDetail)); 
        [outcomes,startIdx, activeOutcomeIdx, hasVariableSize]  = cv('get',decId,'.dc.numOutcomes','.dc.baseIdx', '.dc.activeOutcomeIdx', '.hasVariableSize');
        decData.numOutcomes = outcomes;
        if outcomes==1
            decData.totals = gdecision(startIdx+1,:);
        else
            decData.totals = sum(gdecision((startIdx+1):(startIdx+outcomes),:));
        end
        if outcomes==1
            decData.outCnts = gdecision((startIdx+1):(startIdx+outcomes),:)>0;
        else
            decData.outCnts = sum(gdecision((startIdx+1):(startIdx+outcomes),:)>0);
        end
        
        decData.isVariable = hasVariableSize;
        if (hasVariableSize)
            decData.hasVariableOutcome = true;
            decData.maxActOutcome = gdecision(activeOutcomeIdx + 1,end);                        
            decData.isActive = any(decData.maxActOutcome > 0);
            decData.covered = (decData.outCnts(end)==decData.maxActOutcome);
        else
            nel = numel(decData.outCnts);
            decData.hasVariableOutcome = false;
            decData.maxActOutcome = zeros(1,nel);            
            decData.isActive = true;            
            decData.covered = (decData.outCnts(end)==outcomes);            
        end
        maxActOutcome = max(decData.maxActOutcome);

        for j = 1:outcomes;
            if  ~hasVariableSize || (hasVariableSize && decData.isActive && j <= maxActOutcome ) 
                decData.outcome(j).isActive = true;
                decData.outcome(j).execCount = gdecision(startIdx+j,:);                
            else
                decData.outcome(j).isActive = false;
                decData.outcome(j).execCount = 0;
            end
            decData.outcome(j).text = cvi.ReportUtils.fix_html(cv('TextOf',decId,j-1,[],gFrmt.txtDetail));
        end
        cvstruct.decisions(i) = decData;
    end




    
