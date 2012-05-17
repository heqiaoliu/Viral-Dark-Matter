function schema
%schema

%   Copyright 2009-2010 The MathWorks, Inc.

   
pkg   = findpackage('SlCov');

clsH = schema.class(pkg,...
   'CovSubSysTree');

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

%========
p = schema.prop(clsH,'m_treeItems','mxArray');
%========
p = schema.prop(clsH,'m_selectedItem','string');

p = schema.prop(clsH,'m_callerSource','handle');

