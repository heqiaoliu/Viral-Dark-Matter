function obj = loadobj(obj)
%LOADOBJ Load filter for mmreader objects.
%
%    OBJ = LOADOBJ(OBJ) is called by LOAD when an mmreader object is 
%    loaded from a .MAT file. The return value, OBJ, is subsequently 
%    used by LOAD to populate the workspace.  
%
%    LOADOBJ will be separately invoked for each object in the .MAT file.
%

%    NH DT DL
%    Copyright 2005-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.12 $  $Date: 2010/05/10 17:23:27 $
try
    % For old OOPS object.
    if isstruct(obj)
        
        % Get the structure of property values.
        if isfield(obj,'uddobject') % Old UDD Objects
            props = obj.uddobject;
            
            % Construct the object.
            obj = mmreader(fullfile(props.Path, props.Name));
        else % For version SchemaVersion 7.08 MATLAB Objects
            props = obj;
            obj = mmreader(props.ConstructorArgs);
        end
        
        % Set the original settable property values.
        propNames = getSettableProperties(obj.getImpl());
        
        for i = 1:length(propNames)
            try
                set(obj, propNames{i}, props.(propNames{i}));
            catch err %#ok<NASGU>
                warning('MATLAB:mmreader:loadset', ...
                    mmreader.getError('MATLAB:mmreader:loadset', propNames{i}));
            end
        end
        
    % else
        % nothing to do,  object is properly constructed
    end
catch exception
    throwAsCaller( mmreader.convertException( exception ) );
end


end

