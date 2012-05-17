function runtimeCalloutList = getRuntimeCalloutList(this)

    % Copyright 2007 The Mathworks, Inc
    
    if this.AddCallouts
        calloutList = this.CalloutList;
        source = this.Source;
        
        if ischar(calloutList) 
            if strcmp('%<auto>', calloutList)
                calloutList = locGetAutoCalloutList(this);
            else
                calloutList = this.resolveObject(calloutList);
            end
        end

        nCallouts = length(calloutList);
        runtimeCalloutList = repmat(handle(1), [1, nCallouts]);
        nRuntimeCallouts = 0;

        for i = 1:nCallouts
            obj = this.resolveObject(calloutList(i));

            if (~isempty(obj) && ...
                    (obj ~= source) && ...
                    (obj.up == source) && ...
                    this.isObjectVisible(obj))

                nRuntimeCallouts = nRuntimeCallouts + 1;
                runtimeCalloutList(nRuntimeCallouts) = obj;
            end
        end

        runtimeCalloutList = runtimeCalloutList(1:nRuntimeCallouts);
    
    else
        runtimeCalloutList = [];
    end
    
end

%-------------------------------------------------------------------------------
function calloutList = locGetAutoCalloutList(this)
            
    src = this.Source;
    srcChildren = src.getChildren;
    nChildrens = length(srcChildren);
    calloutList = repmat(handle(1), [1, nChildrens]);
    nCallouts = 0;
    
    if isa(src, 'Simulink.Object')
        for i = 1:nChildrens
            if isa(srcChildren(i), 'Stateflow.Chart')
                nCallouts = nCallouts + 1;
                calloutList(nCallouts) = this.resolveObject(srcChildren(i).Path);
            else
                h = classhandle(srcChildren(i));
                if isprop(h, 'BlockType')
                    nCallouts = nCallouts + 1;
                    calloutList(nCallouts) = srcChildren(i);
                end
            end
        end

    else
        for i = 1:nChildrens
            if (isa(srcChildren(i), 'Stateflow.State') ...
                || isa(srcChildren(i), 'Stateflow.Box') ...
                || isa(srcChildren(i), 'Stateflow.Function') ...
                || (isa(srcChildren(i), 'Stateflow.Transition') ...
                    && ~strcmp(srcChildren(i).LabelString, '?')))
           
                nCallouts = nCallouts + 1;
                calloutList(nCallouts) = srcChildren(i);
            end
        end
        
    end

    calloutList = calloutList(1:nCallouts);
end
