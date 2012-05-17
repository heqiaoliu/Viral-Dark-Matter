function schema
%SCHEMA  Schema for pole/zero group class

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.3.4.2 $ $Date: 2008/09/15 20:36:40 $


% Register class 
c = schema.class(findpackage('sisodata'),'pzgroup');

schema.prop(c,'Parent','MATLAB array');  

% Define properties
% RE: Supported group types are Real, Complex, LeadLag, and Notch
schema.prop(c,'Type','string');           % Group type 
p(1) = schema.prop(c,'Zero','MATLAB array');   % Zero handles (HG objects)
p(1).setFunction = @LocalSetPoleZero;
p(2) = schema.prop(c,'Pole','MATLAB array');   % Pole handles (HG objects)
p(2).setFunction = @LocalSetPoleZero;
% Defaults
% RE: AbortSet=off to correctly overwrite bad user input in PZ editor 
%     (group data is unchanged in such case)
set(p,'AccessFlags.AbortSet','off',...
      'AccessFlags.Init','on','FactoryValue',zeros(0,1));

p = schema.prop(c,'VirtualProperties','MATLAB array'); % vector of virtual properties  
 
p = schema.prop(c,'ParamSpec','handle'); % ParamSpec for PZGroup
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Event
schema.event(c,'PZDataChanged');    % Notifies of modified Zero or Pole data


%% Local Functions
function Value = LocalSetPoleZero(this,Value)
% Make VirtualProperties Dirty
this.VirtualProperties = [];



    


  