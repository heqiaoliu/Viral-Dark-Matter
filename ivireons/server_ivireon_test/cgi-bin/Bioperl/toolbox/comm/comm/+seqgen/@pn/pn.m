classdef pn < commsrc.pn
%PN     PN Sequence Generator.    
%
%   WARNING: seqgen.pn will be removed in a future release. Use commsrc.pn instead.
%
%   H = SEQGEN.PN constructs a default PN Sequence Generator object H.
%
%   H = SEQGEN.PN(PROPERTY1, VALUE1, ...) constructs a PN Sequence Generator
%         object H with properties as specified by PROPERTY/VALUE pairs.
%
%   SEQGEN.PN objects have the following properties:
%
%       GenPoly       - Generator polynomial
%
%       InitialStates - Initial states (initial shift register values)
%
%       CurrentStates - Current states (present shift register values)
%
%       NumBitsOut    - Number of bits to output at each GENERATE method invocation
%
%
%   SEQGEN.PN objects also have exactly one of the following properties:
%
%       Mask - Vector of mask bits
%
%       --- OR ---
%
%       Shift - Scalar shift value
%
%   The 'GenPoly' property values specify the shift register connections.
%   Enter these values as either a binary vector or a descending-ordered
%   polynomial. For the binary vector representation, the first and last
%   elements of the vector must be 1. For the descending-ordered polynomial
%   representation, the last element of the vector must be 0.
%
%   A mask vector of binary 0 and 1 values is used to specify which shift
%   register state bits are XORed to produce the resulting output bit
%   value. Alternatively, a scalar shift value may be used to specify an
%   equivalent shift (either a delay or advance) in the output sequence.
%
%   Please refer to the documentation reference for more information,
%   including a detailed block diagram.
%
%   CONSTRUCTORS
%   ------------
%   H = SEQGEN.PN constructs a default PN Sequence Generator object H with
%         default properties. It is equivalent to the following:
%
%   H = SEQGEN.PN('GenPoly',       [1 0 0 0 0 1 1], ...
%                 'InitialStates', [0 0 0 0 0 1],   ...
%                 'CurrentStates', [0 0 0 0 0 1],   ...
%                 'Mask',          [0 0 0 0 0 1],   ...
%                 'NumBitsOut',    1)
%
%
%   ADDITIONAL METHODS
%   ------------------
%
%   PN Sequence Generator objects also have the following methods defined:
%
%       GENERATE - Generate [NumBitsOut x 1] PN Sequence Generator values
%
%       RESET    - Set the 'CurrentStates' values to the 'InitialStates' values
%
%       GETSHIFT - Get the (actual or equivalent) 'Shift' property value
%
%       GETMASK  - Get the (actual or equivalent) 'Mask' property value
%
%
%   LFSR SSRG IMPLEMENTATION DETAILS
%   --------------------------------
%
%   The GENERATE method produces a pseudorandom noise (PN) sequence using a
%   linear feedback shift register (LFSR). The LFSR is implemented using a
%   simple shift register generator (SSRG, or Fibonacci) configuration.
%
%   Please refer to the documentation reference for more information,
%   including a detailed block diagram.
%
%   EXAMPLES:
%   % Construct a PN object
%   h = commsrc.pn('Shift', 0);
%
%   % Output 10 PN bits
%   set(h, 'NumBitsOut', 10);
%   generate(h);
%
%   % Output 10 more PN bits
%   generate(h);
%
%   % Reset (to the initial shift register state values)
%   reset(h);
%
%   % Output 4 PN bits
%   set(h, 'NumBitsOut', 4);
%   generate(h);
%
%   See also COMMSRC, COMMSRC.PN, COMMSRC.PN/GENERATE, COMMSRC.PN/RESET,
%   COMMSRC.PN/GETSHIFT, COMMSRC.PN/GETMASK, COMMSRC.PN/DISP
%   COMMSRC.PN/COPY, MASK2SHIFT, SHIFT2MASK, PRIMPOLY.

%   +seqgen/@pn

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:48:38 $

    %=====================================================================    
    %Public Methods
    %=====================================================================    
    methods           
        function obj = pn(varargin)
            %Constructor for class seqgen.pn
            %This class is kept here for backward compatibility with previous
            %Matlab versions and it inherits all properties and methods of the
            %new pn class found in the +commsrc package.
            
            warning(generatemsgid('DeprecatedFunction'),...
                (['seqgen.pn will be removed in a future release. ',...
                'Use commsrc.pn instead.']));
            
            obj@commsrc.pn(varargin{:})
        end
        %*****************************************************************                 
        function disp(obj)
%DISP   Display PN Sequence Generator object properties
%   DISP(H) displays the properties of SEQGEN.PN object H
%
%   See also COMMSRC, COMMSRC.PN/GENERATE, COMMSRC.PN/RESET, COMMSRC.PN/GETSHIFT
%   COMMSRC.PN/GETMASK, COMMSRC.PN/COPY, MASK2SHIFT, SHIFT2MASK, PRIMPOLY.
            
            %This method needs to overload the superclass disp method in
            %order to be able to correctly display properties
            %(and their values) of loaded R2008a objects
            
            %When an R2008a object is instantiated with a Shift property.
            %its saved version will contain both shift and mask properties
            %and values. For this reason we need to get rid of one of these
            %properties for a correct display.  We will always display the
            %Mask property even if the Shift was used in the object
            %definition since we do not have a way to get its value from
            %the saved R2008a object. 

            %If displaying a single object use custom display. If trying
            %to display a vector of objects, then use builtin display
            %function.            
            if isscalar(obj)
                s = get(obj); 
                if isfield(s,'Mask') && isfield(s,'Shift')
                    s = rmfield(s,'Shift');                
                end           
                % Place NumBitsOut (index 4) last for display
                snew = orderfields(s, [1 2 4 5 3]);
                disp(snew);            
            else
                builtin('disp', obj);
            end
        end        
    end
    %=====================================================================    
    %Static Methods
    %=====================================================================    
    methods (Static = true)
        function obj = loadobj(SeqgenPnData)
            %LOADOBJ overload load(obj) to retrieve data from structure
            %returned by SAVEOBJ and create a SEQGEN.PN object accordingly.
            
            %Must be static since it will be called when no instance of the
            %object exists.
            
            %If object being loaded was saved in R2008a MATLAB
            %then throw a warning. Due to the format of the R2008a saved 
            %object, we are not able to support loading the object in 
            %+seqen\@pn class.
            %We can at least guarantee that the loaded object contains the 
            %correct data values in its properties. But we should warn that
            %the object might not be properly instantiated and that it
            %should not be used.         
                if ~isfield(SeqgenPnData,'Version')

                     s = ['FAILED to load the SEQGEN.PN object correctly. ' ...
                         'The property values of the loaded object are ' ...
                         'correct but the object may be corrupt and not ' ...
                         'behave as expected. If you want to use this ' ... 
                         'object please re-instantiate it manually ' ...
                         'using the loaded property values.'];
                           
                      if (~isfield(SeqgenPnData,'NumBitsOut') ||... 
                          isempty(SeqgenPnData.NumBitsOut))
                        SeqgenPnData.NumBitsOut = 1;
                      end                        

                      obj = seqgen.pn('GenPoly',SeqgenPnData.GenPoly, ...
                      'InitialStates',SeqgenPnData.InitialStates, ...
                      'Mask',SeqgenPnData.PrivMask);   
                      obj.NumBitsOut = SeqgenPnData.NumBitsOut;
                      obj.CurrentStates = SeqgenPnData.CurrentStates;
                                            
                     warning('comm:commsrc:pn:InvalidLoadObject',s);  
                     return
                end       
                
                %See if saved object was instantiated with a shift or a mask
                %property and create the loaded object accordingly. 
                if isfield(SeqgenPnData,'Shift')
                    obj = seqgen.pn('GenPoly',SeqgenPnData.GenPoly, ...
                    'InitialStates',SeqgenPnData.InitialStates, ...
                    'Shift',SeqgenPnData.Shift, ...
                    'NumBitsOut',SeqgenPnData.NumBitsOut);     
                else 
                    obj = seqgen.pn('GenPoly',SeqgenPnData.GenPoly, ...
                    'InitialStates',SeqgenPnData.InitialStates, ...
                    'Mask',SeqgenPnData.Mask, ...
                    'NumBitsOut',SeqgenPnData.NumBitsOut);     
                end                
                obj.CurrentStates = SeqgenPnData.CurrentStates;
                                
        end 
    end 
end
