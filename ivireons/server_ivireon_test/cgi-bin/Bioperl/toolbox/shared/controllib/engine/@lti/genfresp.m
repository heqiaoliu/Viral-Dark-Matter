function [mag,ph,w,FocusInfo] = genfresp(sys,Grade,w)
%GENFRESP  Generates frequency grid and response data for MIMO model.
%
%  [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC) computes the 
%  frequency response magnitude MAG and phase PH (in radians) of a single 
%  MIMO model SYS on some auto-generated frequency grid W.  
%
%  GRADE and FGRIDSPEC control the grid density and span as follows:
%    GRADE          1 :  Nyquist plot (finest)
%                   2 :  Nichols plot  
%                   3 :  Bode plot
%                   4 :  Sigma plot
%    FGRIDSPEC     [] :  auto-ranging
%            'decade' :  auto-ranging + grid includes 10^k points 
%         {fmin,fmax} :  user-defined range (grid spans this range)
%
%  The structure FOCUSINFO contains the preferred frequency ranges for 
%  displaying each grade of response (FOCUSINFO.Range(k,:) is the preferred
%  range for the k-th grade).
%
%  For Robust Control Toolbox use only.

%  Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:52:18 $

% REVISIT: DELETE WHEN RCTB IS MCOS COMPLIANT

% RE: 1) Never call with fully specified grid
%     2) Phase is unwrapped and adjusted to account for DC characteristics
%     3) MAG and PH are of size Nf-by-Ny-by-Nu
%     4) Used by RCAST
ExactDecade = strcmp(w,'decade');
if ExactDecade
   w = [];
end
[mag,ph,w,FocusInfo] = freqresp(sys.Data_,Grade,w,false);
mag = permute(mag,[2 3 1]);
ph = permute(ph,[2 3 1]);
if ExactDecade
   [w,mag,ph] = roundfocus(FocusInfo.Focus,w,mag,ph);
end
% Return pre-R2007a FocusInfo format
FocusInfo = struct('Range',FocusInfo.Focus,'Soft',FocusInfo.Soft);


function [x,a,b] = roundfocus(focus,x,a,b)
% ROUNDFOCUS  Rounds time or freq. focus to entire values.
% 
%   LOW-LEVEL FUNCTION.
%     arguments

% Round to entire decades
if isempty(focus)
   % Base adhoc value on mean log-frequency to avoid returning
   % empty x (g273480)
   lxmean = mean(log10(x(x>0)));
   focus = 10.^[lxmean-1,lxmean+1];
end
% Make sure [xmin,xmax] contains entire focus (otherwise may clip
% FRD response, see g322552)
if focus(1)>0
   xmin = floor(log10(focus(1))+100*eps);
else
   xmin = -Inf;
end
xmax = ceil(log10(focus(2))-100*eps);
idx = find(x>=10^xmin & x<=10^xmax);
x = x(idx);
if nargin<5
   % sigma
   a = a(:,idx);
else
   % bode, nichols, nyquist
   a = a(:,:,idx);
   b = b(:,:,idx);
end
