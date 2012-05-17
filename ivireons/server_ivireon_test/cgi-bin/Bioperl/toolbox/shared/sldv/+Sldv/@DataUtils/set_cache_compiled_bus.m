function set_cache_compiled_bus(model, status)
%    Before getting compiled port information, we need to set 
%    CacheCompiledBusStruct to 'on' on the model Outport blocks. If the
%    model doesn't compile with StrictBusMsg 'ErrorLevel1', then use this
%    utility to turn it off. 

%   Copyright 2008-2009 The MathWorks, Inc.

    if ischar(model)
        try
            modelH = get_param(model,'Handle');
        catch myException %#ok<NASGU>
            modelH = [];
        end
    else
        modelH = model;
    end       
  
    outportBlksH = find_system(modelH, ...
                             'SearchDepth',1,...
                             'FollowLinks','on',...                               
                             'BlockType','Outport'); 
                             
    for idx = 1 : length(outportBlksH)        
        bpHandles = get_param(outportBlksH(idx), 'porthandles');
        ph = bpHandles.Inport;        
        set_param(ph,'CacheCompiledBusStruct',status);        
    end    
end