function schema
%schema

%   Copyright 2010 The MathWorks, Inc.

   
pkg   = findpackage('SlCov');

clsH = schema.class(pkg,...
   'CovReportSettings');

%=============================
m = schema.method(clsH , 'getDialogSchema');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'string' };
s.OutputTypes = {'mxArray'};
%========
m = schema.method(clsH, 'postApply');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {'bool', 'string'};

%=============================
p = schema.prop(clsH,'m_callerDlg','handle');
p = schema.prop(clsH,'m_callerSource','handle');
