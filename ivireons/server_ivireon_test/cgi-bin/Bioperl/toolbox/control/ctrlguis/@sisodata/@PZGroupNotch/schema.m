function schema
%SCHEMA  Schema for complex pole/zero group class

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2008/09/15 20:36:34 $

% Register class
pkg = findpackage('sisodata');
c = schema.class(pkg, 'PZGroupNotch', findclass(pkg, 'pzgroup'));

% Derived Properties
% Virtual Properties [Wn; ZetaZero; ZetaPole; Depth, Width]
p = schema.prop(c,'Wn','double');  
p.getFunction = {@LocalGetVirtualProperty 1};

p = schema.prop(c,'ZetaZero','double'); 
p.getFunction = {@LocalGetVirtualProperty 2};

p = schema.prop(c,'ZetaPole','double'); 
p.getFunction = {@LocalGetVirtualProperty 3};

p = schema.prop(c,'Depth','double'); 
p.getFunction = {@LocalGetVirtualProperty 4};

p = schema.prop(c,'Width','double'); 
p.getFunction = {@LocalGetVirtualProperty 5};



%% Local Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Value = LocalGetVirtualProperty(this, ValueStored, idx)

if isempty(this.VirtualProperties)
    this.updateVirtualProperties;
end

Value = this.VirtualProperties(idx);