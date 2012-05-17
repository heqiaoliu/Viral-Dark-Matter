function [gm,pm,Wcg,Wcp] = imargin(mag,phase,w)
%IMARGIN  Gain and phase margins using interpolation.
%
%   [Gm,Pm,Wcg,Wcp] = IMARGIN(MAG,PHASE,W) returns gain margin Gm,
%   phase margin Pm, and associated frequencies Wcg and Wcp, given
%   the Bode magnitude, phase, and frequency vectors MAG, PHASE,
%   and W from a linear system.  IMARGIN expects magnitude values 
%   in linear scale and phase values in degrees.
%
%   When invoked without left-hand arguments IMARGIN(MAG,PHASE,W) 
%   plots the Bode response with the gain and phase margins marked  
%   with a vertical line.
%
%   IMARGIN works with the frequency response of both continuous and
%   discrete systems. It uses interpolation between frequency points 
%   to approximate the true gain and phase margins.  Use MARGIN for 
%   more accurate results when an LTI model of the system is available.
%
%   Example of IMARGIN:
%     [mag,phase,w] = bode(a,b,c,d);
%     [Gm,Pm,Wcg,Wcp] = imargin(mag,phase,w)
%
%   See also BODEPLOT, BODE, MARGIN, ALLMARGIN.

%   Clay M. Thompson  7-25-90
%   Revised A.C.W.Grace 3-2-91, 6-21-92
%   Revised A.Potvin 10-1-94
%   Revised P. Gahinet 10-99
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.19.4.10 $  $Date: 2007/12/14 14:22:52 $

ni = nargin;
no = nargout;
error(nargchk(3,3,ni));
if isequal(size(mag),size(phase),[1 1 length(w)])
   % Support 3D input from Bode
   mag = mag(:);
   phase = phase(:);
elseif ndims(mag)>2 || ndims(phase)>2,
    ctrlMsgUtils.error('Control:analysis:imargin1');
end

w = w(:);                   % Make sure freq. is a column
[m, n] = size(phase);       % Assume column orientation.

% Compute interpolated margins for each column of phase
if n==1
   % Minimum margins of single response
   [Gm,Pm,junk,Wcg,Wcp] = utGetMinMargins(allmargin(mag(:),phase(:),w));
      
else
   % Minimum margins of multiple response
   Gm = zeros(1,n);
   Pm = zeros(1,n); 
   Wcg = zeros(1,n); 
   Wcp = zeros(1,n);
   for j=1:n,
      [Gm(j),Pm(j),Wcg(j),Wcp(j)] = imargin(mag(:,j),phase(:,j),w);
   end
end

% If no left hand arguments then plot graph and show location of margins.
if no==0,
   % Call with graphical output: plot using LTIPLOT
   if n>1
       ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithNoOutputArgs','imargin')
   end
   
   % Create plot (visibility ='off')
   h = ltiplot(gca,'bode',{''},{''},[],cstprefs.tbxprefs);
   
   % Create Bode response
   r = h.addresponse(1,1,1);
   r.Data.Frequency = w;
   r.Data.Focus = [w(1) w(end)];
   r.Data.Magnitude = mag(:);
   r.Data.Phase = phase(:);
   r.Data.PhaseUnits = 'deg';
   initsysresp(r,'bode',h.Options,[])
   
   % Add margin display
   r.addchar('Stability Margins','resppack.MinStabilityMarginData', ...
      'resppack.MarginPlotCharView');
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot crated with Visible='off'
   else
      draw(h);  % hold mode
   end
   
   % Right-click menus
   ltiplotmenu(h,'margin');
else
   gm = Gm;
   pm = Pm;
end
