function schema
%schema

%   Copyright 2009-2010 The MathWorks, Inc.

   
pkg   = findpackage('SlCov');

clsH = schema.class(pkg,...
   'CovSettings');
%=============================
p = schema.prop(clsH,'modelH','handle');
p.Visible = 'off';
%=============================
p = schema.prop(clsH,'m_dlg','handle');
%=============================
p = schema.prop(clsH,'m_covMdlRefSelUIH','handle');



%=============================
p = schema.prop(clsH,'covSubSysTreeDlg','handle');
%=============================
p = schema.prop(clsH,'reportSettingsDlg','handle');


%=============================
m = schema.method(clsH , 'getDialogSchema');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'string' };
s.OutputTypes = {'mxArray'};
%========
m = schema.method(clsH , 'subSysBrowseCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};
%========
m = schema.method(clsH , 'reportSettingsCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};

%========
m = schema.method(clsH , 'setCovPathStatus');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'string'};
s.OutputTypes = {};
%========
m = schema.method(clsH , 'setRecordCoverage');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'mxArray'};
s.OutputTypes = {};
%========
m = schema.method(clsH , 'startFilterEdit');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};


%========
m = schema.method(clsH , 'setMdlRefEnable');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'mxArray'};
s.OutputTypes = {};
%========
m = schema.method(clsH , 'mdlRefClose', 'static');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};
%========
m = schema.method(clsH , 'mdlRefRecordCoverageUpdate', 'static');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};
%========
m = schema.method(clsH , 'displayAllModelParams', 'static');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'mxArray'};
s.OutputTypes = {};

%========
m = schema.method(clsH , 'mdlRefSelect', 'static');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'mxArray'};
s.OutputTypes = {'handle'};

%========
m = schema.method(clsH , 'help', 'static');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {};
s.OutputTypes = {};

%========
m = schema.method(clsH , 'mdlRefBrowseCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};
%========
m = schema.method(clsH , 'filterFileBrowseCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};
%========
m = schema.method(clsH, 'postApply');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {'bool', 'string'};
%========
m = schema.method(clsH, 'postClose');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};

%=============================
%=============================
p = schema.prop(clsH,'m_metricGroupEnable_cv','bool');
p.Visible = 'off';
%=============================
p = schema.prop(clsH,'m_metricGroupEnable_signal','bool');
p.Visible = 'off';

%=============================
p = schema.prop(clsH,'m_metricGroupEnable_sldv','bool');
p.Visible = 'off';
%=============================
p = schema.prop(clsH,'m_metricGroupVisible','mxArray');
p.Visible = 'off';
%========

m = schema.method(clsH , 'metricGroupEnableCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle','string'};
s.OutputTypes = {};

%=============================
p = schema.prop(clsH,'m_signalMetricsEnable','bool');
p.Visible = 'off';
%=============================
p = schema.prop(clsH,'m_sldvMetricsEnable','bool');
p.Visible = 'off';
%=============================
p = schema.prop(clsH,'metricStates','mxArray');
p.Visible = 'on';

%=============================
p = schema.prop(clsH,'recordCoverage','bool');
p.Visible = 'on';
%=============================
p = schema.prop(clsH,'modelH','mxArray');
p.Visible = 'on';
%=============================
p = schema.prop(clsH,'covModelRefEnable','string');
p.Visible = 'on';
%=============================
p = schema.prop(clsH,'modelRefEnable','bool');
p.Visible = 'on';

%=============================
p = schema.prop(clsH,'mdlRefSelStatus','string');
p.Visible = 'on';
%=============================
p = schema.prop(clsH,'covModelRefExcluded','string');
p.Visible = 'on';
%=============================
p = schema.prop(clsH,'covExternalEMLEnable','bool');
p.Visible = 'on';

%=============================
p = schema.prop(clsH,'covPath', 'string');
p.Visible = 'on';
p.FactoryValue = '';
%=============================
p = schema.prop(clsH,'covPathStatus', 'string');
p.Visible = 'on';
p.FactoryValue = '';

%=============================
p = schema.prop(clsH,'covSaveName', 'string');
p.Visible = 'on';
p.FactoryValue = '';
%=============================
p = schema.prop(clsH,'covCompData', 'string');
p.Visible = 'on';
p.FactoryValue = '';
%=============================
p = schema.prop(clsH,'covFilter', 'string');
p.Visible = 'on';
p.FactoryValue = '';

%=============================
p = schema.prop(clsH,'covHtmlReporting', 'bool');
p.Visible = 'on';
p.FactoryValue = true;
%=============================
p = schema.prop(clsH,'covNameIncrementing', 'bool');
p.Visible = 'on';
p.FactoryValue = false;

%=============================
p = schema.prop(clsH,'covSaveName', 'string');
p.Visible = 'on';
p.FactoryValue = '';

%=============================
p = schema.prop(clsH,'covNameIncrementing', 'bool');
p.Visible = 'on';
p.FactoryValue = false;

%=============================
p = schema.prop(clsH,'covReportOnPause', 'bool');
p.Visible = 'on';
p.FactoryValue = false;


%=============================
p = schema.prop(clsH,'modelDisplay', 'bool');
p.Visible = 'on';
p.FactoryValue = false;


%=============================
p = schema.prop(clsH,'displayReport', 'bool');
p.Visible = 'on';
p.FactoryValue = false;

%=============================
if isempty(findtype('CovCumulativeReportType'))
    schema.EnumType('CovCumulativeReportType', {'Slvnv:simcoverage:covCumulativeReport1','Slvnv:simcoverage:covCumulativeReport2'});
end    


p = schema.prop(clsH,'covCumulativeReport', 'CovCumulativeReportType');
p.Visible = 'on';
p.FactoryValue = 'Slvnv:simcoverage:covCumulativeReport2';

%=============================
p = schema.prop(clsH,'covCompData', 'string');
p.Visible = 'on';
p.FactoryValue = '';


%=============================
p = schema.prop(clsH,'covHTMLOptions', 'string');
p.Visible = 'on';
p.FactoryValue = '';

%=============================
p = schema.prop(clsH,'covSaveCumulativeToWorkspaceVar', 'bool');
p.Visible = 'on';
p.FactoryValue = false;
%=============================
p = schema.prop(clsH,'covSaveSingleToWorkspaceVar', 'bool');
p.Visible = 'on';
p.FactoryValue = false;

%=============================
p = schema.prop(clsH,'covCumulativeVarName', 'string');
p.Visible = 'on';
p.FactoryValue = '';
%=============================
metricStruct = cvi.MetricRegistry.getMetricsMetaInfo;
for idx = 1:numel(metricStruct)
    p = schema.prop(clsH, metricStruct(idx).cvtestFieldName, 'bool');
    p.Visible = 'on';
    p.FactoryValue = false;
end
%=============================
htmlOptions = cvi.ReportUtils.getOptionsTable;
[m, ~] = size(htmlOptions );
for idx = 1:m
    p = schema.prop(clsH, htmlOptions{idx,2}, 'bool');
    p.Visible = 'on';
    p.FactoryValue = false;
end
%=============================
optionsTable = cv('Private', 'cv_dialog_options');
[m, ~] = size(optionsTable );
for idx = 1:m
    p = schema.prop(clsH, optionsTable{idx,4}, 'bool');
    p.Visible = 'on';
    p.FactoryValue = false;
end


