%   Copyright 2010 The MathWorks, Inc.
   
function mdlRefClose(this)
    covMdlRefSelUIH = handle(this.getCovMdlRefSelUIH);
    if ~isempty(covMdlRefSelUIH) && ishandle(covMdlRefSelUIH) && ishandle(covMdlRefSelUIH.m_editor.getDialog)
            covMdlRefSelUIH.closeCallback([Simulink.ModelReferenceHierarchyExplorerUI.getUITagBase 'Hidden_Destroy']);
    end
    
