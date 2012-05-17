function schema

% Copyright 2003-2008 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'datacursorbehavior');
p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'DataCursor';

schema.prop(cls,'StartDragFcn','MATLAB callback');
schema.prop(cls,'EndDragFcn','MATLAB callback');
schema.prop(cls,'UpdateFcn','MATLAB callback');
schema.prop(cls,'CreateFcn','MATLAB callback');
schema.prop(cls,'StartCreateFcn','MATLAB callback');
schema.prop(cls,'UpdateDataCursorFcn','MATLAB callback');
schema.prop(cls,'MoveDataCursorFcn','MATLAB callback');
p = schema.prop(cls,'CreateNewDatatip','bool');
p.FactoryValue = false;
p.Description = 'True will create a new datatip for every mouse click';
p = schema.prop(cls,'Enable','bool');
p.FactoryValue = true;

p = schema.prop(cls,'Serialize','MATLAB array');
p.FactoryValue = true;
p.AccessFlags.Serialize = 'off';