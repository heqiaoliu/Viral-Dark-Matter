function [flag,fig] = idfigflag(str,silent)
%FIGFLAG True if figure is currently displayed on screen.
%   [FLAG,FIG] = FIGFLAG(STR,SILENT) checks to see if any figure 
%   with Name STR is presently on the screen. If such a figure is 
%   presently on the screen, FLAG=1, else FLAG=0.  If SILENT=0, the
%   figures are brought to the front.

% Copied from matlab/uitools

%   Author: A. Potvin, 12-1-92,6-16-95
%   Modified: E.W. Gulley, 8-9-93
%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2008/05/19 23:03:39 $

ni = nargin;
error(nargchk(1,2,ni,'struct'))
if ni==1
   silent = 0;
end

fig = findobj('Type','figure','Name',str)';
flag = ~isempty(fig) && ishandle(fig);
if flag && ~silent,
   for i=fig,
      figure(i)
   end
end

% end idfigflag
