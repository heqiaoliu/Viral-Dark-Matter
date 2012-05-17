function numEvents=cvEventParser(inputStr)
    str=cvFilterCommentsBracketQuote(inputStr);
    str=strtok(str, '/{');
    numEvents=0; 
    while (length(str)>0) 
        % we need to check whether it is a "after" or "before"
        while(~isempty(str)&&isspace(str(1)))
            str(1)=[];
        end
        if (isempty(str))
            break;
        end
        if (length(str)>=5&&strcmp(str(1:5),'after'))
            if (~strcmp(str(6),'('))
                error('SLVNV:simcoverage:cv_EventParser:ParserError','Error in cvEventParser: no (');
            end
            endIdx=cvRemoveParenthesis(str,7);
            str=['after',str(endIdx:end)];
            numEvents=numEvents+2;
        elseif (length(str)>=6&&strcmp(str(1:6),'before'))
            if (~strcmp(str(7),'('))
                error('SLVNV:simcoverage:cv_EventParser:ParserError','Error in cvEventParser: no (');
            end
            endIdx=cvRemoveParenthesis(str,8);
            str=['before',str(endIdx:end)];
            numEvents=numEvents+2;
        else
            numEvents=numEvents+1;
        end;
        [head, str]=strtok(str,'|');
        % Take care of '|'
        if ~isempty(str)&&strcmp(str(1),'|')
            str(1)='';
        end
        % Take care of '||'
        if ~isempty(str)&&strcmp(str(1),'|')
            str(1)='';
        end
    end

    
function endIdx=cvRemoveParenthesis(inputStr,startIdx)
    endIdx=startIdx;
    while (endIdx<=length(inputStr)) 
        if strcmp(inputStr(endIdx),')')
            endIdx=endIdx+1;
            return;
        elseif strcmp(inputStr(endIdx),'(')
            endIdx=cvRemoveParenthesis(inputStr,endIdx+1);
            continue;
        end;
        endIdx=endIdx+1;
    end
    
    
    

function str=cvFilterCommentsBracketQuote(parsingStr);
    str='';
    i=1;
    while (i<=length(parsingStr))
        % check if it is a '*/' or '/*'
        if i<length(parsingStr)
            if strcmp(parsingStr(i:i+1),'/*') 
                i=cvRemoveComments(parsingStr,i+2); % Idx after */
                continue;
            end
        end
        if strcmp(parsingStr(i),'''')
           i=cvRemoveQuote(parsingStr,i+1); % Idx after '
           continue;
        elseif strcmp(parsingStr(i),'[')
           i=cvRemoveBracket(parsingStr,i+1); % Idx after ]
           continue;
        end;
 
        str=[str,parsingStr(i)];
        i=i+1;
    end
 
% cvRemoveBracket removes part of the string
% surrounded by brackets
% startIdx: the index after '['
% endIdx: the index after ']'
function endIdx=cvRemoveQuote(parsingStr,startIdx)
    endIdx=startIdx;
    while (endIdx<=length(parsingStr))
        % check if it is a '['
        if endIdx<length(parsingStr)
            if strcmp(parsingStr(endIdx:endIdx+1),'/*')
                endIdx=cvRemoveComments(endIdx+2);
                continue;
            end
        end;        

        if strcmp(parsingStr(endIdx),'''')
            endIdx=endIdx+1;
            return;
        elseif strcmp(parsingStr(endIdx),'[')
            endIdx=cvRemoveBracket(parsingStr,endIdx+1);
            continue;
        elseif strcmp(parsingStr(endIdx),']')
            endIdx=endIdx+1;
            return;
        end;
        endIdx=endIdx+1;
    end
    
% cvRemoveQuote removes part of the string
% surrounded by brackets
% startIdx: the index after ''''
% endIdx: the index after ''''
function endIdx=cvRemoveBracket(parsingStr,startIdx)
    endIdx=startIdx;
    while (endIdx<=length(parsingStr))
 
        if endIdx<length(parsingStr)
            if strcmp(parsingStr(endIdx:endIdx+1),'/*')
                endIdx=cvRemoveComments(endIdx+2);
                continue;
            end
        end;        
        if strcmp(parsingStr(endIdx),']')
            endIdx=endIdx+1;
            return;
        elseif strcmp(parsingStr(endIdx),'[')
            endIdx=cvRemoveBracket(parsingStr,endIdx+1);
            continue;
        end;
        endIdx=endIdx+1;
    end    
% cvRemoveComment removes comments.
% startIdx: the index after '/*'
% endIdx: the index after '*/'
function endIdx=cvRemoveComments(parsingStr,startIdx)
    endIdx=startIdx;
    while (endIdx<=length(parsingStr))
        if endIdx<length(parsingStr)
            if strcmp(parsingStr(endIdx:endIdx+1),'/*')
                endIdx=cvRemoveComments(parsingStr,endIdx+2);
                continue;
            elseif strcmp(parsingStr(endIdx:endIdx+1),'*/')
                endIdx=endIdx+2;
                return;
            end
        end;
        endIdx=endIdx+1;
    end
        

    