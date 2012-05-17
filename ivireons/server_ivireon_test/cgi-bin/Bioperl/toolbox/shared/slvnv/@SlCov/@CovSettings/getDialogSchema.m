function dlg = getDialogSchema(this, ~)

%   Copyright 2009-2010 The MathWorks, Inc.


tag = 'SlCov_CovSettings_';
widgetId = 'SlCov.CovSettings.';

tabs.Name = 'tabs';
tabs.Type = 'tab';
tabs.Tag = [tag tabs.Name];
tabs.WidgetId = [widgetId tabs.Name];


tabs.Tabs = {getTabCoverage(this, tag, widgetId ), ...
    getTabResults(this, tag, widgetId ), ...
    getTabReport(this, tag,widgetId ), ...
    getTabOptions(this, tag, widgetId )
    };
if strcmpi(cv('Feature', 'enable coverage filter'), 'on')
    tabs.Tabs{end+1} = getTabFilter(this, tag, widgetId );
end

%it should not be here for configcomp
dlg.DialogTitle  = DAStudio.message('Slvnv:simcoverage:dialogTitle');
dlg.DialogTag  = 'Coverage_Settings';
dlg.PostApplyMethod = 'postApply';
dlg.CloseMethod = 'postClose';
dlg.DialogRefresh = true;
dlg.HelpMethod  = 'SlCov.CovSettings.help';
dlg.HelpArgs    = {};
dlg.Items = {tabs};

%====================
function tab = getTabCoverage(this, tag, widgetId )
tab.Name = DAStudio.message('Slvnv:simcoverage:coverageTab');

recordCoverage.Name = DAStudio.message('Slvnv:simcoverage:coverageForThisModel',get_param(this.modelH, 'name'));
recordCoverage.Type = 'checkbox';
recordCoverage.Bold = true;
recordCoverage.Source = this; 
recordCoverage.ObjectProperty = 'recordCoverage';
recordCoverage.MatlabMethod = 'setRecordCoverage';
recordCoverage.MatlabArgs= {'%source','%value'};
recordCoverage.RowSpan = [1 1]; 
recordCoverage.ColSpan = [1 1]; 
recordCoverage.Tag = [tag recordCoverage.ObjectProperty];
recordCoverage.WidgetId = [widgetId recordCoverage.ObjectProperty];
recordCoverage.Mode = true;
recordCoverage.DialogRefresh = true;

covPath.Type = 'text';
covPath.Name  = this.covPathStatus;
covPath.ObjectProperty = 'covPath';
covPath.Source = this;
covPath.RowSpan = [2 2]; 
covPath.ColSpan = [1 1]; 
covPath.Enabled = this.RecordCoverage;
covPath.Tag = [tag covPath.ObjectProperty];
covPath.WidgetId = [widgetId covPath.ObjectProperty];

subSysBrowse.Name  = DAStudio.message('Slvnv:simcoverage:subSysBrowse');
subSysBrowse.Type  = 'pushbutton';
subSysBrowse.Source = this;
subSysBrowse.RowSpan = [3 3]; 
subSysBrowse.ColSpan = [2 2]; 
subSysBrowse.Alignment = 8;
subSysBrowse.Enabled = this.RecordCoverage;
subSysBrowse.ObjectMethod = 'subSysBrowseCallback';
subSysBrowse.Tag = [tag  subSysBrowse.ObjectMethod];
subSysBrowse.WidgetId = [widgetId subSysBrowse.ObjectMethod];


groupEnableThis.Type = 'group';
groupEnableThis.LayoutGrid = [3 2];
groupEnableThis.Items = {recordCoverage, covPath, subSysBrowse};

modelRefEnable.Name = DAStudio.message('Slvnv:simcoverage:modelRefEnable');
modelRefEnable.RowSpan = [1 1]; 
modelRefEnable.ColSpan = [1 1];
modelRefEnable.Alignment = 1;
modelRefEnable.Type = 'checkbox';
modelRefEnable.Bold = true;
modelRefEnable.Mode = true; 
modelRefEnable.Source = this; 
modelRefEnable.ObjectProperty = 'modelRefEnable'; 
modelRefEnable.MatlabMethod = 'setMdlRefEnable';
modelRefEnable.MatlabArgs= {'%source','%value'};
modelRefEnable.Tag = [tag  modelRefEnable.ObjectProperty];
modelRefEnable.WidgetId = [widgetId modelRefEnable.ObjectProperty];
modelRefEnable.DialogRefresh = true;

modelRefStatus.RowSpan = [2 2]; 
modelRefStatus.ColSpan = [1 1]; 
modelRefStatus.Alignment = 1;
modelRefStatus.Type = 'text';
modelRefStatus.Enabled = this.modelRefEnable;
modelRefStatus.Name = this.mdlRefSelStatus;
modelRefStatus.ObjectProperty = 'mdlRefSelStatus';
modelRefStatus.Tag = [tag  modelRefStatus.ObjectProperty];
modelRefStatus.WidgetId = [widgetId modelRefEnable.ObjectProperty 'text'];

%modelRefStatus.Enable = this.covModelRefEnable;
modelRefBrowse.Name  = DAStudio.message('Slvnv:simcoverage:modelRefBrowse');
modelRefBrowse.Type  = 'pushbutton';
modelRefBrowse.Source = this;
modelRefBrowse.RowSpan = [3 3]; 
modelRefBrowse.ColSpan = [2 2]; 
modelRefBrowse.Alignment = 8;
modelRefBrowse.DialogRefresh = true;
modelRefBrowse.ObjectMethod = 'mdlRefBrowseCallback';
modelRefBrowse.Enabled = this.modelRefEnable;
modelRefBrowse.Tag = [tag  modelRefBrowse.ObjectMethod];
modelRefBrowse.WidgetId = [widgetId modelRefBrowse.ObjectMethod];

groupEnableMdlRef.Type = 'group';
groupEnableMdlRef.LayoutGrid = [3 2];
groupEnableMdlRef.Items = {modelRefEnable, modelRefStatus, modelRefBrowse};

externalEMLEnable.Name  = DAStudio.message('Slvnv:simcoverage:externalEMLEnable');
externalEMLEnable.Type = 'checkbox';    
externalEMLEnable.ObjectProperty = 'covExternalEMLEnable';
externalEMLEnable.Bold = true;
externalEMLEnable.DialogRefresh = true;
externalEMLEnable.Mode = true;
groupEnableExtEML.Type = 'group';
groupEnableExtEML.Items = {externalEMLEnable};

%groupMetrics = getNewGroupMetrics(this, tag, widgetId);
groupMetrics = getGroupMetrics(this);
groupMetrics.Enabled = this.recordCoverage || this.modelRefEnable || this.covExternalEMLEnable;

tab.Items = {groupEnableThis,groupEnableMdlRef, groupEnableExtEML, groupMetrics};

%=======================================
function groupMetrics = getGroupMetrics(this)
groupMetrics.Type = 'group';
groupMetrics.Name = DAStudio.message('Slvnv:simcoverage:groupMetrics');


metricStruct = cvi.MetricRegistry.getMetricsMetaInfo;
groupMetrics.LayoutGrid = [ceil(numel(metricStruct) * 0.5) 2];
for idx = 1:numel(metricStruct)
    metricsEnable.Type = 'checkbox';
    metricsEnable.Name = metricStruct(idx).dialogLabel;
    metricsEnable.RowSpan = [metricStruct(idx).gridRow metricStruct(idx).gridRow]; 
    metricsEnable.ColSpan = [metricStruct(idx).gridColumn metricStruct(idx).gridColumn]; 
    metricsEnable.Source = this; 
    metricsEnable.ObjectProperty = metricStruct(idx).cvtestFieldName;
    groupMetrics.Items{idx} = metricsEnable;
end

%=======================================
function groupMetrics = getNewGroupMetrics(this, tag, widgetId)
groupMetrics.Type = 'group';
groupMetrics.Name = 'Coverage metrics';


structMetrics = addMetricGroup(this, tag, widgetId, ...
                                'Structural', 'cv',  {'Decision', 'Condition', 'Mcdc'}, {'cv_decision', 'cv_condition', 'cv_mcdc'} );
signalMetrics = addMetricGroup(this, tag, widgetId, ...
                                'Singal', 'signal',  {'Signal Range', 'Signal Size'}, {'signal_range', 'singal_size'} );
sldvMetrics = addMetricGroup(this, tag, widgetId, ...
                               'Simulink Design Verifier', 'sldv',  {'Test', 'Proof', 'Condition', 'Assumption'}, {'sldv_proof', 'sldv_test', 'sldv_condition','sldv_assumption',} );

groupMetrics.Items = {structMetrics, signalMetrics, sldvMetrics};

%====================
function groupMetricHead = addMetricGroup(this, tag, widgetId, groupName, groupTag, metricNames, metricTags)
metricsEnable.Type = 'checkbox';
metricsEnable.Name = groupName;
metricsEnable.RowSpan = [1 1]; 
metricsEnable.ColSpan = [1 1]; 
metricsEnable.Mode = true;
metricsEnable.Source = this; 
metricsEnable.ObjectProperty = ['m_metricGroupEnable_' groupTag];
metricsEnable.Tag = [tag  metricsEnable.ObjectProperty ];
metricsEnable.WidgetId = [widgetId metricsEnable.ObjectProperty ];


if ~isfield(this.m_metricGroupVisible, groupTag)  
    this.m_metricGroupVisible.(groupTag) = false;
end
metricsExpand.Type  = 'pushbutton';
if this.m_metricGroupVisible.(groupTag)
    metricsExpand.Name  = '<<';
else
    metricsExpand.Name  = '>>';
end
metricsExpand.RowSpan = [1 1]; 
metricsExpand.ColSpan = [4 4]; 
metricsExpand.Source = this; 
metricsExpand.DialogRefresh = true;
metricsExpand.ObjectMethod = 'metricGroupEnableCallback';
metricsExpand.MethodArgs = {groupTag};
metricsExpand.ArgDataTypes = {'string'};
metricsExpand.Tag = [tag metricsExpand.ObjectMethod '_' groupTag];
metricsExpand.WidgetId = [widgetId metricsExpand.ObjectMethod ];


groupMetrics.Items = {};

for idx = 1:numel(metricNames)
    mn = metricNames{idx};
    metricEnable.Type = 'checkbox';
    metricEnable.Name = mn;
    metricEnable.Tag = [tag mn metricTags{idx}];
    metricEnable.WidgetId = [widgetId mn];

    groupMetrics.Items{end + 1} = metricEnable;
end

groupMetrics.Type = 'panel';
groupMetrics.Alignment = 3;
groupMetrics.Visible = this.m_metricGroupVisible.(groupTag);

groupMetricHead.Type = 'panel';
groupMetricHead.LayoutGrid = [2 2];
groupMetricHead.ColStretch = [3 1];
groupMetricHead.Items = {metricsEnable, metricsExpand, groupMetrics};


%====================
function tab = getTabOptions(this, tag, widgetId)
tab.Name = DAStudio.message('Slvnv:simcoverage:options');
panel.Items = {};
panel.Type = 'panel';
optionsTable = cv('Private', 'cv_dialog_options');
[m, ~] = size(optionsTable );
for idx = 1:m
    fieldName= optionsTable{idx,4};
    chkb.Name = optionsTable{idx,1};
    chkb.Type = 'checkbox';
    chkb.ObjectProperty = fieldName;
    chkb.Value = this.(fieldName);
    if isempty(panel.Items)
        panel.Items = {chkb};
    else
        panel.Items{end+1} = chkb;
    end
end

panel.Alignment = 2; 
tab.Items = {panel};

%====================
function tab = getTabReport(this, tag, widgetId)
tab.Name = DAStudio.message('Slvnv:simcoverage:reporting');
makeReport.Name = DAStudio.message('Slvnv:simcoverage:htmlReport');
makeReport.Type = 'checkbox';
makeReport.ObjectProperty = 'covHtmlReporting';
makeReport.RowSpan = [1 1]; 
makeReport.ColSpan = [1 1]; 
makeReport.Tag = [tag makeReport.ObjectProperty ];
makeReport.WidgetId = [widgetId makeReport.ObjectProperty ];
makeReport.DialogRefresh = true;
makeReport.Mode = true;

reportSettings.Name  = DAStudio.message('Slvnv:simcoverage:htmlSettings');
reportSettings.Type  = 'pushbutton';
reportSettings.Source = this;
reportSettings.RowSpan = [1 1]; 
reportSettings.ColSpan = [2 2]; 
reportSettings.Alignment = 8;
reportSettings.ObjectMethod = 'reportSettingsCallback';
reportSettings.Enabled = this.covHtmlReporting;


% displayReport.Name = 'Display report';
% displayReport.Type = 'checkbox';
% displayReport.ObjectProperty = 'displayReport';
% displayReport.Value = this.displayReport;

covCumulativeReport.Type = 'radiobutton';
covCumulativeReport.Entries = {DAStudio.message('Slvnv:simcoverage:covCumulativeReport1'), DAStudio.message('Slvnv:simcoverage:covCumulativeReport2')};
covCumulativeReport.ObjectProperty = 'covCumulativeReport';
covCumulativeReport.RowSpan = [2 2]; 
covCumulativeReport.ColSpan = [1 2]; 
covCumulativeReport.Enabled = this.covHtmlReporting;
covCumulativeReport.Tag = [tag covCumulativeReport.ObjectProperty ];
covCumulativeReport.WidgetId = [widgetId covCumulativeReport.ObjectProperty ];
covCumulativeReport.Mode = true;
covCumulativeReport.DialogRefresh = true;


covCompData.Name = DAStudio.message('Slvnv:simcoverage:covCompData');
covCompData.Type = 'edit';
covCompData.NameLocation = 2;
covCompData.RowSpan = [3 3]; 
covCompData.ColSpan = [1 2]; 
covCompData.ObjectProperty = 'covCompData';
covCompData.Enabled = this.covHtmlReporting && ...
                      strcmpi(this.covCumulativeReport,DAStudio.message('Slvnv:simcoverage:covCumulativeReport2'));
covCompData.Tag = [tag covCompData.ObjectProperty ];
covCompData.WidgetId = [widgetId covCompData.ObjectProperty ];


panel.Type = 'panel';
panel.Alignment = 2; 
panel.LayoutGrid = [3 2];
panel.Items = {makeReport, reportSettings, covCumulativeReport, covCompData};
tab.Items = {panel};

%====================
function tab = getTabResults(this, tag, widgetId)

tab.Name = DAStudio.message('Slvnv:simcoverage:resultsTab');
saveCumulativeToWorkspaceVar.Name = DAStudio.message('Slvnv:simcoverage:saveCumulativeToWorkspaceVar');
saveCumulativeToWorkspaceVar.Type = 'checkbox';
saveCumulativeToWorkspaceVar.ObjectProperty = 'covSaveCumulativeToWorkspaceVar';
saveCumulativeToWorkspaceVar.DialogRefresh = true;
saveCumulativeToWorkspaceVar.Mode = true;
saveCumulativeToWorkspaceVar.Tag = [tag saveCumulativeToWorkspaceVar.ObjectProperty ];
saveCumulativeToWorkspaceVar.WidgetId = [widgetId saveCumulativeToWorkspaceVar.ObjectProperty ];

cumulativeVarName.Name = DAStudio.message('Slvnv:simcoverage:cumulativeVarName');
cumulativeVarName.Type = 'edit';
cumulativeVarName.ObjectProperty = 'covCumulativeVarName';
cumulativeVarName.Enabled = this.covSaveCumulativeToWorkspaceVar;
cumulativeVarName.Tag = [tag cumulativeVarName.ObjectProperty ];
cumulativeVarName.WidgetId = [widgetId cumulativeVarName.ObjectProperty ];


group1.Type = 'group';
group1.RowSpan = [1 1]; 
group1.ColSpan = [1 1]; 
group1.Items = {saveCumulativeToWorkspaceVar, cumulativeVarName};

saveSingleToWorkspaceVar.Name = DAStudio.message('Slvnv:simcoverage:saveSingleToWorkspaceVar');
saveSingleToWorkspaceVar.Type = 'checkbox';
saveSingleToWorkspaceVar.ObjectProperty = 'covSaveSingleToWorkspaceVar';
saveSingleToWorkspaceVar.DialogRefresh = true;
saveSingleToWorkspaceVar.Mode = true;   
saveSingleToWorkspaceVar.Tag = [tag saveSingleToWorkspaceVar.ObjectProperty ];
saveSingleToWorkspaceVar.WidgetId = [widgetId saveSingleToWorkspaceVar.ObjectProperty ];


varName.Name = DAStudio.message('Slvnv:simcoverage:covSaveName');
varName.Type = 'edit';
varName.ObjectProperty = 'covSaveName';
varName.Enabled = this.covSaveSingleToWorkspaceVar;

incVarName.Name = DAStudio.message('Slvnv:simcoverage:incVarName');
incVarName.Type = 'checkbox';
incVarName.ObjectProperty = 'covNameIncrementing';

group2.Type = 'group';
group2.RowSpan = [2 2]; 
group2.ColSpan = [1 1]; 
group2.Items = {saveSingleToWorkspaceVar, varName, incVarName};


covReportOnPause.Name = DAStudio.message('Slvnv:simcoverage:covReportOnPause');
covReportOnPause.Type = 'checkbox'; 
covReportOnPause.RowSpan = [3 3]; 
covReportOnPause.ColSpan = [1 1]; 
covReportOnPause.ObjectProperty = 'covReportOnPause';

modelDisplay.Name = DAStudio.message('Slvnv:simcoverage:modelDisplay');
modelDisplay.Type = 'checkbox';
modelDisplay.RowSpan = [4 4]; 
modelDisplay.ColSpan = [1 1]; 
modelDisplay.ObjectProperty = 'modelDisplay';

panel.Type = 'panel';
panel.Alignment = 2; 

panel.LayoutGrid = [4 1];

panel.Items = {group1, group2, covReportOnPause, modelDisplay};
tab.Items = {panel};
%====================
function tab = getTabFilter(this, tag, widgetId )


filterFileName.Name = 'Filter filename:';
filterFileName.Type = 'edit';
filterFileName.RowSpan = [1 1]; 
filterFileName.ColSpan = [1 1]; 
filterFileName.ObjectProperty = 'covFilter';

filterFileBrowse.Name = 'Browse...';
filterFileBrowse.Type = 'pushbutton';
filterFileBrowse.RowSpan = [1 1]; 
filterFileBrowse.ColSpan = [2 2]; 
filterFileBrowse.ObjectMethod = 'filterFileBrowseCallback';

filterEditor.Name = 'Open';
filterEditor.Type = 'hyperlink';
filterEditor.RowSpan = [2 2]; 
filterEditor.ColSpan = [1 1]; 
filterEditor.ObjectMethod = 'startFilterEdit';

panel.Type = 'panel';
panel.Items = {filterFileName, filterFileBrowse,filterEditor};
panel.LayoutGrid = [2 2];
panel.Alignment = 2;
tab.Name = 'Filter';
tab.Items = {panel};
