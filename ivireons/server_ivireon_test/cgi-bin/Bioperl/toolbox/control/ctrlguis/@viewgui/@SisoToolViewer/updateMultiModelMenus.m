function updateMultiModelMenus(this,Views)
%updateMultiModelMenus  updates the multimodel menus for the SISO Tool LTI
%Viewer.

%   Author(s): C. Buhr
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 16:59:34 $

if nargin == 1
    Views = this.Views;
end

Views = Views(ishandle(Views));

if isUncertain(this.Parent.Loopdata.P)
    EnableFlag = 'on';
else
    EnableFlag = 'off';
end

for ct = 1:length(Views)
    try
        ax = this.Parent.AnalysisView.Views(ct).getaxes;
        hmenu = findobj(get(ax(1),'UIContextMenu'),'Tag','MultiModel');
        set(hmenu,'Enable',EnableFlag)
        if strcmp(EnableFlag,'off') && hasCharacteristic(Views(ct),'MultipleModelView');
            Views(ct).hideCharacteristic('MultipleModelView');
        end
    end
end



