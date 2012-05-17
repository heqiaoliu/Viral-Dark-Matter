classdef (Hidden, Sealed) MultiBandFilter < handle
    %MultiBandFilter Defines MultiBandFilter class for COMMMEASURE package
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.8.3 $  $Date: 2009/07/27 20:09:31 $
    
    %===========================================================================
    % Public properties
    %===========================================================================
    properties
        %DcCenteredFilter DC centered filter
        %   Handle of a dfilt.dffir object containing a DC centered FIR filter
        %   transfer function.
        DcCenteredFilter
        %ShiftedTransferFunction Shifted filter transfer functions
        %   Shifted filter transfer functions are calculated once (after
        %   construction or reset) and are kept in this property.
        ShiftedTransferFunction = [];
    end
    %===========================================================================
    % Public methods
    %===========================================================================
    methods
        function  computeShiftedTF(obj,offsets)
            %computeShiftedTF Compute shifted transfer functions.
            %   This function saves a vector of dfilt.dffir objects. The i-th
            %   dfilt object corresponds to a filter shifted to the i-th
            %   specified offset.
            %   Frequency offsets must be given in normalized units in the [-1
            %   1] interval.
            
            for idx = 1:length(offsets)
                if idx == 1
                    obj.ShiftedTransferFunction = shiftFilter(obj,...
                        obj.DcCenteredFilter,0,offsets(idx));
                else
                    obj.ShiftedTransferFunction(idx) = shiftFilter(obj,...
                        obj.DcCenteredFilter,0,offsets(idx));
                end
            end
        end
        %=======================================================================
        function filteredData = filterData(obj,x)
            %filterData Filter data with shifted transfer functions.
            %   Output 'filteredData' is a matrix with the i-th column
            %   corresponding to the data filtered with the i-th filter in
            %   'ShiftedTransferFunction'.
            
            for idx = 1:length(obj.ShiftedTransferFunction)
                filteredData(:,idx) = ...
                    filter(obj.ShiftedTransferFunction(idx),x); %#ok<AGROW>
            end
        end
        %=======================================================================
        function resetShiftedTF(obj)
            %resetShiftedTF Reset all shifted transfer functions.
            for idx = 1:length(obj.ShiftedTransferFunction)
                reset(obj.ShiftedTransferFunction(idx));
            end
        end
        %=======================================================================
        function h = copy(obj)
            %COPY   Copy the object
            hTemp = commmeasure.MultiBandFilter;
            hTemp.DcCenteredFilter = copy(obj.DcCenteredFilter);
            for idx = 1:length(obj.ShiftedTransferFunction)
                if idx == 1
                    hTemp.ShiftedTransferFunction = ...
                        copy(obj.ShiftedTransferFunction(idx));
                else
                    hTemp.ShiftedTransferFunction(idx) = ...
                        copy(obj.ShiftedTransferFunction(idx));
                end
            end
            h = hTemp;
        end
    end% public methods
    %===========================================================================
    % Private methods
    %===========================================================================
    methods(Access = private)
        function ht = shiftFilter(obj,ho,wo,wt)
            %shiftFilter Shift transfer function of a FIR dfilt filter
            %   Inputs:
            %   ho - reference dfilt object containing the transfer
            %        function that we want to shift.
            %   wo - center frequency of reference filter
            %   wt - new target center frequency where we want to shift
            %        the reference transfer function
            %   Output:
            %   ht - target shifted dfilt object
            
            %Get the FIR transfer function
            [b, a] = tf(ho);
            
            allPassNum = [0 1] * exp(pi*1i*(wt-wo));
            allPassDen = [1 0];
            
            % Remove possible trailing zeros and get polynomial lengths
            b = b(1:max(find(b~=0))); M = length(b); %#ok<*MXFND>
            a = a(1:max(find(a~=0))); N = length(a);
            
            % Compute temporary numerator
            tempNum = newPoly(obj,b,allPassNum,allPassDen,M);
            
            % Compute temporary denominator
            tempDen = newPoly(obj,a,allPassNum,allPassDen,N);
            
            % Now include common denominators
            num = conv(tempNum,polyPower(obj,allPassDen,N-M));
            den = conv(tempDen,polyPower(obj,allPassDen,M-N));
            
            num = num/den(1);
            
            ht  = dfilt.dffir(num);
            
            if obj.DcCenteredFilter.Persistentmemory
                ht.PersistentMemory = true;
                ht.States = obj.DcCenteredFilter.States;
            end
        end
        %=======================================================================
        function tempPoly = newPoly(obj,b,allPassNum,allPassDen,M)
            %newPoly Compute new polynomial after substitution
            
            % For each coefficient, we will have a resulting polynomial after
            % we substitute, form each polynomial and then add them all up to
            % compute the new numerator or denominator.
            for n = 1:M,
                tempPoly(n,:) = b(n).*conv(polyPower(obj,allPassDen,M-n),...
                    polyPower(obj,allPassNum,n-1)); %#ok<AGROW>
            end
            tempPoly = sum(tempPoly);
        end
        %=======================================================================
        function p = polyPower(obj,q,N) %#ok<*MANU>
            %polyPower Evaluate polynomial to power of N.
            
            % Initialize recursion
            p = 1;
            
            % Return early if order is zero or negative
            if N <= 0,
                return
            end
            
            % Multiply polynomial by q, N times
            for n = 1:N,
                p = conv(p,q);
            end
        end
    end
end%end classdef




