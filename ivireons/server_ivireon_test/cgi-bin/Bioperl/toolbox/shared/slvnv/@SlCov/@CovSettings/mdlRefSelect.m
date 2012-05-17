 function covMdlRefSelUIH = mdlRefSelect(panelH, modelH)

%   Copyright 2009-2010 The MathWorks, Inc.

if panelH.getCovEnabled
    RecordCoverage = 'on';
else
    RecordCoverage = 'off';
end

%would need from ST
% getCovModelRefEnable
% getCovModelRefExcluded
% temporary get from the model
CovModelRefEnable = get_param(modelH, 'CovModelRefEnable');
CovModelRefExcluded = get_param(modelH,'CovModelRefExcluded');
covMdlRefSelUIH = handle(panelH.getCovMdlRefSelUIH);
%if it's invoked twice, e.g click twice on the browse button
if ~isempty(covMdlRefSelUIH) && ishandle(covMdlRefSelUIH) && ishandle(covMdlRefSelUIH.m_editor.getDialog)
    covMdlRefSelUIH.m_editor.show;
else

    covMdlRefSelUIH = cv.ModelRefSelectorUI(modelH, RecordCoverage, CovModelRefEnable, CovModelRefExcluded);
    covMdlRefSelUIH.m_panelH = panelH; 
    covMdlRefSelUIH.m_dlg = [];
end

