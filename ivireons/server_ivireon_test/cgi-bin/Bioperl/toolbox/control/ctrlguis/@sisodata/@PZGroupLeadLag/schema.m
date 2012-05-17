function schema
%SCHEMA  Schema for complex pole/zero group class

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2008/09/15 20:36:33 $

% Register class
pkg = findpackage('sisodata');
c = schema.class(pkg, 'PZGroupLeadLag', findclass(pkg, 'pzgroup'));


% Derived Properties
% Property VirtualProperties [PhaseMax, Wmax]
p = schema.prop(c,'PhaseMax','double'); 
p.getFunction = {@LocalGetVirtualProperty 1};

p = schema.prop(c,'Wmax','double');  
p.getFunction = {@LocalGetVirtualProperty 2};


%% Local Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Value = LocalGetVirtualProperty(this,ValueStored,idx)

if isempty(this.VirtualProperties)
    this.updateVirtualProperties;
end

Value = this.VirtualProperties(idx);

