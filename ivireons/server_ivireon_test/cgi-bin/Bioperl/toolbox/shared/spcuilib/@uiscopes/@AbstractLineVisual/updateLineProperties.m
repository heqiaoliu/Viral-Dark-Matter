function updateLineProperties(this)
%UPDATELINEPROPERTIES Update the line properties.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/05/20 03:08:19 $

hLine = this.Lines;

defaultProps = uiscopes.AbstractLineVisual.getDefaultLineProperties;
defaultColors = get(this.Axes, 'ColorOrder'); 

lineProperties = getPropValue(this, 'LineProperties');

hLineProperties = this.LineProperties;

for indx = 1:length(hLine)
    
    if numel(lineProperties) < indx
        props = defaultProps;
        props.Color = defaultColors(rem(indx-1, size(defaultColors, 1))+1, :);
    else
        props = lineProperties(indx);
    end
    
    style   = props.LineStyle;
    visible = props.Visible;
    marker  = props.Marker;
    color   = props.Color;
    
%     % If we have a mismatch with stem, fix it.
%     if strcmp(marker, 'stem')
%         if ~strcmp(get(hLine(indx), 'Type'), 'hggroup')
%             hNew = stem(get(hLine(indx), 'XData'), get(hLine(indx), 'YData'), ...
%                 'Parent', this.Axes, 'ShowBaseLine', 'off', 'EraseMode', 'XOR');
%             delete(hLine(indx));
%             hLine(indx) = hNew;
%             this.Lines = hLine;
%         end
%         marker = 'o';
%     elseif strcmp(get(hLine(indx), 'Type'), 'hggroup')
%         hNew = line(get(hLine(indx), 'XData'), get(hLine(indx), 'YData'), ...
%             'Parent', this.Axes, 'EraseMode', 'XOR');
%         delete(hLine(indx));
%         hLine(indx) = hNew;
%         this.Lines = hLine;
%     end

    if ~feature('hgusingmatlabclasses')
        oldEraseMode = get(hLine(indx), 'EraseMode');
    end
    
    % Set all the properties at once.
    set(hLine(indx), props);
    
    if ~feature('hgusingmatlabclasses')
        % Toggle the EraseMode to force a refresh.
        set(hLine(indx), 'EraseMode', 'normal');
        drawnow;
        set(hLine(indx), 'EraseMode', oldEraseMode);
    end
    
    if ~isempty(hLineProperties)
        hChannel = hLineProperties.findchild(sprintf('Channel%d', indx));
        if ~isempty(hChannel)
            
            hVisible = hChannel.findchild('Visible');
            set(hVisible.WidgetHandle, 'Checked', visible);
            
            % Update the styles.
            hStyle  = hChannel.findchild('LineDisplay','LineStyle');
            iterator.visitImmediateChildren(hStyle, @(h) set(h.WidgetHandle, 'Checked', 'off'));
            set(hStyle.findwidget(style), 'Checked', 'on');
            
            % Update the markers.
            hMarker = hChannel.findchild('LineDisplay','Marker');
            iterator.visitImmediateChildren(hMarker, @(h) set(h.WidgetHandle, 'Checked', 'off'));
            set(hMarker.findwidget(marker), 'Checked', 'on');
            
            % Turn any numeric colors we might have to their string versions.
            if isnumeric(color)
                if isequal(color, [0 0 1])
                    color = 'b';
                elseif isequal(color, [1 0 0])
                    color = 'r';
                elseif isequal(color, [0 1 0])
                    color = 'g';
                elseif isequal(color, [0 0 0])
                    color = 'k';
                elseif isequal(color, [0 1 1])
                    color = 'c';
                elseif isequal(color, [1 1 0])
                    color = 'y';
                elseif isequal(color, [1 0 1])
                    color = 'm';
                else
                    color = 'other';
                end
            end
            
            % Update the colors.
            hColor  = hChannel.findchild('LineDisplay','Color');
            iterator.visitImmediateChildren(hColor, @(h) set(h.WidgetHandle, 'Checked', 'off'));
            set(hColor.findwidget(color), 'Checked', 'on');
        end
    end
end

% [EOF]
