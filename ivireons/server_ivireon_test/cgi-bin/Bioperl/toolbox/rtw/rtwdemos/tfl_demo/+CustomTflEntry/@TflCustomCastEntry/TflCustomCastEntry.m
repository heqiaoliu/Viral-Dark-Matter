
%   Copyright 2009 The MathWorks, Inc.

classdef TflCustomCastEntry < RTW.TflCOperationEntryML
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
            
            % The base class checks word size and signess. The Slopes and Biases
            % have been wildcarded, so the only additional checking needed here is
            % to make sure the biases are zero and that there are only two
            % conceptual arguments (one result, one input)
            
            ent = []; % default the return to empty indicating the match failed.
            
            if length(hCSO.ConceptualArgs) == 2 && ...
                    hCSO.ConceptualArgs(1).Type.Bias == 0 && ...
                    hCSO.ConceptualArgs(2).Type.Bias == 0
                
                % Want to modify the default implementation. Since this is a
                % factory entry, a concrete entry is created using this factory
                % as a template. The type of entry being created is a standard
                % TflCOperationEntry. Using the standard operation entry is
                % sufficient since it contains all the necessary information and
                % a custom match function will no longer be needed.
                ent = RTW.TflCOperationEntry(hThis);
                
                % Since this entry is modifying the implementation for specific
                % fraction lengths (arguments 2 and 3) then the conceptual argument
                % wildcards must be removed (the wildcards were inherited from the
                % factory when it was used as a template for the concrete entry).
                % This concrete entry is now for a specific slope and bias
                % (not for any slope and bias). The hCSO holds the correct
                % slope and bias values (created by the code generator).
                for idx=1:2
                    ent.ConceptualArgs(idx).CheckSlope = true;
                    ent.ConceptualArgs(idx).CheckBias = true;
                    
                    % Set the specific Slope and Biases
                    ent.ConceptualArgs(idx).Type.Slope = hCSO.ConceptualArgs(idx).Type.Slope;
                    ent.ConceptualArgs(idx).Type.Bias = 0;
                end
                
                % Set the fraction lengths in the implementation function. It is
                % expected that these implementation arguments are added to the
                % factory entry when it is instantiated in a TFL definition file.
                ent.Implementation.Arguments(2).Value = -1.0*hCSO.ConceptualArgs(2).Type.FixedExponent;
                ent.Implementation.Arguments(3).Value = -1.0*hCSO.ConceptualArgs(1).Type.FixedExponent;
            end
        end
    end
end
