function runtimeOrientation = getRuntimeOrientation(this)
    % Get runtime orientation
    
    % Copyright 2007 The Mathworks, Inc

    switch this.Orientation
        case 'auto' % Largest dimension vertical
            srcExtents = this.Portal.targetObjectExtents;
            if (srcExtents.width > srcExtents.height)
                runtimeOrientation = 'landscape';
            else
                runtimeOrientation = 'portrait';
            end

        case 'inherit' % Use src's PaperOrientation
            src = this.Source;
            if (isa(src, 'Simulink.Object') || isa(src, 'Stateflow.Chart'))
                runtimeOrientation = src.PaperOrientation;

            elseif isa(src, 'Stateflow.Object');
                runtimeOrientation = src.Chart.PaperOrientation;

            else
                error('DAStudio:Snapshot:InheritOrientation', ...
                    'Can not get object''s PaperOrientation for object [%s]', ...
                    class(src));
            end

        otherwise % rotated | landscape | portrait
            runtimeOrientation = this.Orientation;
    end
end
