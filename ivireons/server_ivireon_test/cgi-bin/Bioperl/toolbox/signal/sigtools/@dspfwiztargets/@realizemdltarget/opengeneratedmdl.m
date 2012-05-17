function opengeneratedmdl(this)
%OPENGENERATEDMDL   

%   Author(s): V. Pellissier
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:47 $

sys = this.system;
slindex = findstr(sys,'/');

try
    if strcmpi(get_param(sys(1:slindex(end)-1),'Mask'),'off')
        % Open only unmasked subsystems
        open_system(sys(1:slindex(end)-1));
    end
catch ME %#ok<NASGU> 

    % If there is no mask, open system
    open_system(sys(1:slindex(end)-1));
end
% [EOF]
