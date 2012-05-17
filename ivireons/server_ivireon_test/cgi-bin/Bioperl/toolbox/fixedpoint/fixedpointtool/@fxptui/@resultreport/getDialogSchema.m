function dlgstruct = getDialogSchema(h, name) %#ok
% GETDIALOGSCHEMA

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2009/11/13 04:18:49 $

dlgstruct = [];
if(isempty(h.result)); return; end;

widget1.Type = 'textbrowser';
widget1.MinimumSize = [600 600];
widget1.Tag = 'widget1';
widget1.Text = getHTML(h.result);

dlgstruct.DialogTitle = DAStudio.message('FixedPoint:fixedPointTool:resultreportTitle');
dlgstruct.DialogTag = 'Fixed_Point_Tool_Autoscale_Information';
dlgstruct.StandaloneButtonSet  = {'OK'};
dlgstruct.CloseCallback  = 'set(getaction(fxptui.getexplorer,''VIEW_AUTOSCALEINFO''),''on'',''off'');';
dlgstruct.LayoutGrid  = [1 1];
dlgstruct.RowStretch = 1;
dlgstruct.ColStretch = 1;
dlgstruct.Items = {widget1};


%--------------------------------------------------------------------------
function htm = getHTML(h)

ProposedDataTypeSummary = DAStudio.message('FixedPoint:fixedPointTool:resultreportProposedDataTypeSummary');
Value = DAStudio.message('FixedPoint:fixedPointTool:resultreportValue');
Percent = DAStudio.message('FixedPoint:fixedPointTool:resultreportPercent');
ProposedRepresentable = DAStudio.message('FixedPoint:fixedPointTool:resultreportProposedRepresentable');
CurrentlySpecified = DAStudio.message('FixedPoint:fixedPointTool:resultreportCurrentlySpecified');
ProposedDataType = DAStudio.message('FixedPoint:fixedPointTool:resultreportProposedDataType');

proposeddt = h.ProposedDT;
if(isequal(proposeddt, 'n/a'))
  proposeddt = DAStudio.message('FixedPoint:fixedPointTool:resultreportNone');
end

mdl = h.getbdroot;
appData = SimulinkFixedPoint.getApplicationData(mdl);

if ~isempty(h.DTGroup)
    sharedMinMax = SimulinkFixedPoint.Autoscaler.collectDTGSharedInfo(appData, h.DTGroup);
else
    sharedMinMax = [];
end
[~,sharedMinMax] = SimulinkFixedPoint.Autoscaler.determineAlertLevelFromResult(h, appData, sharedMinMax);

if isa(h, 'fxptui.sdoresult')
    % sdo result only display its name
    strTitle = h.Name;
else
    if isequal(h.PathItem, '1')
        strTitle = h.getFullName;
    else
        strTitle = [h.getFullName, ':', h.PathItem];
    end
end
htm = [...
  '<TABLE>', ...
  '<TR>', ...
  '<TH bgcolor=#CDCDCD colspan=3 align=left><FONT face=ariel size=5>' strTitle ...
  '<TR>', ...
  '<TD colspan=3 align=left><FONT face=ariel size=4><B>' ProposedDataTypeSummary ':</B><BR>', ...
  getHighLevelSummary(h) ,...
  getAlertHtml(sharedMinMax),...
  getShareDtHtml(h),...
  getConstrainedDtHtml(h), ...
  '<TR bgcolor=#CDCDCD>', ...
  '<TH align=left width=40%<FONT face=ariel size=4> ', ...
  '<TH align=left width=30%><FONT face=ariel size=4>' Value , ...
  '<TH align=left width=30%><FONT face=ariel size=4>' Percent '<BR>' ProposedRepresentable, ...
  '</TR>', ...
  '<TR><TD align=left><FONT face=ariel size=4><B>' CurrentlySpecified '</B><TD><FONT face=ariel size=4>' h.SpecifiedDT '<TD><FONT face=ariel size=4>', ...
  '<TR><TD align=left><FONT face=ariel size=4><B>' ProposedDataType '</B><TD><FONT face=ariel size=4>' proposeddt '<TD><FONT face=ariel size=4>', ...
  ];

sharedProposedDataType = DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedProposedDataType');
for iP = 1:length(sharedMinMax.propDTs)
    
    if ( iP > 1 ) && sharedMinMax.localPropDTValid
        
        thirdColStr = DAStudio.message('FixedPoint:fixedPointTool:resultreportPropDTVaries');
    else
        thirdColStr = '';
    end
    
    htm = [htm ...
        '<TR><TD align=left><FONT face=ariel size=4><B>' sharedProposedDataType '</B><TD><FONT face=ariel size=4>' sharedMinMax.propDTs{iP} '<TD><FONT face=ariel size=4>', ...
        thirdColStr]; %#ok
end

htm = [htm ...
  getRangeTableMaxMinHtml(h,sharedMinMax),...
  '<TR><TD colspan=3><HR>' ,...
  '</TABLE>', ...
  ];



%--------------------------------------------------------------------------
function res = getHighLevelSummary(h)
if isa(h, 'fxptui.sdoresult')
    sdosummary = [DAStudio.message('FixedPoint:fixedPointTool:resultreportSDOWS', class(h.daobject), h.daobject.slWorkspaceType), '<br>']; 
else
    sdosummary = '';
end
if scaleNeverProposed(h)
  res = statementNeverProposedHtml();
elseif scaleCanBeSet(h)
  res = statementYesScaleHtml(h);
else
  res = statementNoScaleHtml(h);
end
res = [sdosummary, res];
%----------------------------------------------------------------------------
function res = scaleCanBeSet(h)
% Needed a clearer way to determine this
res = false;
if (isempty(h.Comments) && ...
    ~isempty(h.ProposedDT) && ...
    ~isempty(strfind(h.ProposedDT,'fixdt')) )
  try
    not_used_dt_just_prevent_disp_drool = eval(h.ProposedDT); %#ok
    res = true;
  catch %#ok
  end
end

%----------------------------------------------------------------------------
function res = scaleNeverProposed(h)

res = isempty(h.Comments) && isempty(h.ProposedDT);

%----------------------------------------------------------------------------
function res = proposeSameAsCurSpec(h)
if strcmp(h.SpecifiedDT,h.ProposedDT)
  res = true;
  return;
end
specDT = eval(h.SpecifiedDT);
propDT = eval(h.ProposedDT);
if isequal(specDT,propDT)
  res = true;
  return;
end
res = SimulinkFixedPoint.DataType.areEquivalent(specDT,propDT);

%----------------------------------------------------------------------------
function htm = statementYesScaleHtml(h)
itemsSummary = {};
if proposeSameAsCurSpec(h)
  itemsSummary{1} = [DAStudio.message('FixedPoint:fixedPointTool:resultreportSameAsSpecified') '<br>'];
else
  specDT = eval(h.SpecifiedDT);
  if ( 1.0 ~= specDT.SlopeAdjustmentFactor || ...
      0.0 ~= specDT.Bias )
    itemsSummary{1} = [DAStudio.message('FixedPoint:fixedPointTool:resultreportReplaceSlopeBias') '<br>'];
  else
    propDT = eval(h.ProposedDT);
    
    if isequal(specDT.Signed, propDT.Signed) && isequal(specDT.Wordlength, propDT.Wordlength)     
        rangeBitsIncrease = specDT.FractionLength - propDT.FractionLength;
        if rangeBitsIncrease > 0
            itemsSummary{1} = [DAStudio.message('FixedPoint:fixedPointTool:resultreportMoveBitsRange', rangeBitsIncrease) '<br>'];
            itemsSummary{2} = ['<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportRangeIncrease', 2^rangeBitsIncrease) '<br>'];
            itemsSummary{3} = ['<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportPrecisionDecrease', 2^rangeBitsIncrease)];
        else
            itemsSummary{1} = [DAStudio.message('FixedPoint:fixedPointTool:resultreportMoveBitsPrecision', -rangeBitsIncrease) '<br>'];
            itemsSummary{2} = ['<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportRangeDecrease', 2^-rangeBitsIncrease) '<br>'];
            itemsSummary{3} = ['<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportPrecisionIncrease', 2^-rangeBitsIncrease)];
        end
    end
    if ~isequal(specDT.Signed, propDT.Signed)
        if specDT.Signed
            itemsSummary{1} = [DAStudio.message('FixedPoint:fixedPointTool:resultreportSignToUnsign') '<br>'];
        else
            itemsSummary{1} = [DAStudio.message('FixedPoint:fixedPointTool:resultreportUnsignToSign') '<br>'];
        end
    end
    if ~isequal(specDT.Wordlength, propDT.Wordlength) 
        itemsSummary{end+1} = [DAStudio.message('FixedPoint:fixedPointTool:resultreportChangeWordLength', specDT.Wordlength, propDT.Wordlength) '<br>'];
    end
  end
end

htm = getParagraph(itemsSummary);

%----------------------------------------------------------------------------
function res = statementNoScaleHtml(h)
items{1} = [DAStudio.message('FixedPoint:fixedPointTool:resultreportCanNotAutoscale') '<br>'];

[isInSubsysToScale, blkOutofSysStr] = isResultInSubsysToScale(h); 
if ~isInSubsysToScale
    items{end+1} = ['<b> - </b>' blkOutofSysStr '<br>'];
else
    for i = 1:numel(h.Comments)
        items{end+1} = ['<b> - </b>' getCommentSimpleIndex(h.Comments{i}) '<br>'];  %#ok
    end
    if isUnlockedFixdt(h) && isempty(h.ProposedRange)
        if(isempty(h.DesignMin) && isempty(h.DesignMax))
            items{end+1} = ['<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportNoDesignMinMax') '<br>'];
        end
        if(isempty(h.SimMin) && isempty(h.SimMax))
            items{end+1} = ['<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportNoSimMinMax') '<br>'];
            items{end+1} = [ ...
                '<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportUseSimMinMax') '<br>', ...
                '<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSetLoggingMode') '<br>', ...
                '<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportRunSimulation') '<br>', ...
                '<b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportProposeFractionLengths') '<br>'];
        end
    end
end
res = getParagraph(items);



%----------------------------------------------------------------------------
function res = statementNeverProposedHtml()

items{1} = DAStudio.message('FixedPoint:fixedPointTool:resultreportNeverAutoscale');
items{end+1} = ['<br><b> - </b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportNeverAutoscaleSolve')];
res = getParagraph(items);



%----------------------------------------------------------------------------
function res = isUnlockedFixdt(h)
% Needed a clearer way to determine this
res = false;

try
  locked = isequal('on', h.daobject.LockScale);

  if locked
      return
  end
catch %#ok
end

if (~isempty(h.SpecifiedDT) && ...
    ~isempty(strfind(h.SpecifiedDT,'fixdt')) )
  try
    not_used_dt_just_prevent_disp_drool = eval(h.SpecifiedDT); %#ok
    res = true;
  catch %#ok
  end
end

%---------------%----------------------------------------------------------------------------
function [res, str] = isResultInSubsysToScale(h)
% check the comments to verify this
res = true;
str = '';
try
  blkOutofSysStr = DAStudio.message('SimulinkFixedPoint:autoscaling:blockOutsideSubSystem'); 
  notInSubsys = ismember(h.Comments, blkOutofSysStr);

  if any(notInSubsys)
      res = false;
      str = blkOutofSysStr;
  end
catch %#ok
end

%-------------------------------------------------------------
function htm = getParagraph(items)
htm = '';
for iRow = 1:numel(items)
  htm = [htm items{iRow} ' ']; %#ok
end

%----------------------------------------------------------------------------
function htm = getRangeTableMaxMinHtml(h,sharedMinMax)
repMax = sharedMinMax.RepresentableMaxProposed;
repMin = sharedMinMax.RepresentableMinProposed;

if ~sharedMinMax.localPropDTValid && sharedMinMax.sharedPropDTValid && ~isempty(sharedMinMax.propDTs)
    
    sharedPropDt = eval(sharedMinMax.propDTs{1});

    [repMin, repMax] = SimulinkFixedPoint.DataType.getFixedPointRepMinMaxRwvInDouble(sharedPropDt);
end

htm = [...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=1>  ' ,...
    '<TD><FONT face=ariel size=1> ', ...
    '<TD><FONT face=ariel size=1> ' ,...
    ];

htm = [htm ...
  '<TR bgcolor=#EDEDED>' ,...
  '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportProposedRepresentableMax') '</B>' ,...
  '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(repMax),...
  '<TD><FONT face=ariel size=4>' getPosSafetyMargin(repMax,repMin,repMax),...
  ];

if ~isempty(sharedMinMax.DesignMax)
  curVal = sharedMinMax.DesignMax;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedDesignMax') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getPosSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

htm = [htm ...
  '<TR>' ,...
  '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportDesignMax') '</B>' ,...
  '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(h.DesignMax) ,...
  '<TD><FONT face=ariel size=4>' getPosSafetyMargin(h.DesignMax,repMin,repMax) ,...
  ];

if sharedMinMax.isUsingSimMinMax && ~isempty(sharedMinMax.SimMax)
  curVal = sharedMinMax.SimMax;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedSimulationMax') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getPosSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

if sharedMinMax.isUsingSimMinMax

 htm = [htm ...
  '<TR>' ,...
  '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSimulationMax') '</B>' ,...
  '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(h.SimMax) ,...
  '<TD><FONT face=ariel size=4>' getPosSafetyMargin(h.SimMax,repMin,repMax) ,...
  ];
end

if ~isempty(sharedMinMax.InitValueMax)
  curVal = sharedMinMax.InitValueMax;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedInitialValueMax') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getPosSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

if ~isempty(h.InitValueMax)
  curVal = h.InitValueMax;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportInitialValueMax') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getPosSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

if ~isempty(sharedMinMax.ModelRequiredMax)
  curVal = sharedMinMax.ModelRequiredMax;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedModelRequiredMax') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getPosSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

if ~isempty(h.ModelRequiredMax)
  curVal = h.ModelRequiredMax;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportModelRequiredMax') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getPosSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

  htm = [htm ...
    '<TR bgcolor=#EDEDED>' ,...
    '<TD align=left><FONT face=ariel size=1>  ' ,...
    '<TD><FONT face=ariel size=1> ', ...
    '<TD><FONT face=ariel size=1> ' ,...
    ];

if ~isempty(h.ModelRequiredMin)
  curVal = h.ModelRequiredMin;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportModelRequiredMin') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getNegSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

if ~isempty(sharedMinMax.ModelRequiredMin)
  curVal = sharedMinMax.ModelRequiredMin;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedModelRequiredMin') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getNegSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

if ~isempty(h.InitValueMin)
  curVal = h.InitValueMin;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportInitialValueMin') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getNegSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

if ~isempty(sharedMinMax.InitValueMin)
  curVal = sharedMinMax.InitValueMin;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedInitialValueMin') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getNegSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

if sharedMinMax.isUsingSimMinMax

 htm = [htm ...
  '<TR>' ,...
  '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSimulationMin') '</B>' ,...
  '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(h.SimMin) ,...
  '<TD><FONT face=ariel size=4>' getNegSafetyMargin(h.SimMin,repMin,repMax) ,...
  ];
end

if sharedMinMax.isUsingSimMinMax && ~isempty(sharedMinMax.SimMin)
  curVal = sharedMinMax.SimMin;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedSimulationMin') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getNegSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

htm = [htm ...
  '<TR>' ,...
  '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportDesignMin') '</B>' ,...
  '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(h.DesignMin) ,...
  '<TD><FONT face=ariel size=4>' getNegSafetyMargin(h.DesignMin,repMin,repMax) ,...
  ];

if ~isempty(sharedMinMax.DesignMin)
  curVal = sharedMinMax.DesignMin;
  htm = [htm ...
    '<TR>' ,...
    '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedDesignMin') '</B>' ,...
    '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(curVal) ,...
    '<TD><FONT face=ariel size=4>' getNegSafetyMargin(curVal,repMin,repMax) ,...
    ];
end

htm = [htm ...
  '<TR bgcolor=#EDEDED>' ,...
  '<TD align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportProposedRepresentableMin') '</B>' ,...
  '<TD><FONT face=ariel size=4>' compactButAccurateNum2Str(repMin),...
  '<TD><FONT face=ariel size=4>' getNegSafetyMargin(repMin,repMin,repMax),...
  ];

%----------------------------------------------------------------------------
function htm = getConstrainedDtHtml(h)
if ~h.hasDTConstraints
    % no DT constraints with this result
    htm = [];
    return;
end

htm = [ ...
  '<TR>', ...
  '<TD colspan=3 align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportConstrainedDataTypeSummary') ':</B><BR>', ...
  ];

constraintSet = h.DTConstraints;

srcBlkName = removeMdlNameFromBlkPath(constraintSet.SourceBlk.getFullName);
srcBlkHilite = ['<a href="matlab:fxptui.cb_highlightconstrainedblock">', srcBlkName, '</a> '];

if isequal(h.daobject, constraintSet.SourceBlk)
    curBlkStr = DAStudio.message('FixedPoint:fixedPointTool:resultreportThisBlkConstrainedDataType', srcBlkHilite, constraintSet.SourcePort, constraintSet.Comments);  
else
    curBlkStr = DAStudio.message('FixedPoint:fixedPointTool:resultreportConnectedBlkConstrainedDataType', srcBlkHilite, constraintSet.SourcePort, constraintSet.Comments);  
end


htm = [htm, ...
  curBlkStr, '<br>'];

%----------------------------------------------------------------------------
function htm = getShareDtHtml(h)

if isempty(h.DTGroup)
    htm = '';
    return;
end

str = DAStudio.message('FixedPoint:fixedPointTool:actionHILITEDTGROUP');
mdl = h.getbdroot;
run = h.Run;
listname = h.DTGroup;
appData = SimulinkFixedPoint.getApplicationData(mdl);
if isa(h, 'fxptui.sdoresult')
    % this result is a sdo
    str2 = DAStudio.message('FixedPoint:fixedPointTool:actionHILITESDO');
    strShareWithSDO = ['<a href="matlab:fxptui.cb_highlightconnectedblks">',  str2, '</a><br>'];   
else % ~isa(h, 'fxptui.sdoresult')  
    signame = '';
    strShareWithSDO = '';
    if ~isempty(h.actualSrcBlk)
        sameSrcSignal = [];
        for idxActSrc = 1:length(h.actualSrcBlk)
            sameSrcSignal = [sameSrcSignal, appData.dataset.getblklist4src(appData.ScaleUsing, h.actualSrcBlk{idxActSrc})]; %#ok<AGROW>
        end
    else
        sameSrcSignal = appData.dataset.getblklist4src(appData.ScaleUsing, h.daobject);
    end
    
    if ~isempty(sameSrcSignal)
        sdoResultsConnected = find(sameSrcSignal, '-isa', 'fxptui.sdoresult');
        for i = 1:length(sdoResultsConnected)
            signame = [sdoResultsConnected(i).name, '  ', signame]; %#ok<AGROW>
        end
    end
    if ~isempty(signame)
        strShareWithSDO = [DAStudio.message('FixedPoint:fixedPointTool:resultreportSDOConnected'), '<br>', signame];
    end
end
htm = [ ...
  '<TR>', ...
  '<TD colspan=3 align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultreportSharedDataTypeSummary') ':</B><BR>', ...
  ];
if isempty(h.DTGroup)
  htm = [htm DAStudio.message('FixedPoint:fixedPointTool:resultreportNoSharedDataType')];
else
  htm = [htm, ...
      DAStudio.message('FixedPoint:fixedPointTool:resultreportYesSharedDataType'), ...
      '<BR><a href="matlab:fxptui.highlightdtgroup(''' mdl ''',''' run ''',''' listname ''')">' str, '</a><br>'];
  if ~isempty(strShareWithSDO)
      htm = [htm, strShareWithSDO, '<br>'];
  end
end



%----------------------------------------------------------------------------
function htm = getAlertHtml(sharedMinMax)
if ( ~isempty(sharedMinMax.alertsRed   ) || ...
     ~isempty(sharedMinMax.alertsYellow) )
    
    htm = [ ...
        '<TR>', ...
        '<TD colspan=3 align=left><FONT face=ariel size=4><B>' DAStudio.message('FixedPoint:fixedPointTool:resultAlertInfoSummary') ':</B>', ...
        ];
    
    for iAlert = 1:length(sharedMinMax.alertsRed)
        
        htm = [htm, ...
               '<BR>', ...
               '<img src="', fullfile(matlabroot,'toolbox','fixedpoint','fixedpointtool','resources','failed.png'), '"> &nbsp;', ...
               sharedMinMax.alertsRed{iAlert}]; %#ok
    end
    
    for iAlert = 1:length(sharedMinMax.alertsYellow)
        
        htm = [htm, ...
               '<BR>', ...
               '<img src="', fullfile(matlabroot,'toolbox','fixedpoint','fixedpointtool','resources','warning.png'), '"> &nbsp;', ...
               sharedMinMax.alertsYellow{iAlert}]; %#ok
    end
    htm = [htm, '<br>'];
else
    htm = [];
end
%----------------------------------------------------------------------------
function safeMargStr = getSafetyMargin(curVal,repMin,repMax)

if isempty(curVal)

    safeMargStr = ''; %DAStudio.message('FixedPoint:fixedPointTool:resultreportNone');

elseif curVal == 0.0

  safeMargStr = '0';
    
elseif curVal > 0.0
  
    if isempty(repMax)

        safeMargStr = ''; %DAStudio.message('FixedPoint:fixedPointTool:resultreportNone');
    
    elseif repMax <= 0.0
        
        safeMargStr = ['<b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportOverflow') '<\b>'];
        %safeMargStr = DAStudio.message('FixedPoint:fixedPointTool:resultreportRepMaxInvalid');
        
    else
        safeMarg = 100 * abs(curVal)/abs(repMax);
        safeMargStr = [ sprintf('%5.2f',safeMarg), '%' ];
        if curVal > repMax
            safeMargStr = [safeMargStr, '  <b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportOverflow') '<\b>'];
        end
    end

else  %if curVal < 0.0

    if isempty(repMin)

        safeMargStr = ''; %DAStudio.message('FixedPoint:fixedPointTool:resultreportNone');

    elseif repMin >= 0.0
        
        safeMargStr = ['<b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportOverflow') '<\b>'];

    else
        safeMarg = 100 * abs(curVal)/abs(repMin);
        safeMargStr = [ sprintf('%5.2f',safeMarg), '%' ];
        if curVal < repMin
            safeMargStr = [safeMargStr, '  <b>' DAStudio.message('FixedPoint:fixedPointTool:resultreportOverflow') '<\b>'];
        end
    end
end

%----------------------------------------------------------------------------
function safeMargStr = getPosSafetyMargin(curVal,repMin,repMax)
safeMargStr = getSafetyMargin(curVal,repMin,repMax);

%----------------------------------------------------------------------------
function safeMargStr = getNegSafetyMargin(curVal,repMin,repMax)
safeMargStr = getSafetyMargin(curVal,repMin,repMax);

%----------------------------------------------------------------------------
function curComment = getCommentSimpleIndex(curComment)
% 
while(iscell(curComment))
  curComment = curComment{1};
end

%--------------------------------------------------------------------------
function decimalNumberStr = compactButAccurateNum2Str(origNumberInDouble)
% find compact string for cases that are messy when crossing the
% decimal to/from binary canyon
% For example, 0.05 can't be represented perfectly in binary representations
% such as IEEE floating point representations.
% For proof of this try the following snippet of MATLAB code,
%   ideallyEqualButNotBecauseOfErrorInBinaryRep = ( 3*0.01 == 0.15 )

decimalNumberStr = ''; %DAStudio.message('FixedPoint:fixedPointTool:resultreportNone');
if(isempty(origNumberInDouble)); return; end
if isa(origNumberInDouble,'embedded.fi')
    origNumberInDouble = double(origNumberInDouble);
end
for numDecimalDigits = 15:19
  decimalNumberStr = num2str(origNumberInDouble,numDecimalDigits);
  if eval(decimalNumberStr) == origNumberInDouble;
    break
  end
end

%--------------------------------------------------------------------------
function blkNameStr = removeMdlNameFromBlkPath(originalFullName)
if ischar(originalFullName)
    mdlName = bdroot(originalFullName);
   blkNameStr = regexprep(originalFullName, [mdlName,'/'] , '', 1);
else
    %not a string input, returns empty string
    blkNameStr = '';
end
% [EOF]
