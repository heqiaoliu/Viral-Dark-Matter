classdef pn < dynamicprops & hgsetget & sigutils.sorteddisp
%PN     PN Sequence Generator
%   H = COMMSRC.PN constructs a default PN Sequence Generator object H.
%
%   H = COMMSRC.PN(PROPERTY1, VALUE1, ...) constructs a PN Sequence Generator
%         object H with properties as specified by PROPERTY/VALUE pairs.
%
%   commsrc.pn methods:
%       GENERATE - Generate [NumBitsOut x 1] PN Sequence Generator values
%       RESET    - Set the CurrentStates values to the InitialStates values
%       GETSHIFT - Get the (actual or equivalent) Shift property value
%       GETMASK  - Get the (actual or equivalent) Mask property value 
%       COPY     - Make an independent copy of a COMMSRC.PN object
%       DISP     - Display PN Sequence Generator object properties
%
%   commsrc.pn properties:
%       GenPoly       - Generator Polynomial
%       InitialStates - Initial states (initial shift register values) 
%       CurrentStates - Current states (present shift register values)
%       NumBitsOut    - Number of bits to output at each GENERATE method invocation
%
%   COMMSRC.PN objects also have exactly one of the following properties:
%
%        Mask - Vector of mask bits
%
%        --- OR ---
%
%        Shift - Scalar shift value
%
%   H = COMMSRC.PN constructs a default PN Sequence Generator object H with
%         default properties. It is equivalent to the following:
%
%   H = COMMSRC.PN('GenPoly',       [1 0 0 0 0 1 1], ...
%                 'InitialStates', [0 0 0 0 0 1],   ...
%                 'CurrentStates', [0 0 0 0 0 1],   ...
%                 'Mask',          [0 0 0 0 0 1],   ...
%                 'NumBitsOut',    1)
%
%   Examples:
%   % Construct a PN object
%   h = commsrc.pn('Shift', 0);
%
%   % Output 10 PN bits
%   h.NumBitsOut = 10;
%   h.generate;
%
%   % Output 10 more PN bits
%   generate(h);
%
%   % Reset (to the initial shift register state values)
%   reset(h);
%
%   % Output 4 PN bits
%   h.NumBitsOut = 4;
%   generate(h);
%
%   See also COMMSRC, COMMSRC.PN/GENERATE, COMMSRC.PN/RESET,
%   COMMSRC.PN/GETSHIFT, COMMSRC.PN/GETMASK, COMMSRC.PN/DISP
%   COMMSRC.PN/COPY, MASK2SHIFT, SHIFT2MASK, PRIMPOLY.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/01/25 21:28:18 $


    %=====================================================================
    % Define Properties
    %=====================================================================
    properties        
%GenPoly Generator Polynomial
%   Generator polynomial is a row vector that specifies the shift register 
%   connections of the PN generator. It can be given as either a binary  
%   row vector or a polynomial in descending order of powers. For the binary row 
%   vector representation, the first and last elements of the vector must
%   be 1. For the descending-ordered polynomial representation, the vector
%   contains the exponents of z for the nonzero terms of the polynomial
%   in descending order of powers. The last entry must be 0.  
%   For example, [1 0 0 0 0 0 1 0 1] and [8 2 0] represent the same
%   polynomial, p(z) = z8 + z2 + 1.
%   When not specified, GenPoly is set to [1 0 0 0 0 1 1] by default.
%   A mask vector of binary 0 and 1 values is used to specify which shift
%   register state bits are XORed to produce the resulting output bit
%   value. Alternatively, a scalar shift value may be used to specify an
%   equivalent shift (either a delay or advance) in the output sequence.
%   Please refer to the documentation reference for more information,
%   including a detailed block diagram.
        GenPoly
        
%InitialStates Initial states (initial shift register values) 
%   Vector array of initial shift register values (in bits). The length
%   of InitialStates should be one less than the length of GenPoly. When
%   neither GenPoly, nor InitialStates are specified, InitialStates is set
%   to [0 0 0 0 0 1] by default. 
        InitialStates 
                
%NumBitsOut Number of bits to output at each GENERATE method invocation
%   Number of bits to output at each GENERATE method invocation. Its
%   default value is 1. 
        NumBitsOut        
    end
    properties(Dependent = true)
%CurrentStates Current states (present shift register values)
%   Vector array of current shift register values (in bits). The length
%   of CurrentStates should be one less than the length of GenPoly. This 
%   vector is updated  each time the GENERATE method is applied to obtain 
%   an output sequence of NumBitsOut bits. When neither GenPoly, nor
%   InitialStates, and CurrentStates are specified, CurrentStates is set
%   to [0 0 0 0 0 1] by default. CurrentStates and InitialStates must be
%   equal when the object is created. 
        CurrentStates
    end
     properties (GetAccess = protected, SetAccess = private, Hidden = true)              
        % PRIVATE PrivMask
        %for @SetShift, GETSHIFT, and GETMASK)
        PrivMask 
     end
     properties (GetAccess = private, SetAccess = private, Hidden = true)              
        PrivCurrentStates 
     end
    %=====================================================================
    % Define Private Methods
    %=====================================================================
    methods (Access = private)
        
        initObj(obj, varargin); %defined in a separate MATLAB file
        
        %*****************************************************************
        %Create dynamic property Mask
        function createMaskProperty(obj, mask)
            obj.addprop('Mask'); %must be double vector
            mobj = obj.findprop('Mask'); 
            mobj.Dependent = true;
            mobj.SetMethod=@setMask; %defined outside of methods           
            mobj.GetMethod=@getMask; %defined outside of methods 
            obj.Mask = mask;
        end        
        %*****************************************************************        
        %Create dynamic property Shift
        function createShiftProperty(obj, shift)
            obj.addprop('Shift'); %must be double vector
            mobj = obj.findprop('Shift'); 
            mobj.SetMethod=@setShift;  %defined outside of methods  
            obj.Shift = shift;
        end

    end %private methods
    %=====================================================================
    % Define Public Methods
    %=====================================================================
    methods
    %=====================================================================
    % Constructor
    %=====================================================================
        function obj = pn(varargin)
            if (nargin < 1)
                
                % -----------------------------------------------------------
                % Initialize all default values for classes
                % Note: just set GenPoly since this has a side-effect of
                % resetting all other vector property defaults (e.g. states).
                % -----------------------------------------------------------
                obj.GenPoly = [1 0 0 0 0 1 1];
                obj.NumBitsOut = 1;
                % Create dynamic 'Mask' property
                createMaskProperty(obj, [0 0 0 0 0 1]);                                               
            else
                % =====================
                % P-V pairs constructor
                % =====================
                
                % ---------------------------------------------------------------------
                % First, initialize all default values for classes
                %
                % Note: ONLY do this if GenPoly not specified in varargin, since
                % setting the GenPoly property has a side-effect of resetting all other
                % vector property defaults (e.g. states).
                % ---------------------------------------------------------------------
                genPolySpecified = false;
                args             = varargin(:);
                numSpecifiedPrms = floor(length(args)/2);
                for count = 1:numSpecifiedPrms
                    paramStrIdx = 2*count - 1;
                    if strcmpi('genpoly', args(paramStrIdx))
                        genPolySpecified = true;
                        break;
                    end
                end
                
                if (~genPolySpecified)
                    % Initialize all default values
                    % for static class properties
                    obj.GenPoly = [1 0 0 0 0 1 1];
                end                
                % Initialize the rest of the object
                initObj(obj, varargin{:});               
            end      
        end%constructor method
    %=====================================================================
    % Other Methods
    %=====================================================================        
        function yout = generate(obj)
%GENERATE Generate PN Sequence values
%   OUTPUT = GENERATE(H)  generates a row vector of NumBitsOut PN
%   sequence values. The GENERATE method produces a pseudorandom noise (PN) 
%   sequence using a linear feedback shift register (LFSR). The LFSR is 
%   implemented using a simple shift register generator (SSRG, or Fibonacci)
%   configuration. GENERATE causes the CurrentStates property to be updated 
%   according to the new shift register contents.
%   Please refer to the documentation reference for more information,
%   including a detailed block diagram.
%
%   See also COMMSRC,  COMMSRC.PN/DISP, COMMSRC.PN/RESET, COMMSRC.PN/GETSHIFT,
%   COMMSRC.PN/GETMASK, COMMSRC.PN/COPY, MASK2SHIFT, SHIFT2MASK, PRIMPOLY.
                        
            % Get parameters from object
            polyBits = obj.GenPoly(:);
            polyLen  = length(polyBits);
            maskBits = obj.PrivMask(:);
            states   = obj.PrivCurrentStates(:);

        % ===================================================
        % Execute algorithm:
        %
        % Equivalent MATLAB code reference implementation
        % ------------------------------------------
        % for jc = 1:(h.NumBitsOut)
        %     % Compute feedback bit
        %     fdbkBit = 0;
        %     for ji = 2:polyLen
        %         fdbkBit = xor(fdbkBit, (polyBits(ji) * states(ji-1)));
        %     end
        %     
        %     % Apply output mask and compute output bit
        %     tmp = 0;
        %     for ji = 1:(polyLen-1)
        %         tmp = xor(tmp, (states(ji) * maskBits(ji)));
        %     end
        %     yout(jc) = tmp;
        %     
        %     % Update states
        %     for ji = (polyLen-1):-1:2
        %         states(ji) = states(ji-1);
        %     end
        %     states(1) = fdbkBit;
        % end
        % ===================================================
        
        %Return current states to PrivCurrentStates to avoid data type
        %checking every time this function is called
            [yout obj.PrivCurrentStates] = pnSeqGenerate(obj.NumBitsOut, ...
                                                   polyBits, polyLen, ...
                                                   maskBits, states);
        end
        %*****************************************************************               
        function reset(obj)  
%RESET  Set the CurrentStates values to the InitialStates values
%    RESET(H) sets the CurrentStates values to the InitialStates values of 
%    the COMMSRC.PN object H.
%
%    See also COMMSRC, COMMSRC.PN/GENERATE, COMMSRC.PN/DISP, COMMSRC.PN/GETSHIFT,
%    COMMSRC.PN/GETMASK, COMMSRC.PN/COPY, MASK2SHIFT, SHIFT2MASK, PRIMPOLY.
        
            obj.PrivCurrentStates = obj.InitialStates;            
        end        
        %*****************************************************************       
        function newObj = copy(obj)
%COPY   Make an independent copy of a COMMSRC.PN object
%   Example: 
%   h1 = commsrc.pn;
%   h2 = copy(h1); % Copies COMMSRC.PN object h1 to h2
%
%   See also COMMSRC, COMMSRC.PN/GENERATE, COMMSRC.PN/DISP, COMMSRC.PN/GETSHIFT,
%   COMMSRC.PN/GETMASK, COMMSRC.PN/RESET, MASK2SHIFT, SHIFT2MASK, PRIMPOLY.
                                           
            % Get all present property values to copy
            % (be careful to get only one of Shift or Mask)
            pvPairArgs    = cell(1, 8); % all properties except CurrentStates
            pvPairArgs{1} = 'GenPoly';
            pvPairArgs{2} = obj.GenPoly;
            pvPairArgs{3} = 'InitialStates';
            pvPairArgs{4} = obj.InitialStates;
            pvPairArgs{5} = 'NumBitsOut';
            pvPairArgs{6} = obj.NumBitsOut;
            if isempty(findprop(obj,'Mask'))
                % Specify object using 'Shift' property
                pvPairArgs{7}  = 'Shift';
                pvPairArgs{8} = obj.Shift;
            else
                % Specify object using 'Mask' property
                pvPairArgs{7} = 'Mask';
                pvPairArgs{8} = obj.Mask;
            end
                        
            %Create new object with all the specs (except for 'CurrentStates' 
            %from the original object
            newObj = commsrc.pn(pvPairArgs{:});
            
            %Copy the 'CurrentStates' from the original object. Recall that
            %in the initial constructor 'InitialStates' and 'CurrentStates'
            %are forced to be equal, however the actual state of the obj's
            %shift register may not be at the initial state anymore if some
            %bits have already been generated
            newObj.CurrentStates = obj.PrivCurrentStates;
        end
                         
        %*****************************************************************
        function mask = getmask(obj)  
%GETMASK Get the (actual or equivalent) Mask property value
%   MASK=GETMASK(H) gets the actual or equivalent Mask property 
%   value of the COMMSRC.PN object H.
%   Example:
%   h=commsrc.pn('GenPoly',[ 1 0 1 1 ],'Shift',3); %generate object using
%                                                  %a predefined shift
%   getmask(h) % obtain the equivalent Mask using the SHIFT2MASK function
%
%   See also COMMSRC, COMMSRC.PN/GENERATE, COMMSRC.PN/DISP, COMMSRC.PN/GETSHIFT,
%   COMMSRC.PN/COPY, COMMSRC.PN/RESET, MASK2SHIFT, SHIFT2MASK, PRIMPOLY.

        %getmask function, get the Mask value (if the object was created
        %using a Shift value then obj.PrivMask contains the shift to mask 
        %conversion
        %This function does not override get(obj.Mask) or obj.Mask
        %The get override function is called getMask
        
            mask = obj.PrivMask;
        end
        %*****************************************************************
        function shift = getshift(obj)
%GETSHIFT Get the (actual or equivalent) Shift property value
%   SHIFT=GETSHIFT(H) gets the actual or equivalent Shift property 
%   value of the COMMSRC.PN object H.
%   Example:
%   h=commsrc.pn('GenPoly',[ 1 0 1 1 ],'Mask',[0 1 1]); %generate object
%                                                       %using a predefined Mask
%   getshift(h) % obtain the equivalent Shift using the MASK2SHIFT function
%
%   See also COMMSRC, COMMSRC.PN/GENERATE, COMMSRC.PN/DISP, COMMSRC.PN/GETMASK,
%   COMMSRC.PN/COPY, COMMSRC.PN/RESET, MASK2SHIFT, SHIFT2MASK, PRIMPOLY.

        %getshift function, get dynamic property Shift
        %This function does not override get(obj.Shift) or obj.Shift
        %The get override function is called GetShift        

            shift = mask2shift(obj.GenPoly, obj.PrivMask);
        end        
    %=====================================================================
    % Get/Set methods
    %=====================================================================
        function  set.GenPoly(obj, genPoly)
        %Set generator polynomial
           
            %Check data type (double row vector)           
            sigdatatypes.checkFiniteRealDblRowVec(obj, 'GenPoly', genPoly) 
            
            % genPoly must be a binary vector
            % OR a vector of non-negative integers
            % (strictly decreasing powers of two)
            if check_bool_vector(genPoly)
                % Specified using "bits" format
                genPolyBits = genPoly;
                                
                if ~(genPolyBits(1))
                    % Leading bit is a zero
                    genPolyBits = removeLeadingZeros(genPolyBits);                    
                end
                
                if (length(genPolyBits) < 2)
                    error('comm:commsrc:pn:InvalidGenPolyLength', ...
                        'GenPoly length must be greater than one.');
                end
            else
                % Specified using positive integer "shorthand" format
                if ~check_nonneg_int(genPoly)
                    throwInvalidGenPolyValuesError;
                end
                
                % Convert to "bits" format for use below
                genPolyBits = genPolyIntsToBitVector(genPoly);
            end
            
            genPolyBits  = double(genPolyBits);
            genPolyOrder = length(genPolyBits) - 1;
                        
            % Reset all properties controlled by GenPoly attributes
            obj.GenPoly       = genPolyBits;
            obj.InitialStates = [zeros(1, genPolyOrder-1) 1]; %#ok<*MCSUP>
            obj.PrivCurrentStates = [zeros(1, genPolyOrder-1) 1];
            obj.PrivMask      = [zeros(1, genPolyOrder-1) 1];
            
            % Warn if generator polynomial is not primitive
            % (avoid OUT OF MEMORY errors by limiting polynomial orders checked)
            if (genPolyOrder <= 16)                                 
                if ~isequal(gfprimck(fliplr(genPolyBits)), 1)
                    warning('comm:commsrc:pn:GenPolyNotPrimitive',       ...
                        ['GenPoly is not a primitive polynomial. '  ...
                        'Type warning(''off'','                    ...
                        '''comm:commsrc:pn:GenPolyNotPrimitive'') ' ...
                        'to turn off this warning message.']);
                end
            end
        end
        
        %*****************************************************************
        function set.InitialStates(obj, initStates)
        %set InitialStates

            %Check data type (double row vector)           
            sigdatatypes.checkFiniteRealDblVec(obj, 'InitialStates', initStates) 

            % InitialStates must be a binary vector
            if isempty(initStates) || (~check_bool_vector(initStates))
                error('comm:commsrc:pn:InvalidInitialStatesValues', ...
                    'InitialStates values must be 0 or 1.');
            end
            
            % InitialStates vector length must be length(GenPoly)-1
            if (length(initStates) ~= (length(obj.GenPoly)-1))
                % Allow for scalar expansion of values
                if isequal(length(initStates), 1)
                    initStates = initStates .* ones(1, length(obj.GenPoly)-1);
                else
                    error('comm:commsrc:pn:InvalidInitialStatesLength', ...
                        'InitialStates vector length must equal the GenPoly order.');
                end
            end
            
            obj.InitialStates = initStates;            
            % Update CurrentStates (side-effect)
            obj.PrivCurrentStates = initStates;  
            
        end
        %*****************************************************************
        function  set.CurrentStates(obj, currStates)
        %set CurrentStates

            %Check data type (double row vector)           
            sigdatatypes.checkFiniteRealDblVec(obj, 'CurrentStates', currStates) 
            
            % CurrentStates must be a binary vector
            if isempty(currStates) || (~check_bool_vector(currStates))
                error('comm:commsrc:pn:InvalidCurrentStatesValues', ...
                    'CurrentStates values must be 0 or 1.');
            end
            
            % CurrentStates vector length must be length(GenPoly)-1
            if (length(currStates) ~= (length(obj.GenPoly)-1))
                % Allow for scalar expansion of values
                if isequal(length(currStates), 1)
                    currStates = currStates .* ones(1, length(obj.GenPoly)-1);
                else
                    error('comm:commsrc:pn:InvalidCurrentStatesLength', ...
                        'CurrentStates vector length must equal the GenPoly order.');
                end
            end

            obj.PrivCurrentStates = currStates; 
            
        end      
        %*****************************************************************
        function  currStates = get.CurrentStates(obj)
            %get current states 
            currStates = obj.PrivCurrentStates;
        end
        
        %*****************************************************************
        function set.NumBitsOut(obj,numbits)   
        %set NumBitsOut
        
            %Check data type (double row vector)           
            sigdatatypes.checkFinitePosIntScalar(obj, 'NumBitsOut', numbits) 
            
            obj.NumBitsOut = numbits;
        end
    %=====================================================================
    %Load and Save functions for COMMSRC.PN Objects
    %=====================================================================
        function CommsrcPnData = saveobj(obj)
        %SAVEOBJ overload save(obj) to be able to save dynamic properties
        %correctly.       
            CommsrcPnData.Version = '9a'; %identifier of object's version
            CommsrcPnData.GenPoly = obj.GenPoly;
            CommsrcPnData.InitialStates = obj.InitialStates;
            CommsrcPnData.CurrentStates = obj.PrivCurrentStates;
            CommsrcPnData.NumBitsOut = obj.NumBitsOut;  
            d = get(obj);          
            if isfield(d,'Shift')                                            
                CommsrcPnData.Shift = obj.Shift;
            else
               CommsrcPnData.Mask = obj.Mask;                 
            end
        end
     end  %public methods
    %*****************************************************************    
   methods (Static = true)
        function obj = loadobj(CommsrcPnData)
         %LOADOBJ overload load(obj) to retrieve data from structure 
         %returned by SAVEOBJ and create a COMMSRC.PN object accordingly.

         %Must be static since it will be called when no instance of the 
         %object exists.        
            if isfield(CommsrcPnData,'Shift')
                 obj = commsrc.pn('GenPoly',CommsrcPnData.GenPoly, ...
                    'InitialStates',CommsrcPnData.InitialStates, ...
                    'Shift',CommsrcPnData.Shift, ...
                    'NumBitsOut',CommsrcPnData.NumBitsOut);
            else
                 obj = commsrc.pn('GenPoly',CommsrcPnData.GenPoly, ...
                    'InitialStates',CommsrcPnData.InitialStates, ...
                    'Mask',CommsrcPnData.Mask, ...
                    'NumBitsOut',CommsrcPnData.NumBitsOut);               
            end
            obj.CurrentStates = CommsrcPnData.CurrentStates;
        end
   end %static methods
   %=====================================================================
   % Define Protected Methods
   %=====================================================================        
   methods (Access = protected)
   %=====================================================================
        function sortedList = getSortedPropDispList(obj)  
            % getSortedPropDispList
            %    Get the sorted list of the properties to be displayed.
            sortedList = {...
                'GenPoly', ...
                'InitialStates', ...
                'CurrentStates', ...
                'Mask', ...
                'NumBitsOut'};
                        
            if ~isempty(findprop(obj,'Shift'))
                sortedList{4} = 'Shift';
            end
        end
    end
 end %class definition

%=====================================================================
% Get/Set Methods for dynamic properties
%=====================================================================
%These set/get functions overload  
%get(obj,'Mask'), obj.Mask, 
%set(obj,'Mask', mask), set(obj,'Shift', shift), obj.Mask = mask,
%obj.Shift=shift
%These functions are not member functions and should not be confused
%with the getshift, and getmask member functions
%---------------------------------------------------------------------
function setMask(obj, mask)
%Set dynamic property Mask (this function cannot be specified as a method or
%assigning obj.Mask = mask will yield infinite recursions)

    %Check data type (double row vector)           
    sigdatatypes.checkFiniteRealDblVec(obj, 'Mask', mask) 

    %Mask vector length must be length(GenPoly)-1
    if (length(mask) ~= (length(obj.GenPoly)-1))
        error('comm:commsrc:pn:InvalidMaskLength', ...
            'Mask vector length must equal the GenPoly order.');
    end

    % Mask must be a binary vector
    if ~check_bool_vector(mask)
        error('comm:commsrc:pn:InvalidMaskValues', ...
            'Mask values must be 0 or 1.');
    end

    %Update PrivMask
    obj.PrivMask = mask;     
end      
%---------------------------------------------------------------------
function setShift(obj, shift)
%Set dynamic property Shift this function cannot be specified as a 
%method or assigning obj.Shift = shift will yield infinite recursions)

    % Shift must be scalar
    if (length(shift) ~= 1)
        error('comm:commsrc:pn:InvalidShiftLength', ...
            'Shift must be a scalar value.');
    end

    % Shift must be an integer
    if any(rem(shift, 1))
        error('comm:commsrc:pn:InvalidShiftValue', ...
            'Shift must be integer valued.');
    end

    obj.Shift = shift;
    
    % Update PrivMask
    obj.PrivMask = shift2mask(obj.GenPoly, shift);
    
end
%---------------------------------------------------------------------
function mask = getMask(obj)
%getmask function, get dynamic property Mask
    mask = obj.PrivMask;
end
%=====================================================================
% Private helper functions
%=====================================================================
function success = check_bool_vector(values)
%CHECK_BOOL_VECTOR  Return true if input is a vector of 0 and 1 values.
%                   Return false otherwise.
    success = check_nonneg_int(values) && (max(values) <= 1);
end

%---------------------------------------------------------------------
function success = check_nonneg_int(values)
%CHECK_NONNEG_INT  Return true if input is a vector of non-negative ints.
%                  Return false otherwise.

    success = ~any(rem(values, 1)) && (min(values) >= 0);
end

%--------------------------------------------------------------------------
function genPolyBits = genPolyIntsToBitVector(genPolyInts)
%GENPOLYINTSTOBITVECTOR 

if (length(genPolyInts) > 1)
    genPolyIntsCol = genPolyInts(:);
    
    % Check polynomial format specified as STRICTLY DECREASING int powers
    if ~isequal(sort(genPolyIntsCol,1,'descend'), genPolyIntsCol)
        throwInvalidGenPolyValuesError;
    end
    
    numPolyBits = genPolyIntsCol(1) + 1; % first int gives highest power
    genPolyBits = zeros(numPolyBits, 1); % initialize to all zeros
    genPolyBits(genPolyIntsCol+1) = 1;   % vector of indices
    genPolyBits = fliplr(genPolyBits');  % descending pow2 ROW vector
else
    % Polynomial specified as a scalar integer power-of-two value
    genPolyBits = de2bi(pow2(genPolyInts),'left-msb');
end
end

%--------------------------------------------------------------------------
function genPolyBits = removeLeadingZeros(genPolyBits)
%REMOVELEADINGZEROS
    genPolyBits = genPolyBits(2:end);
    if (length(genPolyBits) > 1)
        if ~(genPolyBits(1))
            % Leading bit is a zero - call this function recursively
            genPolyBits = removeLeadingZeros(genPolyBits);
        end
    end
end
%--------------------------------------------------------------------------
function throwInvalidGenPolyValuesError
error('comm:commsrc:pn:InvalidGenPolyValues', ...
      ['GenPoly values must be 0 or 1, or all non-negative ' ...
      'integers. Values specified as non-negative integer ' ...
      'powers of two must be in strictly decreasing order.']);
end


% [EOF]

