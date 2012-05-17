function checkCompileErr(obj)
%   Copyright 2007-2010 The MathWorks, Inc.

    origModelName = get_param(obj.OrigModelH,'Name');
    currentNags = slsfnagctlr('GetNags');    
    
    if ~isempty(currentNags)         
        sourceNames = {currentNags.sourceFullName};
        nagTypes = {currentNags.type};
        sourceModels = strtok(sourceNames,'/');
        msgs = [currentNags.msg];
        msgTypes = {msgs.type};                
        isRelavent = strcmp(sourceModels,origModelName) & strcmpi(nagTypes,'error') & ~strcmp(msgTypes,'Design Verifier');
        relaventNags = currentNags(isRelavent);        
        if ~isempty(relaventNags)
            generateErrorTitle(obj.OrigModelH, obj.SubSystemH);                           
        end        
    end    
end

function generateErrorTitle(origModelH, blockH)
    blockPath = get_name_strings(blockH);     
    errText = ...
        sprintf('Subsystem extraction for failed for subsystem ''%s''.',blockPath);
    nag = slprivate('create_nag','sldv', 'error', 'Subsystem Extraction',...
                errText, {}, origModelH);    
    slsfnagctlr('Naglog', 'push', nag);
end
               
function [fullPath,name] = get_name_strings(objH)
    name = get_param(objH,'Name');
    fullPath = cr_to_space(getfullname(objH));      
end
    
function out = cr_to_space(in)
    out = in;
    if ~isempty(in)
        out(in==10) = char(32);
    end
end
% LocalWords:  Naglog sldv
