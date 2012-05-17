
%   Copyright 2010 The MathWorks, Inc.

classdef DataUtils
   
    properties(Constant)
        % These constants should be in sync with the string returned by
        % sf('help', 'data.scope')
        LOCAL_DATA = 0;
        INPUT_DATA = 1;
        OUTPUT_DATA = 2;
        WORKSPACE_DATA = 3;
        IMPORTED_DATA = 4;
        EXPORTED_DATA = 5;
        TEMPORARY_DATA = 6;
        CONSTANT_DATA = 7;
        FUNCTION_INPUT_DATA = 8;
        FUNCTION_OUTPUT_DATA = 9;
        PARAMETER_DATA = 10;
        DATA_STORE_MEMORY_DATA = 11;
    end    
end