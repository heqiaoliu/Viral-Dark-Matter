function systems = dee_find_system(varargin)
%DEE_FIND_SYSTEM Get a sorted list of DEE related systems.

%   Copyright 1990-2002 The MathWorks, Inc.

    systems = find_system(varargin{:});
    
    if isempty(systems)
        return;
    end
    
    % force systems to be in numeric order wrt the integer at the end
    N = length(systems);
    index = zeros(1,N);
    pattern = '\d*$'; % look for integer at the end of the block path
    for i=1:N
        sys = systems{i};
        ind = regexp(sys, pattern);
            
        if ~isempty(ind)
            index(i) =  str2num(sys(ind:end));
        end
        
    end
    
    [junk perm] = sort(index);
    
    % permute the systems list so it's sorted by index
    systems = systems(perm);
end

        
        
    
    