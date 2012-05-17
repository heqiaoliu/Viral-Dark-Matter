function schema
%SCHEMA defines the distcomp.configsection class
%

%   Copyright 2007 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('object');
hThisClass   = schema.class(hThisPackage, 'configsection', hParentClass);
% Declare the interface that this class implements.
hThisClass.JavaInterfaces = {'com.mathworks.toolbox.distcomp.configurations.ConfigSection'};

% The SectionName is currently only used to print user-friendly messages.
p = schema.prop(hThisClass, 'SectionName', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';


%%%%%%%%%%%%%
%
% The following properties are all vectors/arrays of equal length.
p = schema.prop(hThisClass, 'Names', 'string vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(hThisClass, 'Types', 'string vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(hThisClass, 'IsPropWritable', 'MATLAB array'); % Array of booleans
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'IsPropEnabled', 'MATLAB array'); % Array of booleans
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'PropValue', 'MATLAB array'); % A cell array of values
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

%%%%
% Declare the public methods for the interface that this class implements.
m = schema.method(hThisClass, 'setJavaValue');
m.signature.varargin = 'off';
m.signature.InputTypes = {'handle', 'string', 'java.lang.Object'}; % The handle is for the object itself.
m.signature.OutputTypes = {};

m = schema.method(hThisClass, 'getJavaValue');
m.signature.varargin = 'off';
m.signature.InputTypes = {'handle', 'string'}; 
m.signature.OutputTypes = {'java.lang.Object'};

m = schema.method(hThisClass, 'getIsEnabled');
m.signature.varargin = 'off';
m.signature.InputTypes = {'handle', 'string'}; 
m.signature.OutputTypes = {'bool'};

m = schema.method(hThisClass, 'setIsEnabled');
m.signature.varargin = 'off';
m.signature.InputTypes = {'handle', 'string', 'bool'}; 
m.signature.OutputTypes = {};

m = schema.method(hThisClass, 'getIsWritable');
m.signature.varargin = 'off';
m.signature.InputTypes = {'handle', 'string'}; 
m.signature.OutputTypes = {'bool'};

