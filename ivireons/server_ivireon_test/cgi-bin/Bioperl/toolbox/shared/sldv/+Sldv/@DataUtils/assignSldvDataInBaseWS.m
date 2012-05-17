function varName = assignSldvDataInBaseWS(sldvData)
    varName = 'dvTcIns';    
    varList = evalin('base', sprintf('whos(''%s*'')',varName));
    counter = 0;
    while true
        if ~isempty(strmatch(varName,{varList.name},'exact'))
            varName = horzcat(varName,num2str(counter));            
            counter = counter+1;        
        else
            break;
        end        
    end  
    assignin('base', varName, sldvData);
end