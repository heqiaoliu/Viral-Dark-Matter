function schema
% Defines properties for @plant superclass (plant model for multi-loop tuning)

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/03/26 17:22:26 $
c = schema.class(findpackage('sisodata'),'plant');

% Number of SISO loops
schema.prop(c,'nLoop','MATLAB array');
% Loop configuration identifier
schema.prop(c,'Configuration','double');

% Private
% Augmented plant (@ssdata object)
p = schema.prop(c,'P','MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.setfunction = {@LocalSetP};


p = schema.prop(c,'NominalIdx','MATLAB array');
% p.AccessFlags.PublicGet = 'off';
% p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 1;



% ------------------------------------------------------------------------%
% Function: LocalSetP
% Purpose:  Ensure that NominalIdx is valid when plant is set
% ------------------------------------------------------------------------%
function valueStored = LocalSetP(this, ProposedValue)
if this.NominalIdx > length(ProposedValue)
    this.NominalIdx = 1;
end
valueStored = ProposedValue;
