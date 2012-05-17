function [isValid, newSpec] = checkSldvSpecificationType(spec, classS, varargin)

%   Copyright 2007-2010 The MathWorks, Inc.

    % Validate the type of an Sldv specification
    % The specification is expected to be already syntactically
    % valid, that is, validated by checkSldvSpecification.
    %
    % This is called from several places in the following manner:
    %
    % checkSldvSpecification(spec, blockH)
    %   - early check on the sldv blocks.
    %
    % checkSldvSpecification(spec, class, dimensions, blockH)
    %   - deeper compatibility check and eventually vectorization on the blocks
    %
    % checkSldvSpecification(spec, class, dimensions, param, modelReferencingParam)
    %   - check on a parameter configuration. No vectorization. dimensions
    %     is the internal dimension. 

    isValid = true;
    allowResizing = true;
    param_value = [];
    
    if nargin < 3 
        dimensions = [];
    else
        dimensions = varargin{1};
    end
    
    if nargin < 4
        obj = classS;
    else
        obj = varargin{2};
        if ischar(obj)
            param_value = evalin('base', obj);
            if isscalar(param_value)
                allowResizing = false;
            end
            if isa(param_value, 'Simulink.Parameter')
                modelH = varargin{3};
                param_value = slResolve(obj,modelH);
            end
        end
    end
    
    % If the second argument is a block handle, we go back to the block and
    % get the class and dimensions from there.
    if isnumeric(classS) 
        ssBlk = [];
        while isempty(ssBlk)
            maskType = get_param(classS, 'MaskType');
            if (strcmpi(maskType, 'design verifier test objective') || ...
                       strcmpi(maskType, 'design verifier proof objective') || ...
                       strcmpi(maskType, 'design verifier test condition') || ...
                       strcmpi(maskType, 'design verifier assumption'))
                   ssBlk = classS;
            else
                classS = get_param(classS, 'Parent');
                if isempty(classS)
                    isValid = false;
                    return;
                end
            end
        end
        portInfo = get_param(ssBlk, 'CompiledPortDataTypes');
        classS = portInfo.Inport{1};
        portDimensions = get_param(ssBlk, 'CompiledPortDimensions');
        dimensions = portDimensions.Inport;
        dimensions = dimensions(2:end);
            
        obj = get_param(ssBlk, 'Handle');
    end
    
    % Explicitly give number of rows for 1 dimensions signals
    if length(dimensions) == 1
        dimensions = [ 1 dimensions ];
    end
    
    if ~iscell(spec)
        spec = { spec };
    end
    
    newSpec = spec;
    
    for i=1:length(spec)
        [isValidElem, newElem] = checkElem(spec{i}, classS, dimensions, obj, allowResizing, param_value);
        isValid = isValid && isValidElem;
        newSpec{i} = newElem;
    end
end
    
% An element is valid if:
% - it's empty
% - it's a point and it's value is valid
% - it's an interval and both bound are either valid
%   or infinite
% We assume that the spec is already syntactically valid
% (i.e. either [], Sldv.Point, or Sldv.Interval
function [isValid, newSpec] = checkElem(spec, classS, dimensions, obj, allowResizing, pvalue)
    isValid = true;
    newSpec = spec;
    
    if isa(spec,'Sldv.Point')
        [isValid, newValue] = checkValue(spec.value, classS, dimensions, obj, allowResizing, pvalue);
        newSpec = Sldv.Point(newValue);
    elseif isa(spec,'Sldv.Interval')
        [isValidLow, newLow] = checkValue(spec.low, classS, dimensions, obj, allowResizing, pvalue);
        [isValidHigh, newHigh] = checkValue(spec.high, classS, dimensions, obj, allowResizing, pvalue);
        isValid = isValidLow & isValidHigh;
        if spec.lowIncluded
            modL = '[';
        else
            modL = '(';
        end
        if spec.highIncluded
            modH = ']';
        else
            modH = ')';
        end
        newSpec = Sldv.Interval(newLow, newHigh, [ modL modH ]);
    end
end

% A scalar is valid if casting it to the required class doesn't 
% imply any loss of precision. The single case is special.
%
% This should check things for any dimension matrix. The isnan
% check lets infinities pass (Inf - Inf == NaN).
function [isValid, newValue] = checkValue(value, classS, dimensions, obj, allowResizing, pvalue)

    [isValid, value, errId] = fixValue(value, classS, pvalue);

    if isValid
        % We have a new specification, we need to check its dimensions
        %   . if the dimensions are the same as the expected ones, we're
        %     good
        %   . if they are different, and the spec is a scalar and we allow 
        %     resizing, we vectorize the spec
        %   . otherwise, error out. Two errors - either we don't allow
        %     resizing, or it's allowed but we couldn't reconcile the
        %     dimensions.
        
        valueSize = size(value);
        pvalueSize = size(pvalue);
        
        dim1 = simplify_dimensions(valueSize);
        dim2 = simplify_dimensions(dimensions);
        
        if ~isempty(dim1) && ~isempty(dim2) && ...
           (ndims(dim1) == ndims(dim2)) && ...
           (numel(dim1) == numel(dim2)) && ...
           all(dim1 == dim2)
            newValue = value;
        elseif ~isempty(pvalue) && ...
                length(valueSize)== length(pvalueSize) && all(valueSize==pvalueSize)
            newValue = reshape(value,dimensions);
        else
            if isscalar(value)
                % The specification is a scalar, and is applied to a matrix
                % if the specification comes from a parameter, we don't do 
                % vectorization. If it's coming from a block, we do.
                if allowResizing
                    newValue = repmat(value,dimensions);
                else
                    isValid = false;
                    errMsg = [ 'The parameter ' obj ' has a scalar value and is used with dimensions [' ...
                        num2str(dimensions) '].' ...
                        'Simulink Design Verifier requires the parameter workspace value and ' , ...
                        'its analysis configuration to have matching dimensions.' ];
                    errID = 'SLDV:Compatibility:ParameterSizeMismatch';
                    avtcgirunsupcollect('push', -1, 'sldv', errMsg, errID);
                end
            else
                newValue = value;
                isValid = false;
                errObj = obj;
                if ischar(obj);
                    errMsg = ['Dimensions mismatch. The parameter ' obj ' has dimensions [' num2str(dimensions) ...
                        '] its analysis configuration has dimensions [' num2str(size(value)) '].' ] ;
                    errObj = -1;
                else
                    errMsg = [ 'Dimensions mismatch. The input signal has dimensions [' num2str(dimensions) ...
                        '] the specification has dimensions [' num2str(size(value)) '].' ] ;
                end
                errID = 'SLDV:Compatibility:CustomBlockDimensionError';
                avtcgirunsupcollect('push', errObj, 'sldv', errMsg, errID);
            end
        end
    else
        newValue = value;
        errObj = obj;
        switch errId
            case 'SLDV:Compatibility:FixedPtMismatch'
                errMsg = [ 'The input signal and its specification have different fixed point types.' ...
                           'They should have the same fixed point type.' ];
            case 'SLDV:Compatibility:IncompatibleTypes'
                 if ischar(obj)
                    errMsg = [ 'Incompatible types. The parameter ' obj ' is of type ''' ...
                               classS ''' its analysis configuration is of type ''' class(value) '''.' ] ;
                    errObj = -1;
                else
                    errMsg = [ 'Incompatible types. The input signal is of type ''' ...
                               classS ''' the specification is of type ''' class(value) '''.' ] ;
                 end  
            case 'SLDV:Compatibility:IncompatibleParamTypes'
                errMsg = [ 'Incompatible types. The parameter ' obj ' is of type ''' ...
                            class(pvalue) ''' its analysis configuration is of type ''' class(value) '''.' ] ;
                errObj = -1;
            case 'SLDV:Compatibility:PrecisionLoss'
                if ischar(obj)
                    errMsg = [ 'Precision loss due to type conversions. The parameter ' obj ' is of type ''' ...
                               classS ''' its analysis configuration is of type ''' class(value) '''.' ] ;
                    errObj = -1;
                else
                    errMsg = [ 'Precision loss due to type conversions. The input signal is of type ''' ...
                               classS ''' the specification is of type ''' class(value) '''.' ] ;
                end
        end
        % We loose information on the error ID on purpose.
        errID = 'SLDV:Compatibility:CustomBlockTypeError';
        avtcgirunsupcollect('push', errObj, 'sldv', errMsg, errID);
    end
end

function [isValid, newValue, errId] = fixValue(value, classS, pvalue)
    isValid = false;
    newValue = value;
    errId = '';
       
    if ~isempty(pvalue)
        if ~strcmp(class(value), class(pvalue))
            isValid = false;
            errId = 'SLDV:Compatibility:IncompatibleParamTypes';
            return;
        end
    end
    
    if isa(value, 'embedded.fi')
        if strncmp(classS, 'sfix', 4) ||...
           strncmp(classS, 'ufix', 4) ||...
           strncmp(classS, 'flt', 3)
   
            fixdtType = fixdt(classS);
            isValid = checkFixedPointType(value, fixdtType);
            if ~isValid
                errId = 'SLDV:Compatibility:FixedPtMismatch';
            end
        elseif strcmp(classS, 'int16') || ...
               strcmp(classS, 'int32') || ...
               strcmp(classS, 'int8')
           newValue = feval(classS, value.int);
           isValid = true;
        else
           errId = 'SLDV:Compatibility:IncompatibleTypes'; 
        end
    else
        switch classS
            case 'single'
                diffValue = abs(single(value) - value);
                myEps = eps('single');
            otherwise
                try % we might have a non-numeric class on which this will fail
                    diffValue = abs(double(feval(classS, value)) - double(value));
                    myEps = eps;
                catch Mex  %#ok<NASGU>
                    % if we failed: nothing to do, the spec is not valid.
                    myEps = 0;
                    diffValue = 0;
                end
        end
        noLoss = diffValue < myEps | isnan(diffValue);
        isValid = all(noLoss(:));
        if ~isValid
            if diffValue == 0
                errId = 'SLDV:Compatibility:IncompatibleTypes';
            else
                errId = 'SLDV:Compatibility:PrecisionLoss';
            end
        else
            newValue = feval(classS, value);
        end
    end
end    

function out = checkFixedPointType(value, fixT)
    out = isequal(value.DataType, fixT.DataType) && ...
          isequal(value.Scaling, fixT.Scaling) && ...
          (value.Signed == fixT.Signed) && ...
          (value.WordLength == fixT.WordLength);
          
    if ~out
        return;
    end
    
    if fixT.isscalingbinarypoint
        out = out && (value.FractionLength == fixT.FractionLength);
    elseif fixT.isscalingslopebias
        out = out && ... 
              (value.Slope == fixT.Slope) && ...
              (value.Bias == fixT.Bias);
    else
        out = false;
    end
end

function dimensions = simplify_dimensions(dims)
    dimensions = dims(dims ~= 1);
    if isempty(dimensions)
        dimensions =  1 ;
    end
end

% LocalWords:  Sldv sldv
