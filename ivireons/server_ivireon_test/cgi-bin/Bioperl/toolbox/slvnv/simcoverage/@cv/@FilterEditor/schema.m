function schema
%schema

%   Copyright 2009-2010 The MathWorks, Inc.

   
pkg   = findpackage('cv');

clsH = schema.class(pkg,...
   'FilterEditor');
%=============================
p = schema.prop(clsH,'covFilter','string');
p.Visible = 'off';
%=============================
p = schema.prop(clsH,'modelName','string');
p.Visible = 'off';
%=============================
p = schema.prop(clsH,'saveToModel','bool');
p.Visible = 'off';


%=============================
p = schema.prop(clsH,'m_dlg','handle');

%=============================
m = schema.method(clsH , 'getDialogSchema');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'string' };
s.OutputTypes = {'mxArray'};

%========
m = schema.method(clsH , 'loadFilter', 'static');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'string'};
s.OutputTypes = {'mxArray'};
%========
m = schema.method(clsH , 'saveFilter', 'static');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'string','mxArray'};
s.OutputTypes = {};
%========
m = schema.method(clsH , 'help', 'static');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {};
s.OutputTypes = {};

%========
m = schema.method(clsH , 'filterAddCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};

%========
m = schema.method(clsH , 'filterRemoveCallback');
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
%=============================
m = schema.method(clsH , 'filterFileBrowseCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};
%=============================
m = schema.method(clsH , 'modelNameBrowseCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle'};
s.OutputTypes = {};

%=============================
m = schema.method(clsH , 'browseCallback', 'static');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'string', 'string', 'string'};
s.OutputTypes = {'string'};

%=============================
p = schema.prop(clsH,'filterPropertyNameIdx','int');
p.Visible = 'off';
p.FactoryValue = 0;

%=============================
p = schema.prop(clsH,'filterPropertyValueidx','int');
p.Visible = 'off';
p.FactoryValue = 0;
%=============================
p = schema.prop(clsH,'filterStateIdx','int');
p.Visible = 'off';
p.FactoryValue = 0;
%=============================
p = schema.prop(clsH,'filterState','mxArray');
p.Visible = 'off';

%=============================
p = schema.prop(clsH,'propMap','mxArray');
p.Visible = 'off';



