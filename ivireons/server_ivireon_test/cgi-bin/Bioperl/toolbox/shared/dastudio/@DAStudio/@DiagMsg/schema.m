function schema
% Defines DiagMsg class 

% Copyright 2008 The MathWorks, Inc.
    
% =========================================================================
% Class Definition
% =========================================================================

pkg = findpackage('DAStudio');
sc = pkg.findclass('Explorable');
c = schema.class (pkg, 'DiagMsg', sc);

		      
% =========================================================================
% Class Properties for DiagMsg class
% =========================================================================

schema.prop(c,'Name','string');
schema.prop(c,'Type','string');
schema.prop(c,'DispType','string'); % Type displayed in ME.
schema.prop(c,'Contents','handle');
schema.prop(c,'SourceFullName','string');
schema.prop(c,'SourceName','string');
schema.prop(c,'Component','string');
schema.prop(c,'Summary','string');
schema.prop(c,'AssocObjectHandles','NReals');
schema.prop(c,'AssocObjectNames','string vector');
schema.prop(c,'SourceObject','NReals');
schema.prop(c,'OpenFcn','string');

% this property is meant to find the directory for a hyperlink
schema.prop(c,'HyperRefDir','string');

schema.prop(c, 'enableOpenButton', 'bool');

% =========================================================================
% Class Methods for DiagMsg class
% =========================================================================

m = schema.method(c, 'getDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

m = schema.method(c, 'getDisplayIcon');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'string'};

m = schema.method(c, 'getPreferredProperties');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'string vector'};

m = schema.method(c, 'isHierarchical');
m.signature.varargin = 'off';
m.signature.inputTypes={'handle'};
m.signature.outputTypes={'bool'};

m = schema.method(c, 'isEditableProperty');
m.signature.varargin = 'off';
m.signature.inputTypes={'handle' 'string'};
m.signature.outputTypes={'bool'};

m = schema.method(c, 'exploreAction');
m.signature.varargin = 'off';
m.signature.inputTypes={'handle'};
m.signature.outputTypes={};
  

% =========================================================================  
% Create DiagMsg.Contents class
% =========================================================================
cContents = schema.class(pkg, 'DiagMsgContents');

% =========================================================================
% Class Properties for DiagMsgContents class
% =========================================================================
schema.prop(cContents,'Type','string');
schema.prop(cContents,'Details','string');
schema.prop(cContents,'Summary','string');
schema.prop(cContents,'HyperSearched','bool');

end
