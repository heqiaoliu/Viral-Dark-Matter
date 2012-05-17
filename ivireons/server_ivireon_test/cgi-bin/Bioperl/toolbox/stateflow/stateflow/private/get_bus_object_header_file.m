function headerFile = get_bus_object_header_file(busObjName,recursive)

%   Copyright 2006-2009 The MathWorks, Inc.

if nargin == 1
    recursive = false;
end

headerFile = getOneHeader(busObjName,recursive);

end

function headerFile = getOneHeader(busName,recursive)
headerFile = '';
try
    % This function may be called recursively on fields of a bus that are
    % not themselves buses.  We try to eliminate the most obvious values
    % that are not buses before doing the expensive EVALIN.
    
    % Valid workspace names must be all characters. This discards some
    % types like fixdt(1,16,0).
    if isempty(regexp(busName,'^\w+$','once'))
        return;
    end
    builtinTypes = '^(double|single|logical|boolean|uint32|int32|uint16|int16|uint8|int8)$';
    if ~isempty(regexp(busName,builtinTypes,'once'))
        return;
    end
    if ~evalin('base',['exist(''' busName ''')'])
        return;
    end

    bus = evalin('base',busName);
    if ~isa(bus,'Simulink.Bus')
        % It isn't a Simulink.Bus do an early return.
    elseif ~isempty(bus.HeaderFile)
        headerFile = bus.HeaderFile;
    elseif recursive
        es = bus.Elements;
        for i = 1:length(es)
            e = es(i);
            headerFile = getOneHeader(e.DataType,recursive);
            if ~isempty(headerFile)
                return;
            end
        end
    end
catch ME %#ok
    headerFile = '';
end

end
