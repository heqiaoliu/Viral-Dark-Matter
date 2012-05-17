function cvstruct = report_mcdc_info(cvstruct,mcdcentries, options)

% Copyright 2003-2008 The MathWorks, Inc.

    global gmcdc gFrmt;
    gFrmt.txtDetail = 2;
    
	mcdcCnt = length(mcdcentries);
	
	cvstruct.mcdcentries = struct( ...
	                        'cvId',         num2cell(mcdcentries), ...
	                        'text',         cell(1,mcdcCnt), ...
	                        'numPreds',     cell(1,mcdcCnt), ...
	                        'predicate',    cell(1,mcdcCnt), ...
	                        'covered',      cell(1,mcdcCnt));
	
    testCnt = length(cvstruct.tests);
    if testCnt==1,
        coumnCnt = 1;
    else
        coumnCnt = testCnt+1;
    end
    
	%Total col is last col
	if options.cumulativeReport
		coumnCnt = testCnt;
	end;

    
    for i=1:mcdcCnt
        mcdcId = mcdcentries(i);
        [subconditions,numPreds,predAchievIdx,truePathIdx,falsePathIdx,activeCondIdx,hasVariableSize ] = cv('get',mcdcId, ...
                        '.conditions', ...
                        '.numPredicates', ...
                        '.dataBaseIdx.predSatisfied', ...
                        '.dataBaseIdx.trueTableEntry', ...
                        '.dataBaseIdx.falseTableEntry',...
                        '.dataBaseIdx.activeCondIdx',...
                        '.hasVariableSize');
                        
        cvstruct.mcdcentries(i).cvId = mcdcId; 
        cvstruct.mcdcentries(i).text = cvi.ReportUtils.fix_html(cv('TextOf',mcdcId,-1,[],gFrmt.txtDetail)); 
        cvstruct.mcdcentries(i).numPreds = numPreds;
        
        isActive = true;
        if hasVariableSize 
            cvstruct.mcdcentries(i).isVariable = true;
            cvstruct.mcdcentries(i).isActive = any(gmcdc(activeCondIdx+1,end));
        else
            cvstruct.mcdcentries(i).isActive = true;
            cvstruct.mcdcentries(i).isVariable = false;
        end

        actCondIdx  = 0;
        if hasVariableSize 
            actCondIdx = min(gmcdc(activeCondIdx+1,end)); 
        end
        
        for k=1:numPreds
                condId = subconditions(k);
 
                predEntry.text = cvi.ReportUtils.fix_html(cv('TextOf',condId,-1,[],gFrmt.txtDetail)); 
                predEntry.achieved = gmcdc(predAchievIdx+k,:)==4;
                
                condIsActive = true;
                predEntry.isVariable = false;
                if hasVariableSize
                    condIsActive =  k <= actCondIdx;
                    predEntry.isVariable = true;
                end
                predEntry.isActive = isActive & condIsActive;
                
                for j=1:coumnCnt
                        status = gmcdc(predAchievIdx+k,j);
                        if status == 0
                            true_text = 'NA';
                            false_text = 'NA';
                        else
                            true_text = cv('McdcPathText',mcdcId,gmcdc(truePathIdx+k,j));
                            false_text = cv('McdcPathText',mcdcId,gmcdc(falsePathIdx+k,j));
                            if hasVariableSize 
                                true_text = markUnusedConditions(true_text, subconditions, k);
                                false_text = markUnusedConditions(false_text, subconditions, k);
                            else
                                true_text = make_n_bold(true_text,k);
                                false_text = make_n_bold(false_text,k);
                            end
                            % Neither True or False achieved
                            % Only False achieved
                            if status == 1 || status == 3 
                                 true_text = ['(' true_text ')']; %#ok
                            end
                            % Neither True or False achieved
                            % Only True achieved
                            if status == 1 || status == 2 
                                 false_text = ['(' false_text ')']; %#ok
                            end
                        end
                        predEntry.trueCombo{j} = true_text;
                        predEntry.falseCombo{j} = false_text;
                end
                
                
                cvstruct.mcdcentries(i).predicate(k) = predEntry;
        end
        if sum(gmcdc(predAchievIdx+1:numPreds,end)>0)==numPreds
            cvstruct.mcdcentries(i).covered = 1;
        else
            cvstruct.mcdcentries(i).covered = 0;
        end
    end
%================================
function text = markUnusedConditions(text,subconditions, boldIdx)
global gcondition;
  for k = 1:numel(subconditions)
     condId = subconditions(k);
     condActiveCondIdx  = cv('get',condId, '.coverage.activeCondIdx');
     if min(gcondition(condActiveCondIdx+1,end)) == 0
        text(k) = ' ';
     end
  end
  if boldIdx <= numel(text)
      text = make_n_bold(text, boldIdx);
  end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE_N_BOLD - enclose the nth character in <B> </B>.

function out = make_n_bold(str,n)
    if (n>length(str))
        out = str;
    else
        if (n==1)
            out = sprintf('<font color="blue"><B>%s</B></font>%s',str(1),str(2:end));
        elseif (n == length(str))
            out = sprintf('%s<font color="blue"><B>%s</B></font>',str(1:(end-1)),str(end));
        else
            out = sprintf('%s<font color="blue"><B>%s</B></font>%s',str(1:(n-1)),str(n),str((n+1):end));
        end
    end
        



