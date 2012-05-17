
%   Copyright 2010 The MathWorks, Inc.

classdef FactoryBase
    %FACTORYBASE Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Abstract)
        out = newCVariable(~,name,type)
        out = newCTypename(~,name)
        out = newCStructType(~,name)
        out = newCFunction(~,name,type)
    end
end

