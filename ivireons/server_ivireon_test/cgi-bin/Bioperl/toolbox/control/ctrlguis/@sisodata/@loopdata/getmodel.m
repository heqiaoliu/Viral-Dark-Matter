function [NomModel,Model] = getmodel(this,LoopTF)
%GETMODEL  Computes loop transfer functions as LTI objects.
%
%   LOOPTF is a structure specifying the loop transfer of interest
%   (see LOOPTRANSFERS for details). The output MODEL is an @lti 
%   object.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/04/11 20:29:53 $

NominalIdx = this.P.getNominalModelIndex;

switch LoopTF.Type
   case 'G'
      Model = this.Plant.G(LoopTF.Index).Model;
      localSetDefaultIOName(Model);
      if size(Model,3) == 1;
          NomModel = Model;
      else
          NomModel = Model(:,:,NominalIdx);
      end
   case 'C'
      Model = zpk.make(zpk(this.C(LoopTF.Index)));
      localSetDefaultIOName(Model);
      NomModel = Model;
      Model = [];
   case 'L'
      % getOpenLoop returns @ssdata or @frddata model
      P = this.Plant.getP;
      if isa(P,'ltipack.frddata')
          DataModel = ltipack.frddata.array([length(P) 1]);
      else
          DataModel = ltipack.ssdata.array([length(P) 1]);
      end    
      for ct = 1:length(P)
          DataModel(ct,1) =  getOpenLoop(this.L(LoopTF.Index),[],ct);
      end  
      if isa(P,'ltipack.frddata')
          Model = frd.make(DataModel);
      else
          Model = ss.make(DataModel);
      end
     
      localSetDefaultIOName(Model);
      NomModel = Model(:,:,NominalIdx);
   case 'T'
      % getclosedloop returns @ssdata or @frddata model
      [~,ModelData] = getclosedloop(this,LoopTF.Index{:});
      if isa(ModelData,'ltipack.frddata')
          Model = frd.make(ModelData);
      else
          Model = ss.make(ModelData);
      end
      set(Model,...
         'InputName',this.Input(LoopTF.Index{2}),...
         'OutputName',this.Output(LoopTF.Index{1}));
      NomModel = Model(:,:,NominalIdx);
   case 'Tss'
      % Returns @ssdata or @frddata model
      [~,ModelData] = getclosedloop(this);
      if isa(ModelData,'ltipack.frddata')
          Model = frd.make(ModelData);
      else
          Model = ss.make(ModelData);
      end
      set(Model,'InputName',this.Input,'OutputName',this.Output);
      NomModel = Model(:,:,NominalIdx);
   case 'P'
      % Returns @ssdata or @frddata model
      ModelData = getP(this.Plant);
      if isa(ModelData,'ltipack.frddata')
          Model = frd.make(ModelData);
      else
          Model = ss.make(ModelData);
      end
      
      NomModel = Model(NominalIdx);
end

if ~isUncertain(this.P)
    Model = [];
end


end


function Model = localSetDefaultIOName(Model)
set(Model,'InputName',sprintf('Input'),...
    'OutputName',sprintf('Output'));
end
