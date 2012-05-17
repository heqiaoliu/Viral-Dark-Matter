function this = design(FixedNames,TunedNames,LoopNames,config)
% Constructor for @design class

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/05/10 16:58:56 $


this = sisodata.design;

% Version 1 for 2006a
% this.Version = 1.0;
% Version 2 for 2010b (multimodel support)
this.Version = 2.0;

if nargin==0
   % load call
   return
end

if isequal(nargin,4)
    this.Configuration = config;
end

% Fixed and tuned components
this.Fixed = FixedNames(:);
this.Tuned = TunedNames(:);
this.Loops = LoopNames(:);

% Add instance prop for each new name
initsys = zpk(1);

for ct=1:length(FixedNames)
   fn = FixedNames{ct};
   try 
      schema.prop(this,fn,'MATLAB array');
   catch
       ctrlMsgUtils.error('Control:compDesignTask:DesignSnapshot1')
   end
   fm = sisodata.system;
   fm.Name = fn;
   fm.Value = initsys;
   this.(fn) = fm;
end

nC = length(TunedNames);
for ct=1:nC
   tn = TunedNames{ct};
   try 
      schema.prop(this,tn,'MATLAB array');
   catch
       ctrlMsgUtils.error('Control:compDesignTask:DesignSnapshot2')
   end
   if ~isequal(config,0)
       tm = sisodata.TunedZPKSnapshot;
       tm.Name = tn;
       tm.Value = initsys;
       this.(tn) = tm;
   end
end


nC = length(LoopNames);
for ct=1:nC
   tn = LoopNames{ct};
   try 
      schema.prop(this,tn,'MATLAB array');
   catch
       ctrlMsgUtils.error('Control:compDesignTask:DesignSnapshot3')
   end
   tm = sisodata.TunedLoopSnapshot;
   % Revisit: Determine what other fields need to added here
   tm.Name = tn;
   tm.View = {'bode'};
   this.(tn) = tm;
end