function dataFlat = flattenData(numberTimeSteps, dimensions, data)
    if isscalar(dimensions) 
        % Input port is NOT matrix, it is dimension 1 or n where n>1
        dataFlat = data;
    else 
        % Input port is [n_1 n_2 ... n_i]  where n_i >=1 and i>=2
        dataFlat = reshape(data,[prod(dimensions) numberTimeSteps]);
    end