function pcgd_DataObjectWizard(objName)
    % 0.) get the data

%   Copyright 2007 The MathWorks, Inc.

    pcgDemoData = evalin('base','pcgDemoData');
    
    % 1.) Get the data objects
   [eDiag,pcgDemoData] = RTWDemos.pcgd_getExplorDialogs(pcgDemoData,2);     
   dataObj = pcgDemoData.explDiags.workspace.getChildren;
    
    % 2.) Get the names of all the objects
    numObj = length(dataObj);
    inx = 1;
    while (inx <= numObj)
        if (strcmp(objName,dataObj(inx).getDisplayLabel))
            diagHand                     = DAStudio.Dialog(dataObj(inx));
            pcgDemoData.openDiags{end+1} = diagHand;
        end
        inx = inx + 1;
    end % ends the while

    % Save off the data
    assignin('base','pcgDemoData',pcgDemoData);
end

