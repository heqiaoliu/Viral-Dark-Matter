function [isu,isy]=iddsink(CB)
% iddata sink mask init fcn

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $ $Date: 2006/12/27 20:57:21 $

%porty = find_system(CB,'LookUnderMasks','all','FollowLinks','on','Name','y');
%portu = find_system(CB,'LookUnderMasks','all','FollowLinks','on','Name','u');

c = get_param(CB, 'PortConnectivity');
%[c(1).SrcBlock c(2).SrcBlock]
if ~ishandle(c(1).SrcBlock)
    % input port is disconnected
   isu = 0;
   set_param(CB,'isu','off') 
else
    isu = 1;
   set_param(CB,'isu','on') 
end

if ~ishandle(c(2).SrcBlock)
    % output port is disconnected
    isy = 0;
   set_param(CB,'isy','off') 
else
    isy = 1;
   set_param(CB,'isy','on') 
end
