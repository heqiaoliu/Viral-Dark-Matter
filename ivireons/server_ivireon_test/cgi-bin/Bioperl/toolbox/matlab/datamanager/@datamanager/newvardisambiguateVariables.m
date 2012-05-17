function newvardisambiguateVariables(fig,varNames,varValues,mfile,fcnname,okAction)

% Disambiguate variables in linked plots when creating new variables from
% brushing annotations.

% Copyright 2008-2010 The MathWorks, Inc.

% Find linked variable names
% Build table entries
tableData = javaArray('java.lang.Object',length(varNames),3);
brushMgr = datamanager.brushmanager;
for k=1:length(varNames)
    tableData(k,1) = java.lang.String(varNames{k});
    I = brushMgr.getBrushingProp(varNames{k},mfile,fcnname,'I');
    tableData(k,2) = java.lang.String(sprintf('%d out of %d',sum(I(:)),numel(I)));
    varDescriptions = workspacefunc('getabstractvaluesummariesj',{varValues{k}});
    if length(varDescriptions)>=1
        tableData(k,3) = varDescriptions(1);
    end
end

% Build and show Disambiguation dialog
dlg = javaObjectEDT('com.mathworks.page.datamgr.brushing.NewVarVariableDisambiguationDialog',...
    datamanager.getJavaFrame(fig),tableData,...
    {xlate('Name'),xlate('Number of Brushed Points'),xlate('Size')});


% Specify callbacks
set(handle(dlg.getOKButton,'callbackproperties'),...
        'ActionPerformedCallback',{@localOK dlg okAction varNames varValues mfile fcnname});
set(handle(dlg.getVariableComboBox.getEditor,'callbackproperties'),...
        'ActionPerformedCallback',{@localOK dlg okAction varNames varValues mfile fcnname});    

awtinvoke(dlg,'show()');
% Make sure the dialog is fully ready before interacting with it. We don't
% want callbacks executing before all java classes are fully initialized.
drawnow 

function localOK(es,ed,dlg,okAction,varNames,varValues,mfile,fcnname) %#ok<INUSL>

varName = char(dlg.getVarName);
if isempty(varName) || ~isvarname(varName)
    javaMethodEDT('showMessageDialog','com.mathworks.mwswing.MJOptionPane',...
        dlg,xlate('Invalid or empty variable name'), xlate('MATLAB'),...
        javax.swing.JOptionPane.ERROR_MESSAGE);
    awtinvoke(dlg,'show()');
    return
end

pos = dlg.getSelectionIndex+1;
if pos>=1
    writeData = feval(okAction,varNames{pos},varValues{pos},mfile,fcnname);
    if ~isempty(writeData)
        assignin('caller',varName,writeData)
    end
end
awtinvoke(dlg,'dispose()');

    