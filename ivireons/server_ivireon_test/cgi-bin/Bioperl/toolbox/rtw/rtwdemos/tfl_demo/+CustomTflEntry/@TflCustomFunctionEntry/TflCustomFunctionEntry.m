
%   Copyright 2009 The MathWorks, Inc.

classdef TflCustomFunctionEntry < RTW.TflCFunctionEntryML
    methods
        function ent = do_match(hThis, ...
                hCSO, ... %#ok
                targetBitPerChar, ... %#ok
                targetBitPerShort, ... %#ok
                targetBitPerInt, ... %#ok
                targetBitPerLong ) %#ok
            % DO_MATCH - Create a custom match function. The base class
            % checks the types of the arguments prior to calling this
            % method. This will check additional data and perhaps modify
            % the implementation function.
            %
            
            ent = [];
            
            % Only use this sin function if the target int size is 32 bits
            if targetBitPerInt == 32
                % Want to modify the default implementation. Need to create a copy first.
                % Want to create a regular CFunction Entry since we do not want to keep
                % adding an implementation arg on every TFL query.
                ent = RTW.TflCFunctionEntry(hThis);
                
                % In this case, the implementaion function takes flag
                % indicatiting degrees vs radians
                
                % The additional argument could be created either in the TFL deinition file 
                % or as follows:
                arg = ent.createTflArgFromParamVals( 'RTW.TflArgNumericConstant', ...
                    'Name', 'u2',...
                    'IsSigned', true, ...
                    'WordLength', 32, ...
                    'FractionLength', 0, ...
                    'Value', 1);
                
                ent.Implementation.addArgument(arg);
            end            
        end
    end
end
