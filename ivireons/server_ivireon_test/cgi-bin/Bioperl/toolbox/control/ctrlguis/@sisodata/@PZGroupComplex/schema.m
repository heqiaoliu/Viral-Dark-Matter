function schema
%SCHEMA  Schema for complex pole/zero group class

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2008/09/15 20:36:31 $

% Register class
pkg = findpackage('sisodata');
c = schema.class(pkg, 'PZGroupComplex', findclass(pkg, 'pzgroup'));


% Derived Properties
%Property VirtualProperties is [Zeta; Wn]

p = schema.prop(c,'Zeta','double');  % Damping ratio
p.getFunction = {@LocalGetVirtualProperty 1};
%p.setFunction = @LocalSetZeta;

p = schema.prop(c,'Wn','double'); % Natural Frequency (rad/s)
p.getFunction = {@LocalGetVirtualProperty 2};
%p.setFunction = @LocalSetWn;



%% Local Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Value = LocalGetVirtualProperty(this,StoredValue,idx)

if isempty(this.VirtualProperties)
    this.updateVirtualProperties;
end

Value = this.VirtualProperties(idx);


function Zeta = LocalSetZeta(this,Zeta)

this.setValue(1,VirtualProperties);

Zeta = this.VirtualProperties(1);




