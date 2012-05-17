function [Gmout,Pm,Wcg,Wcp,isStable] = margin(sys)
%MARGIN  Gain and phase margins and crossover frequencies.
%
%   [Gm,Pm,Wcg,Wcp] = MARGIN(SYS) computes the gain margin Gm, the phase 
%   margin Pm, and the associated frequencies Wcg and Wcp, for the SISO 
%   open-loop model SYS (continuous or discrete). The gain margin Gm is 
%   defined as 1/G where G is the gain at the -180 phase crossing. The 
%   phase margin Pm is in degrees.  
%
%   The gain margin in dB is derived by 
%      Gm_dB = 20*log10(Gm)
%   The loop gain at Wcg can increase or decrease by this many dBs before 
%   losing stability, and Gm_dB<0 (Gm<1) means that stability is most 
%   sensitive to loop gain reduction.  If there are several crossover 
%   points, MARGIN returns the smallest margins (gain margin nearest to 
%   0dB and phase margin nearest to 0 degrees).
%
%   For a S1-by...-by-Sp array of linear systems, MARGIN returns 
%   arrays of size [S1 ... Sp] such that
%      [Gm(j1,...,jp),Pm(j1,...,jp)] = MARGIN(SYS(:,:,j1,...,jp)) .  
%
%   [Gm,Pm,Wcg,Wcp] = MARGIN(MAG,PHASE,W) derives the gain and phase
%   margins from the Bode magnitude, phase, and frequency vectors 
%   MAG, PHASE, and W produced by BODE. Interpolation is performed 
%   between the frequency points to estimate the values. 
%
%   MARGIN(SYS), by itself, plot the open-loop Bode plot with 
%   the gain and phase margins marked with a vertical line. 
%
%   See also ALLMARGIN, BODEPLOT, BODE, LTIVIEW, DYNAMICSYSTEM.

%   Note: if there is more than one crossover point, margin will
%   return the worst case gain and phase margins. 

%   Andrew Grace, P.Gahinet, A.DiVergilio, J.Glass 1-02
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:05 $

% Handle case when called w/o output argument
if nargout
   % Compute margins
   try
      s = allmargin(sys);
   catch E
      error(E.identifier,strrep(E.message,'allmargin','margin'))
   end

   % Initialize output arrays
   asizes = size(s);
   nsys = prod(asizes);  % number of models
   Gmout = zeros(asizes);  Wcg = zeros(asizes);
   Pm = zeros(asizes);  Wcp = zeros(asizes);
   isStable = zeros(asizes);
   for m=1:nsys
      % Compute min (worst-case) gain margins
      [Gmout(m),Pm(m),~,Wcg(m),Wcp(m),isStable(m)] = ltipack.getMinMargins(s(m));
   end

   if nsys==1 && s.Stable==0
       ctrlMsgUtils.warning('Control:analysis:MarginUnstable')
   end
else
   % Plot margins
   if ndims(sys)>2
       ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithNoOutputArgs','margin')
   elseif ~issiso(sys)
       ctrlMsgUtils.error('Control:analysis:margin1','margin')
   end

   ax = gca;

   try
      [sysList,~,OptionsObject] = DynamicSystem.parseRespFcnInputs({sys},{inputname(1)});
      sysList = DynamicSystem.checkBodeInputs(sysList,cell(1,0));
   catch E
      throw(E)
   end

   % Bode response plot
   % Create plot (visibility ='off')
   h = ltiplot(ax,'bode',sys.InputName,sys.OutputName,OptionsObject,cstprefs.tbxprefs);

   % Create responses
   src = resppack.ltisource(sys,'Name',sysList.Name);
   r = h.addresponse(src);
   r.DataFcn = {'magphaseresp' src 'bode' r []};
   % Styles and preferences
   initsysresp(r,'bode',h.Options,sysList.Style)

   % Add margin display
   r.addchar('Stability Margins','resppack.MinStabilityMarginData', ...
      'resppack.MarginPlotCharView');

   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h);  % hold mode
   end

   % Right-click menus
   ltiplotmenu(h,'margin');
end
