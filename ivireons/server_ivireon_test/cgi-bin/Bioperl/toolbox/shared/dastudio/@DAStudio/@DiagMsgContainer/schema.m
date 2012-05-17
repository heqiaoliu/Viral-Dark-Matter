function schema
% SCHEMA  
% Defines an explorable container for diagnostic messages.
%  Copyright 2008 The MathWorks, Inc.
  
  pkg = findpackage('DAStudio');
  c = schema.class(pkg, 'DiagMsgContainer', pkg.findclass('Explorable'));

  % Define public properties
  schema.prop(c, 'Name', 'string');
  
  m = schema.method(c, 'isHierarchical');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};

  m = schema.method(c, 'areChildrenOrdered');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};
  
  m = schema.method(c, 'areDescendantsReadonly');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};
  
  m = schema.method(c, 'getDialogSchema');
  s = m.Signature;
  s.varargin    = 'off';
  s.InputTypes  = {'handle', 'string'};
  s.OutputTypes = {'mxArray'};
 
  
end
