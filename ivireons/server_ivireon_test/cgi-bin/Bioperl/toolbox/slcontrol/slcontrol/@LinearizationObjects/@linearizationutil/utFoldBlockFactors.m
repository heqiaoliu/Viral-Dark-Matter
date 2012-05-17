function [sys,stateNames] = utFoldBlockFactors(this,upper_lft,BlockFactors,opt,varargin)
% UTFOLDBLOCKFACTORS 
%

% Author(s): John W. Glass 15-Oct-2008
%   Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/05/23 08:19:52 $

% Use state names if they are externally specified.
if isempty(varargin)
    stateNames = repmat({''},size(upper_lft.A,1),1);
else
    stateNames = varargin{1};
end    

% Close the lft over the replacement parts
% USYSdelta = [];
upper_lftTs = upper_lft.Ts;
systems = {};
isuss = false;
for ct = 1:numel(BlockFactors)
    if ~isempty(BlockFactors(ct).Factor)
        sys_replace = BlockFactors(ct).Factor;
        if isa(sys_replace,'tf') || isa(sys_replace,'zpk') || isa(sys_replace,'double')
            sys_replace = ss(sys_replace);
        elseif isa(sys_replace,'umat') || isa(sys_replace,'ureal')|| isa(sys_replace,'ultidyn')
            sys_replace = uss(sys_replace);
            sys_replace.Ts = upper_lftTs;
        end
        sys_rep_Ts = sys_replace.Ts;
        if (sys_rep_Ts ~= upper_lftTs) && ...
                ((upper_lftTs ~= -1) && (upper_lftTs ~= -2))
            if sys_rep_Ts < 0
                sys_replace.Ts = upper_lftTs;
            else
                sys_replace = utRateConversion(this,sys_replace,upper_lftTs,opt);
            end
        end
        
        sys_rep_StateName = sys_replace.StateName;
        if ~strcmp(opt.RateConversionMethod,'zoh') && (sys_rep_Ts ~= upper_lftTs)
            sys_rep_StateName = repmat({'?'},numel(sys_rep_StateName),1);
        elseif numel(sys_rep_StateName) > 0 && ...
                isequal(sys_rep_StateName,repmat({''},numel(sys_rep_StateName),1))
            repstatename = repmat({BlockFactors(ct).Name},numel(sys_rep_StateName),1);
            sys_replace.StateName = repstatename;
        end
        stateNames = [stateNames;sys_rep_StateName];
        
        % Store for later when folding the lft
        systems{ct} = sys_replace;
        if isa(sys_replace,'uss')
            isuss = true;
        end
    end
end

% Check for consistency if there are uss systems
if isuss
    try
        ufind(systems{:});
    catch Ex
        ctrlMsgUtils.error('Slcontrol:linearize:InconsistentUncertainVariableDefinitions')
    end
end

if ~isempty(systems)
    sys = lft(upper_lft,append(systems{:}));
else
    sys = upper_lft;
end

if isa(sys,'ss')
    sys = sminreal(utSimplifyDelay(sys));
end
