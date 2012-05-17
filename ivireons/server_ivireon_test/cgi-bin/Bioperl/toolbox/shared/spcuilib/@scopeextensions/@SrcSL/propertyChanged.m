function propertyChanged(this, propName)
%PROPERTYCHANGED React to property changes.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/29 16:08:45 $

if ~ischar(propName)
    propName = propName.AffectedObject.Name;
end

switch lower(propName)
    case 'probingsupport'
        newValue = getPropValue(this, 'ProbingSupport');
        if strcmp(newValue, 'SignalLinesOrBlocks') && this.isFloating
            
            model = this.SLConnectMgr.getSystemHandle.Name;
            
            % If there are no lines, but there are blocks selected, connect
            % to the selected blocks.
            if isempty(gsl(model)) && ~isempty(gsb(model))
                selectChangeEventHandler(this, []);
            end
        end
end


% [EOF]
