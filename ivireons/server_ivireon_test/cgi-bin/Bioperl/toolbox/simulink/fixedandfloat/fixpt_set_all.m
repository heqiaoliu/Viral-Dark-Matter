function fixpt_set_all(SystemName,pName,pValue)
%  FIXPT_SET_ALL Sets a property for every Fixed Point Block in a subsystem.
%
%  Usage
%    FIXPT_SET_ALL( SystemName, fixptPropertyName, fixptPropertyValue )
%
%  Example: 
%  % set every fixed point block in the subsystem to use to floor rounding
%  % and to saturate on overflows.
%
%   open_system('fxpdemo_feedback');
%   fixpt_set_all( 'fxpdemo_feedback/Controller', 'RndMeth', 'Floor' );
%   fixpt_set_all( 'fxpdemo_feedback/Controller', 'DoSatur', 'on' );
%

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.6.2.1 $  
% $Date: 2009/05/14 17:50:26 $

to_do = find_system(SystemName,'LookUnderMasks','all');

nblks = length(to_do);

for i=1:nblks

    try
        mn = get_param(to_do{i},'MaskNames');
        
        if ~isempty(mn)
        
            if any( strcmp(mn,pName) )
            
                set_param(to_do{i},pName,pValue)
                
            end
        end
    catch
    end
end
