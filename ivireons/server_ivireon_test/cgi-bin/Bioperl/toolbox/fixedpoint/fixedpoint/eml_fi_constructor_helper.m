function [T,F,ERR,val,fiIsautoscaled,pvpairsetdata,fimathislocal] = eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,datasz,varargin)
% EML_FI_CONSTRUCTOR_HELPER1 Helper function for eML to construct a
% fi object.

%   Copyright 2003-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.21 $  $Date: 2010/04/05 22:16:09 $

ERR = ''; %#ok
val = []; T = []; F = [];
fiIsautoscaled = false;
pvpairsetdata = false;
fimathislocal = true;

% To workaround G367399, float fi is passed from eML to ML in three parts -
% value, numerictype & fimath. Create temporary fi object from these info
% here (in ML) and pass it, along with other input arguments, to fi
% constructor.
if (length(varargin)>3 && isnumerictype(varargin{2}) && isfimath(varargin{3}))
    % create temporary fi
    hTemp = embedded.fi(varargin{1},varargin{2},varargin{3});
    varargin = {hTemp,varargin{4:end}};
end

try
    % Set the fipref
    [mlDTOStr,mlDTOAppliesToStr,ERR] = eml_fipref_helper(slDTOStr,slDTOAppliesToStr);  %#ok
    % Set the default fimath
    if useInputFimathForFiConstructors || fifeature('FimathLessFis') 
        defaultFimathForFiConstructors = emlInputFimath;
    else
        defaultFimathForFiConstructors =  fimath('RoundMode','nearest',...
                                                 'OverflowMode','saturate',...
                                                 'ProductMode','FullPrecision',...
                                                 'ProductWordLength',32,...
                                                 'MaxProductWordLength',128,...
                                                 'ProductFractionLength',30,...
                                                 'ProductSlopeAdjustmentFactor',1,...
                                                 'ProductBias',0,...
                                                 'SumMode','FullPrecision',...
                                                 'SumWordLength',32,...
                                                 'MaxSumWordLength',128,...
                                                 'SumFractionLength',30,...
                                                 'SumSlopeAdjustmentFactor',1,...
                                                 'SumBias',0);
    end
    origDefaultFimath = fimath;
    globalfimath(defaultFimathForFiConstructors);
    
    h = embedded.fi(varargin{:});
    T = numerictype(h);
    F = fimath(h);

    % Reset fipref to original DTO
    [~, ~, ERR] = eml_fipref_helper(mlDTOStr,mlDTOAppliesToStr);
    % Reset the default fimath to its original value
    globalfimath(origDefaultFimath);
    
    % If the value of h has been set by setting the 'Data' property using
    % varargin{1} then val = vararagin{1}, otherwise h's value has been set
    % by a PV pair so gets the correct value.
    pvpairsetdata = datasetbypvpair(h);
    if pvpairsetdata && isnumeric(varargin{1}) && ~isequal(size(h),datasz)
        % Error out as per g499075
          ERR = ['If the first input to the fi constructor is numeric and you use property value '...
              'pairs to specify the stored-data property of the fi object, the size '...
              'of the corresponding stored-data property value must match '...
              'the size of the first input to the fi constructor.'];
        return;
    end
    if isequal(LastPropertySet(h),26) && ~pvpairsetdata
        val = varargin{1};
    else
        % If the data was set using a PV pair then simply return the fi.
        % This will maintain precision if WL > 53 bits (instead of casting
        % it to a double)
        val = h;
    end
    fiIsautoscaled = isautoscaled(h);
    fimathislocal = isfimathlocal(h);
    % If fimath is not local and the fi-data was set by a double value set the round and overflow modes of F
    % to nearest & saturate regardless of what it might be. This will ensure that EML uses these modes to create the
    % fimathless fi from a double-precision real-world value.
    if ~fimathislocal && isequal(LastPropertySet(h),26)
        F.RoundMode = 'nearest';
        F.OverflowMode = 'saturate';
    end
    
    % Check the Numerictype's "DataType" property and error out if it is
    % 'boolean'  or 'ScaledDouble'
    if strcmpi(T.DataType,'boolean') || strcmpi(T.DataType,'ScaledDouble')
        ERR = ['fi DataTypeMode = ''' T.DataType ''' is not supported in Embedded MATLAB'];
        return;
    end
    % Check the Numerictype's WordLength and error if > EMLFiMaxBits
    if strcmpi(T.DataType,'Fixed') && (T.WordLength >  double(maxWL))      
        ERR = sprintf('Invalid WordLength specified; the WordLength must be less than %d bits.',double(maxWL)+1);
    end
catch ME
    % Reset fipref to original DTO
    eml_fipref_helper(mlDTOStr,mlDTOAppliesToStr);
    % Reset the default fimath to its original value
    globalfimath(origDefaultFimath);
    ERR = ME.message;
end

nout = nargout;
if nout<=1
    T = {T,F,ERR,val,fiIsautoscaled};
end

