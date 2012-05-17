function [x,a,b] = roundfocus(Domain,focus,x,a,b)
% ROUNDFOCUS  Rounds time or freq. focus to entire values.
% 
%   LOW-LEVEL FUNCTION.

%   Author(s): P. Gahinet, B. Eryilmaz
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:51:38 $

% RE: Used by time and freq. response functions when called with output
%     arguments

switch Domain
   case 'freq'
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
      
   case 'time'
      if isempty(focus)
         focus = [0 1];
      end

      xmin = focus(1) - 1e3*eps;
      xmax = focus(2) + 1e3*eps;
      idx = find(x >= xmin & x <= xmax);
      x = x(idx);
      a = a(idx,:,:);

      if size(b,1)>0
         b = b(idx,:,:);
      end
end
