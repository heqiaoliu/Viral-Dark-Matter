function Design = exportdesign(this)
% Exports SISO Tool data as @initdata object.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/05/10 16:58:59 $
Config = getconfig(this.Plant);
if Config==0
  
   Design = LocalConfig0Setup(this);
   Design.Name = this.Name;
   Design.Input = this.Input;
   Design.Output = this.Output; 
   Design = Design.setLoopView(this.LoopView);
   
else
   Design = sisoinit(Config);
   Design.Name = this.Name;
   Design.FeedbackSign = this.Plant.LoopSign;
   Design.Input = this.Input;
   Design.Output = this.Output;
   Design = Design.setLoopView(this.LoopView);
   
   if ~isempty(this.Plant)
      for ct=1:length(this.Plant.G)
         Gid = Design.Fixed{ct};
         Design.(Gid) = save(this.Plant.G(ct),Design.(Gid));
      end
      
      for ct=1:length(this.C)
         Cid = Design.Tuned{ct};
         Design.(Cid) = save(this.C(ct),Design.(Cid));
      end
   end
end
Design.NominalModelIndex = this.Plant.getNominalModelIndex;



function Design = LocalConfig0Setup(LoopData)
% Fixed and tuned components
Fixed = {'P'};
TunedNames = get(LoopData.C,{'Identifier'});
LoopNames = get(LoopData.L,{'Identifier'});
Design = sisodata.design(Fixed,TunedNames,LoopNames,0);

% Add instance prop for each new name
Design.P.Value = utCreateLTI(getP(LoopData.Plant));

nC = length(TunedNames);
for ct=1:nC
   tn = TunedNames{ct};
   Design.(tn) = save(LoopData.C(ct));
end

nC = length(LoopNames);
for ct=1:nC
   tn = LoopNames{ct};
   Design.(tn) = save(LoopData.L(ct));
end
