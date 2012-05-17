function createAxes(this)
%CREATEAXES    Create axes for the scope

%   @commscope/@eyediagram
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/12/28 04:06:48 $

if this.PrivOperationMode
    pos = get(this.PrivScopeHandle, 'Position');
    aspectRatio = pos(4)/pos(3);
    if ( aspectRatio < 1 )
        % It is just I
        set(this.PrivScopeHandle, 'Position', [pos(1) pos(2)-pos(4)*0.37/0.63 pos(3) pos(4)/0.63]);
    end
    
    % Add axes for Inphase part (This will be the last handle in Childrens)
    hRe = axes('Parent', this.PrivScopeHandle, ...
        'OuterPosition', [0 0.50 1 0.49], ...
        'Tag', 'InPhaseAxes');
    formatAxes(hRe, 'In-phase Signal');
    
    % Add axes for Quadrature part (This will be the second from last handle in
    % Childrens)
    hIm = axes('Parent', this.PrivScopeHandle, ...
        'OuterPosition', [0 0.01 1 0.49], ...
        'Tag', 'QuadratureAxes');
    formatAxes(hIm, 'Quadrature Signal');
else
    pos = get(this.PrivScopeHandle, 'Position');
    aspectRatio = pos(4)/pos(3);
    if ( aspectRatio > 1 )
        % It is I & Q
        set(this.PrivScopeHandle, 'Position', [pos(1) pos(2)+pos(4)*0.37 pos(3) pos(4)*0.63]);
    end
    
    % Add axes for Inphase part (This will be the last handle in Childrens)
    hRe = axes('Parent', this.PrivScopeHandle, ...
        'OuterPosition', [0 0.01 1 0.98], ...
        'Tag', 'InPhaseAxes');
    formatAxes(hRe, 'In-phase Signal');
end
end
%-------------------------------------------------------------------------------
function formatAxes(ha, axesTitle)
title(ha, axesTitle);
xlabel(ha, 'Time (s)');
ylabel(ha, 'Amplitude (AU)');
set(ha, 'XGrid', 'on', ...
    'YGrid', 'on', ...
    'XColor', [0.2 0.2 0.2], ...
    'YColor', [0.2 0.2 0.2], ...
    'ZColor', [0.2 0.2 0.2]);
end
% [EOF]
