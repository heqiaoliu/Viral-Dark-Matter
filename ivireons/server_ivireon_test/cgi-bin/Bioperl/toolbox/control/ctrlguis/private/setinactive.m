function Diagram = setinactive(InactiveBlocks, InactiveConnections, InactiveSignals, Diagram)
% ------------------------------------------------------------------------%
% Function: SetInactive
% Purpose: Greys out and sends to back inactive items
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.10.1 $ $Date: 2005/11/15 00:54:46 $

ColorI = [1,1,1]*145/255; % Inactive color

% Set inactive blocks
for cnt = InactiveBlocks
    hp = Diagram.B(cnt).PHandle;
    set(hp, 'FaceColor', ColorI, 'EdgeColor', ColorI);
end
% hp = [Diagram.B(cnt).PHandle];
% set(hp, 'FaceColor', ColorI, 'EdgeColor', ColorI);

% Set inactive connector lines/arrows
for cnt = InactiveConnections
    hp = Diagram.L{cnt};
    for cnt2=1:length(hp)
        % use zdata so inactive lines are always behind visible lines
        zdata = -1*ones(size(get(hp(cnt2),'xdata'))); 
        if strcmp('line',get(hp(cnt2),'type'))
            set(hp(cnt2), 'Color', ColorI,'zdata',zdata);
        else
            set(hp(cnt2), 'FaceColor', ColorI, 'EdgeColor', ColorI,'zdata',zdata);
        end
    end
end

% Set Inactive Signals
for cnt = InactiveSignals
    hp = Diagram.S(cnt).Signal;
    for cnt2=1:length(hp)
        % use zdata so inactive lines are always behind visible lines
        zdata = -1*ones(size(get(hp(cnt2),'xdata'))); 
        if strcmp('line',get(hp(cnt2),'type'))
            set(hp(cnt2), 'Color', ColorI,'zdata',zdata);
        else
            set(hp(cnt2), 'FaceColor', ColorI, 'EdgeColor', ColorI,'zdata',zdata);
        end
    end
end


