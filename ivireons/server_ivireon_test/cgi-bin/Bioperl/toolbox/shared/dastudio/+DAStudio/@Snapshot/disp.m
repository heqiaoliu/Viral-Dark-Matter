function disp(this)

    % Copyright 2007 The Mathworks, Inc

    clsDisp = sprintf('[%s]\n', class(this));

    srcDisp = locGetPropDisplayLabel( ...
        'Source', locGetObjectDisplayLabel(this.Source));

    fmtDisp = locGetPropDisplayLabel( ...
        'Format', this.Format);

    fNameDisp = locGetPropDisplayLabel( ...
        'FileName', ['''' this.FileName '''']);

    orientDisp = locGetPropDisplayLabel( ...
        'Orientation', ...
        locGetEnumDispLabel(this.Orientation,  ...
        {'portrait', 'landscape', 'inherit', 'rotated', 'auto'}));

    sizeModeDisp = locGetPropDisplayLabel( ...
        'SizeMode', ...
        locGetEnumDispLabel(this.SizeMode,  ...
        {'scaled', 'fixed', 'auto'}));

    unitDisp = locGetPropDisplayLabel( ...
        'Units', ...
        locGetEnumDispLabel(this.Units,  ...
        {'inches', 'centimeters', 'pixels', 'points'}));

    if strcmp(this.SizeMode, 'fixed')
        zoomDisp = '';
        maxSizeDisp = '';
        fixedSizeDisp = locGetPropDisplayLabel( ...
            'FixedSize', ...
            [locGetVectDisplayLabel(this.FixedSize) ' ' this.Units]);
        isTightDisp = locGetPropDisplayLabel( ...
            'IsTight', locGetTrueFalseLabel(this.IsTight));

        if ~this.IsTight
            isExpandToFitDisp = locGetPropDisplayLabel( ...
                'IsExpandToFit', locGetTrueFalseLabel(this.IsExpandToFit));
        else
            isExpandToFitDisp = '';
        end

    elseif strcmp(this.SizeMode, 'auto')
        zoomDisp = '';
        maxSizeDisp = '';
        fixedSizeDisp = '';
        isTightDisp = '';
        isExpandToFitDisp = '';

    else
        zoomDisp = locGetPropDisplayLabel( ...
            'Zoom', sprintf('%d', this.Zoom));
        fixedSizeDisp = '';
        maxSizeDisp = locGetPropDisplayLabel( ...
            'MaxSize', ...
            [locGetVectDisplayLabel(this.MaxSize) ' ' this.Units]);
        isTightDisp = '';
        isExpandToFitDisp = '';

    end

    viewModeDisp = locGetPropDisplayLabel( ...
        'ViewMode', ...
        locGetEnumDispLabel(this.ViewMode,  ...
        {'full', 'current', 'custom'}));

    if strcmp(this.ViewMode, 'custom')
        viewExtentsDisp = locGetPropDisplayLabel( ...
            'ViewExtents', ...
            [locGetVectDisplayLabel(this.ViewExtents) ' [x y w h]']);
    else
        viewExtentsDisp = '';
    end

    addFrameDisp = locGetPropDisplayLabel( ...
        'AddFrame', locGetTrueFalseLabel(this.AddFrame));

    if this.AddFrame
        frameFileDisp = locGetPropDisplayLabel( ...
            'FrameFile', ['''' this.FrameFile '''']);
    else
        frameFileDisp = '';
    end

    addCalloutsDisp = locGetPropDisplayLabel( ...
        'AddCallouts', locGetTrueFalseLabel(this.AddCallouts));

    if this.AddCallouts
        calloutListDisp = locGetPropDisplayLabel( ...
            'CalloutList', locGetCalloutListDispLabel(this, this.CalloutList));
        calloutSpaceDisp = locGetPropDisplayLabel( ...
            'CalloutSpace', sprintf('%.2f %s', this.CalloutSpace, this.Units));
    else
        calloutListDisp = '';
        calloutSpaceDisp = '';
    end

    whiteSpaceDisp = locGetPropDisplayLabel( ...
        'WhiteSpace', ...
        [locGetVectDisplayLabel(this.WhiteSpace) ' ' this.Units ' [top left bottom right]']);

    disp([clsDisp, ...
        srcDisp, ...
        fmtDisp, ...
        fNameDisp, ...
        orientDisp, ...
        sizeModeDisp, ...
        unitDisp, ...
        zoomDisp, ...
        maxSizeDisp, ...
        fixedSizeDisp, ...
        isTightDisp, ...
        isExpandToFitDisp, ...
        viewModeDisp, ...
        viewExtentsDisp, ...
        addFrameDisp, ...
        frameFileDisp, ...
        addCalloutsDisp, ...
        calloutListDisp, ...
        calloutSpaceDisp, ...
        whiteSpaceDisp]);

end

%-------------------------------------------------------------------------------
function dispLabel = locGetObjectDisplayLabel(obj)
    if isempty(obj)
        dispLabel = '[]';

    elseif isa(obj, 'Simulink.Object')
        dispLabel = ['[' obj.getFullName ']'];

    elseif isa(obj, 'Stateflow.Object')
        dispLabel = obj.Path;
        if ~isa(obj, 'Stateflow.Chart')
            dispLabel = ['[' dispLabel '/' obj.Name ']'];
        end

    else
        dispLabel = ['[' class(obj) ']'];
    
    end
    dispLabel = strrep(dispLabel, sprintf('\n'), ' ');

end

%-------------------------------------------------------------------------------
function dispLabel = locGetVectDisplayLabel(vect)
    dispLabel = '[';
    if ~isempty(vect)
        dispLabel = [dispLabel sprintf('%.2f', vect(1)) ];
    end
    for i = 2:length(vect)
        dispLabel = [dispLabel ' ' sprintf('%.2f', vect(i)) ]; %#ok
    end

    dispLabel = [dispLabel ']'];
end

%-------------------------------------------------------------------------------
function dispLabel = locGetPropDisplayLabel(propName, propVal)
    lengthToColon = 24;
    leadingSpace = lengthToColon - length(propName);
    
    if (leadingSpace == lengthToColon)
        %No prop, same as the last one.  Used in callout case
        dispLabel = [repmat(' ', [1 leadingSpace]) '  ' propVal sprintf('\n')];
        
    else
        dispLabel = [repmat(' ', [1 leadingSpace]) propName ': ' propVal sprintf('\n')];

    end
end

%-------------------------------------------------------------------------------
function dispLabel = locGetEnumDispLabel(val, list)
    dispLabel = '[';
    for i = 1:length(list)
        if strcmp(val, list{i})
            dispLabel = [dispLabel ' {' val '} |']; %#ok
        else
            dispLabel = [dispLabel ' ' list{i} ' |']; %#ok
        end
    end
    dispLabel = [dispLabel(1:end-2) ' ]'];
end

%-------------------------------------------------------------------------------
function dispLabel = locGetTrueFalseLabel(bool)
    if bool
        dispLabel = 'true';
    else
        dispLabel = 'false';
    end
end

%-------------------------------------------------------------------------------
function dispLabel = locGetCalloutListDispLabel(this, calloutList)

    if isempty(calloutList)
        dispLabel = '[]';

    elseif ischar(calloutList)
        dispLabel = ['[' strrep(calloutList, sprintf('\n'), ' ') ']'];
    
    else
        if ~iscell(calloutList)
            calloutListCell = num2cell(calloutList);
        else
            calloutListCell = calloutList;
        end

        % Display obj on a new line
        obj = this.resolveObject(calloutListCell{1});
        dispLabel = [locGetObjectDisplayLabel(obj) sprintf('\n')];
        nCallouts = length(calloutListCell);
        for i = 2:nCallouts
            obj = this.resolveObject(calloutListCell{i});
            dispLabel = [dispLabel, ...
                locGetPropDisplayLabel('', locGetObjectDisplayLabel(obj))]; %#ok
        end

        % Remove last return carriage
        dispLabel = dispLabel(1:end-1); 
        
    end
end