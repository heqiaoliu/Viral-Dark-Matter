function [StructNames, ListFields] = AnalyzeStructures(T)

a=mtfind(T,'Kind','DOT');

StructNames = cell(1,0);
ListFields = cell(1,0);
NrStruct = 0;

    function result = IsSubstring(sub, full)
    res = strfind(full, sub);
    result = false;
    if ~isempty(res)
        if res(1) == 1, result = true; end
    end
    
    end

% Traverse all nodes that have 'DOT'
for ii=indices(a)
    count = 1;  % Depth of the structure
    stop = false;
    
    % For each 'DOT' node
    b=mtfind(select(a,ii));
    b0 = b;
    while ~stop
        % Go to left child until 'ID' i.e. structure name
        b = Left(b);
        % Protect against case where left-mode node isn't 'ID'
        if isempty(b)
            stop = true;
        else
            % If find another 'DOT' on the way, indicate another level of
            % hierarchy
            stop = strcmp(kind(b),'ID') || isempty(b);
            if strcmp(kind(b),'DOT')
                count = count + 1;
            end
        end
    end
    if isempty(b), name = ''; else name = string(b); end
    
    if count 
        cnt = 1;
        fieldtrace = string(b);
        while b ~= b0
            b = Parent(b);
            if strcmp(kind(b),'DOT')
                cnt = cnt + 1;
                fieldtrace = sprintf('%s.%s',fieldtrace,string(Right(b)));
            end
        end
    end
    
    % Add structure to list or take max of depth if already in list
    [isthere, loc] = ismember(name, StructNames);
    if ~isthere
        NrStruct = NrStruct + 1;  % One more structure found
        StructNames{NrStruct} = name; % Structure name
        ListFields(NrStruct).name{1} = fieldtrace;
    else
        % If there is already a list, do not add if substring of existing
        % one. Or remove existing substring
        
        stop = false;
        kk = 0;
        AppendToList = true;
        while ~stop && kk < length(ListFields(loc).name)
            kk = kk+1;
            existing = ListFields(loc).name{kk};

            if IsSubstring(fieldtrace,existing)
                % Ignore this field as it is a substring of an existing one
                stop = true;
                AppendToList = false;
            else
                % Test if there is a field that is a substring of this one
                if IsSubstring(existing,fieldtrace)
                    stop = true;
                    ListFields(loc).name{kk} = fieldtrace;
                    AppendToList = false;
                end
            end
        end
        
        if AppendToList
            ListFields(loc).name{end+1} = fieldtrace;
        end
 
    end
    
    % Note: something in the tree with a 'DOT' marker could be a structure
    % or a class. This function doesn't make the difference and will
    % classify classes as structures.
        
end
    
end


