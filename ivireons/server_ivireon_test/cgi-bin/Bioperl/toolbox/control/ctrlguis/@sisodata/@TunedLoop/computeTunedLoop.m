function computeTunedLoop(this,LoopData,varargin)
% Recomputes tuned loop parameterization
%    TL = TF1 ... TFn * lft(IC,diag(TB1,...TBm))
% where 
%   * the TFi's are the tuned factors (directly 
%     tunable blocks
%   * the TBj's are the indirectly tunable blocks.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/03/26 17:22:00 $
if nargin == 3
    LoopConfig = varargin{1};
else
    LoopConfig = this.LoopConfig;
end 

% Set nominal index
this.Nominal = getNominalModelIndex(LoopData.Plant);

if LoopData.getconfig == 0
   %% Throw up a waitbar
   wb = waitbar(0,sprintf('Analyzing the model...'),'Name',xlate('Simulink Control Design'));

   %% Get the TaskNode
   TaskNode = handle(getObject(getSelected(slctrlexplorer)));

   %% Create the loop opening IOs
   LoopOpenings = LoopConfig.LoopOpenings;
   for ct = numel(LoopOpenings):-1:1
      if LoopOpenings(ct).Status
         Active = 'on';
      else
         Active = 'off';
      end
      loopopeningio(ct) = linio(LoopOpenings(ct).BlockName,LoopOpenings(ct).PortNumber,...
         'none','on');
      loopopeningio(ct).Active = Active;
   end

   %% Create the FeedbackLoop IO
   OpenLoop = LoopConfig.OpenLoop;
   FeedbackLoop = linio(OpenLoop.BlockName,OpenLoop.PortNumber,'outin','on');

   loopio = struct('FeedbackLoop',FeedbackLoop,...
      'LoopOpenings',loopopeningio,...
      'Name',this.Name,...
      'Description',this.Description);

   % Recompute loop for SCD
   try
      waitbar(0.25,wb);
      newtunedloop = computeSingleTunedLoop(TaskNode,loopio,LoopData);
      waitbar(0.9,wb);
   catch ME
      close(wb);
      throw(ME);
   end

   this.TunedFactors = newtunedloop.TunedFactors;
   this.setTunedLFT(newtunedloop.TunedLFT.IC,newtunedloop.TunedLFT.Blocks);
   this.LoopConfig.BlocksInPathByName = newtunedloop.LoopConfig.BlocksInPathByName;

   % Update the SISODB
   LoopData.send('LoopDataChanged')
   close(wb);

elseif this.Feedback
   % Tuned open loop
   BlockNames = get(LoopData.C,{'Identifier'}); % names of tuned blocks
   idxOL = find(strcmp(LoopConfig.OpenLoop.BlockName, BlockNames));

   % Find all loop openings for open loop IDXOL
   LoopOpenings = LoopConfig.LoopOpenings;
   if isempty(LoopOpenings)
      idxOpenings = [];
   else
      [junk,idxOpenings] = intersect(BlockNames,...
         {LoopOpenings([LoopOpenings.Status]).BlockName});
   end

   % Build data structure for open-loop analysis
   [cDepend,G] = getOpenLoopModel(LoopData.Plant,idxOL,idxOpenings);
   this.TunedFactors = LoopData.C(idxOL);
   this.setTunedLFT(G,LoopData.C(cDepend)); 

else
   % Tuned closed loop
end