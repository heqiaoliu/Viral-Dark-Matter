function [CLNom,CL] = getclosedloop(this,outputs,inputs)
%GETCLOSEDLOOP  Gets the closed-loop model.
%
%   GETCLOSEDLOOP(THIS) returns a MIMO @ssdata model
%   mapping this.Input to this.Output.
%
%   GETCLOSEDLOOP(THIS,OUTPUTS,INPUTS) returns a
%   structurally minimal @ssdata model of the 
%   closed-loop map between the I/Os specified by
%   INPUTS and OUTPUTS (index vectors or string
%   vectors).

%   Author(s): P. Gahinet, N. Hickey, K. Subbarao
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.23.4.8 $  $Date: 2010/04/11 20:29:52 $
CL = this.ClosedLoop;
if isequal(CL,[]) && ~isempty(this.Plant)
   % Recompute overall closed-loop model if not available
   nC = length(this.C);

   % Get augmented plant for closed-loop analysis
   Psim = getPsim(this.Plant);
   
   % Build vector of state-space models of C1,C2,...,CN
   if isa(Psim,'ltipack.frddata')
       C = ltipack.frddata.array([nC 1]);
       freqs = Psim.Frequency;
       units = Psim.FreqUnits;
       for ct=1:nC
           C(ct,1) = frd(zpk(this.C(ct)),freqs,units);
       end
   else
       C = ltipack.ssdata.array([nC 1]);
       for ct=1:nC
           C(ct) = ss(this.C(ct));
       end
   end



   % Close the loop
   try
      % Call optimize LTF code to close N SISO loops
      if isa(Psim,'ltipack.frddata')
          CL = ltipack.frddata.array([length(Psim) 1]);
      else
          CL = ltipack.ssdata.array([length(Psim) 1]);
      end
      for ct = 1:length(Psim)
          CL(ct) = utSISOLFT(Psim(ct),C);
      end
   catch %#ok<CTCH>
      % Algebraic loop
      nu = length(this.Input);
      ny = length(this.Output);
      CL = ltipack.ssdata([],zeros(0,nu),zeros(ny,0),...
         repmat(NaN,ny,nu),[],this.Ts);
   end
   this.ClosedLoop = CL;
end

% Extract subsystem for specified I/Os
if nargin>1
   if isnumeric(inputs)
      idxIn = inputs;
   else % char and cell of strings
      [junk,idxIn] = ismember(inputs,this.Input);
      idxIn = idxIn(idxIn>0);
   end
   if isnumeric(outputs)
      idxOut = outputs;
   else
      [junk,idxOut] = ismember(outputs,this.Output);
      idxOut = idxOut(idxOut>0);
   end
   if isempty(idxOut) || isempty(idxIn)
      CL = [];
   else
       for ct = 1:length(CL)
           CL(ct) = getsubsys(CL(ct),idxOut,idxIn,'smin');
       end
   end
end

CLNom = CL(this.Plant.getNominalModelIndex);