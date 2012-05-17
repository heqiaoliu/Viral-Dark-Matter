function [flag,fig] = deeflag(str, silent)
%DEEFLAG True if figure is currently displayed on screen.
%   [FLAG,FIG] = DEEFLAG(STR,SILENT) checks to see if any figure 
%   with Name STR is presently on the screen. If such a figure is 
%   presently on the screen, FLAG=1, else FLAG=0.  If SILENT=0, the
%   figures are brought to the front.

%   Copyright 1990-2008 The MathWorks, Inc.
%   Jay Torgerson

switch nargin
    case 0, error('Simulink:deeflag:NotEnoughInputs',...
            'DEEFLAG must have at least one argument.');
    case 1, silent = false;
    otherwise,
end

flag = false;
fig  = findall(0,'type','figure','name',str);

if ishandle(fig)
    flag = true;
    if ~silent
        figure(fig);
    end
end

end % deeflag
