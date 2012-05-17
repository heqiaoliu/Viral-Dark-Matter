function this = fi(varargin)
%FI  FIxed-point object constructor
%   FI(DATA) returns a signed fixed-point object with real-world-value
%   DATA, default 16-bit wordlength, and best-precision fractionlength.
%
%   Refer to FI for a detailed help
%
%   See also FI

% Undocumented
%    fi(data, q)

%   FI(V) returns a signed fixed-point object with value V, default 16-bit
%   wordlength, and best-precision fractionlength.
%
%   FI(V, W) returns a signed fixed-point object with value V, wordlength W,
%   and best-precision fractionlength.
%
%   FI(V, W, F) returns a signed fixed-point object with value V,
%   wordlength W, and fractionlength F.
%
%   FI(V, ..., 'Signed', false) returns an unsigned fixed-point object.
%   FI(V, ..., 'Signed', true ) returns a signed fixed-point object.
%
%   FI(V, Q) returns a fixed-point object with value V, that has been
%   quantized with QUANTIZER object Q, and with the fixed-point
%   properties of Q.
%
%   FI(..., 'PropertyName', PropertyValue, ...) sets fixed-point
%   attributes by named property/value pairs.  To get a structure with all
%   possible property/value pairs and their attributes, do
%     a = fi(0);
%     s = set(a)

%   When auto-scaling will be used.
%     Legend:
%       A=fi, X=double or single, N=int
%       T=numerictype, scaling specified
%       U=numerictype, scaling unspecified
%       F=fimath
%       PV parameter/value pairs, one of which specifies scaling
%       PU parameter/value paris, none of which specifies scaling
%
%   Auto-scale              Don't auto-scale
%     fi(X)                   fi(A/N)
%     fi(X, s)                fi(A/N, s)
%     fi(A/X, s, w)           fi(N, s, w)
%     fi(A/X, U)              fi(N, U)
%     fi(A/X, U, F)           fi(N, U, F)
%     fi(X, PU)               fi(A/N, PU)
%     fi(X, s, PU)            fi(A/N, s, PU)
%     fi(A/X, s, w, PU)       fi(N, s, w, PU)
%     fi(A/X, U, PU)          fi(N, U, PU)
%     fi(A/X, U, F, PU)       fi(N, U, F, PU)
%
%   Don't auto-scale
%     fi(A/X/N, s, w, f)
%     fi(A/X/N, s, w, slope, bias)
%     fi(A/X/N, s, w, slopeadjustmentfactor, fixedexponent, bias)
%     fi(A/X/N, T)
%     fi(A/X/N, T, F)
%     fi(..., PV )
%
%   The signature fi(N,...) sets datatypemode=[u]int[8,16,32] and the
%   related settings will be made automatically.

%   Thomas A. Bryan
%   Copyright 2003-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.36 $  $Date: 2010/04/05 22:16:14 $

if nargin==0
  this = embedded.fi; % Returns a fimath-less empty fi
  % Check for a Fixed-Point License when DataTye != 'Double'
  fiLicenseCheckout(this);
  return    
end

% We need to figure out if the wordlength has been set but none of the
% scaling parameters has been set to see if we need to autoscale a copy
% constructor.
wordlengthset = false;
scalingset = false;

% Error out if the first input to fi constructor is of type struct
if isstruct(varargin{1})
  error('fi:constructor:invalidInput','First input to fi constructor cannot be of type struct.');  
end

%Check all inputs to verify that they belong to one of the types
%supported by the FI constructor; Error out if any one of them does not;
for k=1:nargin
    vKthInput = varargin{k};    
    classKthInput = class(vKthInput);
    if ~isnumeric(vKthInput) && ~islogical(vKthInput) && ~ischar(vKthInput) ...
          && ~isfimath(vKthInput) && ~isnumerictype(vKthInput) && ...
          ~isquantizer(vKthInput) && ~strcmpi(classKthInput,'Simulink.NumericType')
        errMsg = 'Inputs to fi constructor cannot be of class %s';
        error('fi:constructor:invalidInput', sprintf(errMsg,classKthInput));
    end
end

% Flag to keep track of whether the fi object has an attached fimath
fimathislocal = false;

% Find the number of leading numeric values.
nnumeric = 0;
for k=1:nargin
  if ~isnumeric(varargin{k}) && ~islogical(varargin{k})
    break
  end
  nnumeric = nnumeric + 1;
end

% Find the position of the first char argument, which indicates the
% start of the parameter/value pairs.  Note that there may be a hole
% between the leading numeric and first parameter/value pair.
nfirstchararg = realmax;
for k=1:nargin
  if ischar(varargin{k})
    nfirstchararg = k;
    break
  end
end
fimathSpecifiedByString = 0;


% We will autoscale unless we detect that scaling has been set.
autoscale = true;

%  If data is a FI object, then this is a copy constructor.
isCopyConstructor = nargin>0 && isfi(varargin{1});
isVar1FloatBoolFi = false;

if isCopyConstructor
  % fi(fi, ...)
  this = varargin{1};
  this.fimathislocal = isfimathlocal(varargin{1});
  isVar1FloatBoolFi = isfloat(this) || isboolean(this);
else 
  this = embedded.fi; % Returns a fimath-less empty fi  
  resetlogging(this);
end


% If 1st and only input is single or boolean create a 'single'
% or a 'boolean' fi.
% If copy constructor and other numerictype arguments (not pv pairs)
%  are given, continue as if it is not a copy constructor.
if ~isCopyConstructor && nargin==1 && nnumeric==1
    switch class(varargin{1})
      case 'single'
      this.DataTypeMode = 'Single';
      this.DataType = 'Single';
      autoscale = false;
    case 'logical'
      this.DataTypeMode = 'Boolean';
      this.DataType = 'Boolean';
      autoscale = false;
    end
elseif isCopyConstructor && isVar1FloatBoolFi && nargin>1 && nnumeric>1
    this = embedded.fi;
    if ~feature('FimathLessFis') || isfimathlocal(varargin{1})
        this.fimath = fimath(varargin{1});
    end
    varargin{1} = double(varargin{1});
    resetlogging(this);
    isCopyConstructor = false;
end

        

if ~isCopyConstructor && nnumeric>0
  switch class(varargin{1})
    % fi(I,...), where I is an integer type
    case 'int8'
      this.DataType = 'Fixed';
      this.Scaling = 'BinaryPoint';
      this.SignednessBool = true;
      this.WordLength = 8;
      this.FractionLength = 0;
      autoscale = false;
      wordlengthset = true;
    case 'int16'
      this.DataType = 'Fixed';
      this.Scaling = 'BinaryPoint';
      this.SignednessBool = true;
      this.WordLength = 16;
      this.FractionLength = 0;
      autoscale = false;
      wordlengthset = true;
    case 'int32'
      this.DataType = 'Fixed';
      this.Scaling = 'BinaryPoint';
      this.SignednessBool = true;
      this.WordLength = 32;
      this.FractionLength = 0;
      autoscale = false;
      wordlengthset = true;
    case 'uint8'
      this.DataType = 'Fixed';
      this.Scaling = 'BinaryPoint';
      this.SignednessBool = false;
      this.WordLength = 8;
      this.FractionLength = 0;
      autoscale = false;
      wordlengthset = true;
    case 'uint16'
      this.DataType = 'Fixed';
      this.Scaling = 'BinaryPoint';
      this.SignednessBool = false;
      this.WordLength = 16;
      this.FractionLength = 0;
      autoscale = false;
      wordlengthset = true;
    case 'uint32'
      this.DataType = 'Fixed';
      this.Scaling = 'BinaryPoint';
      this.SignednessBool = false;
      this.WordLength = 32;
      this.FractionLength = 0;
      autoscale = false;
      wordlengthset = true;
    case 'int64'
      this.DataType = 'Fixed';
      this.Scaling = 'BinaryPoint';
      this.SignednessBool = true;
      this.WordLength = 64;
      this.FractionLength = 0;
      autoscale = false;
      wordlengthset = true;
    case 'uint64'
      this.DataType = 'Fixed';
      this.Scaling = 'BinaryPoint';
      this.SignednessBool = false;
      this.WordLength = 64;
      this.FractionLength = 0;
      autoscale = false;
      wordlengthset = true;
  end
end

% 0   fi(property1,value1,...)
% 1   fi(data)
%     fi(data, T)
%     fi(data, T, F)
% 2   fi(data, s)
% 3   fi(data, s, w)
% 4   fi(data, s, w, f)
% 5   fi(data, s, w, slope, bias)
% 6   fi(data, s, w, slopeadjustmentfactor, fixedexponent, bias)
%
switch nnumeric
  case 0
    % Nothing to be done.  No initial numeric arguments.
  case 1
    % 1   fi(data)
    %     fi(data,signed)
    %     fi(data, q)
    %     fi(data, T)
    %     fi(data, T, F)
    if nargin>1
      if isquantizer(varargin{2})
        this = setFiFromQuantizer(this,varargin{2});
        autoscale = false;
        % Quantizer has round/overflow modes so fimathislocal = true
        fimathislocal = true;
      elseif isnumerictype(varargin{2})
        T = varargin{2};
        warnstate = warning('off','FixedPointToolbox:numerictype:InvalidSetting');
        this.numerictype = T;
        warning(warnstate);
        wordlengthset = true;
        if ~strcmpi(T.Scaling,'Unspecified')
          autoscale = false;
          scalingset = true;
        end
        if nargin>2 && isfimath(varargin{3})
          this.fimath = varargin{3};
          fimathislocal = true;
        end
      elseif isa(varargin{2},'Simulink.NumericType')
        T = numerictype;
        S = varargin{2};
        T.DataTypeMode   = S.DataTypeMode;
        T.SignednessBool = S.SignednessBool;
        T.WordLength     = S.WordLength;
        T.Slope          = S.Slope;
        T.Bias           = S.Bias;
        warnstate = warning('off','FixedPointToolbox:numerictype:InvalidSetting');
        this.numerictype = T;
        warning(warnstate);
        wordlengthset = true;
        if ~strcmpi(T.Scaling,'Unspecified')
          autoscale = false;
          scalingset = true;
        end
        if nargin>2 && isfimath(varargin{3})
          this.fimath = varargin{3};
        end
      elseif isfimath(varargin{2})
          this.fimath = varargin{2};
          fimathislocal = true;
          if nargin>2 && isnumerictype(varargin{3})
              T = varargin{3};
              warnstate = warning('off','FixedPointToolbox:numerictype:InvalidSetting');
              this.numerictype = T;
              warning(warnstate);
              wordlengthset = true;
              if ~strcmpi(T.Scaling,'Unspecified')
                  autoscale = false;
                  scalingset = true;
              end
          end
      end
    end
  case 2
    % 2   fi(data, s)
    this.Scaling         = 'BinaryPoint';
    this.SignednessBool          = varargin{2};
    autoscale = true && autoscale;
  case 3
    % 3   fi(data, s, w)
    this.Scaling         = 'BinaryPoint';
    this.SignednessBool          = varargin{2};
    this.WordLength      = varargin{3};
    wordlengthset        = true;
    autoscale            = true;
  case 4
    % 4   fi(data, s, w, f)
    this.Scaling         = 'BinaryPoint';
    this.SignednessBool          = varargin{2};
    this.WordLength      = varargin{3};
    this.FractionLength  = varargin{4};
    autoscale = false;
  case 5
    % 5   fi(data, s, w, slope, bias)
    this.Scaling         = 'SlopeBias';
    this.SignednessBool          = varargin{2};
    this.WordLength      = varargin{3};
    this.Slope           = varargin{4};
    this.Bias            = varargin{5};
    autoscale = false;
  case 6
    % 6   fi(data, s, w, slopeadjustmentfactor, fixedexponent, bias)
    this.Scaling         = 'SlopeBias';
    this.SignednessBool          = varargin{2};
    this.WordLength      = varargin{3};
    this.SlopeAdjustmentFactor = varargin{4};
    this.FixedExponent   = varargin{5};
    this.Bias            = varargin{6};
    autoscale = false;
  otherwise  
    error('fi:constructor:invalidInputs','Too many initial numeric arguments.');
end

% Set the fimath when it is provided with other numeric inputs
[this,fimathislocal] = setFimathAfterNumericInputs(this,nargin,nnumeric, ...
                                                        varargin{:});


% Process parameter/value pairs

% NumericType property names
ntProps = lower({'DataType',...
                 'DataTypeMode',...
                 'Scaling',...
                 'Signed',...
                 'Signedness',...
                 'SignednessBool',...
                 'WordLength',...
                 'FractionLength',...
                 'BinaryPoint',...
                 'FixedExponent',...
                 'Slope',...
                 'SlopeAdjustmentFactor',...
                 'Bias'
                });


setloopargs = varargin(nfirstchararg:end);
nsetloopargs = length(setloopargs) - fimathSpecifiedByString;
if fix(nsetloopargs/2)~=nsetloopargs/2
  error('fi:constructor:invalidPVPairs','Invalid parameter/value pair arguments.');
end

% If copyconstructor and fi input is float/bool and if any of the pv pairs
% change the type, reset "this" to a fixed embedded.fi
if isCopyConstructor && isVar1FloatBoolFi && nnumeric==1
    for k = 1:2:nsetloopargs
        ntmatch = min(strmatch(lower(setloopargs{k}),ntProps));
        if ntmatch
            % If datatype mode is being changed check to see
            % the new mode
            if isequal(ntmatch,1) || isequal(ntmatch,2)
                
                strDouble = strDataTypeMatch(setloopargs{k+1},'double');
                strSingle = strDataTypeMatch(setloopargs{k+1},'single');
                strBoolean = strDataTypeMatch(setloopargs{k+1},'boolean');
                
                if ~strDouble && ~strSingle && ~strBoolean 
                    varargin{1} = double(varargin{1});
                    this = embedded.fi;
                    resetlogging(this);
                    isCopyConstructor = false;
                    break;
                end
            else
                varargin{1} = double(varargin{1});
                this = embedded.fi;
                resetlogging(this);
                isCopyConstructor = false;
                break;
            end
        end
    end
end



warnstate = warning('off','FixedPointToolbox:numerictype:InvalidSetting');
for k=1:2:nsetloopargs
    this.(setloopargs{k}) = setloopargs{k+1};
    % LastPropertySet values are enumerated in fi.cpp
    switch LastPropertySet(this);
      case 0
        % numerictype
        T = setloopargs{k+1};
        wordlengthset = true;
        if ~strcmpi(T.Scaling,'Unspecified')
            autoscale = false;
        end
      case 4
        % signedness
        if ~wordlengthset
            this.WordLength = 16;
            wordlengthset = true;
            autoscale = true;
        end
      case 5
        % wordlength
        wordlengthset = true;
        if ~scalingset
            autoscale = true;
        end
      case {6,7,8,9}
        % fractionlength, binarypoint, fixedexponent, slope
        % One of the scaling properties has been set by a parameter/value pair.
        autoscale  = false;
        scalingset = true;
      case {25,26,27,28,29,30,31,32,33}
        % double, data, int, intarray,simulinkarray,bin,oct,dec,hex
        % One of the data properties has been set by a parameter/value pair.
        this.datasetbypvpair = true;
    end
end
warning(warnstate);

% PV pairs could have set a fimath or a fimath attribute.
% Determine if fimath is now local or not.
fimathislocal = isfimathlocal(this);

% If a copy constructor is still considering fixed-point auto-scaling
% and we have not set the wordlength, then don't auto-scale.
if isscaledtype(this) && isCopyConstructor && autoscale &&  ~wordlengthset  
  autoscale = false;
end

% Set data type based on fipref's DataTypeOverride and these other rules:
% If this.datatype == boolean skip DTO
% If this.numerictype chooses to ignore DTO, skip DTO
% If fipref.DataTypeOverride = forceoff, skip DTO
% Else check the fipref.DataTypeOverrideAppliesTo property to set the correct datatype based on the
% fipref's DataTypeOverride setting
p = fipref;
doDataTypeOverride = ~isequal(this.datatype,'boolean') && ...
    ~isequal(p.DataTypeOverride,'ForceOff') && ...
    ~isequal(this.numerictype.DataTypeOverride,'Off'); 
if doDataTypeOverride
    switch p.DataTypeOverride
      case {'TrueDoubles','TrueSingles'}
        if (isequal(p.DataTypeOverrideAppliesTo,'AllNumericTypes')) || ...
                (isequal(p.DataTypeOverrideAppliesTo,'Fixed-point') && isfixed(this)) || ...
                (isequal(p.DataTypeOverrideAppliesTo,'Floating-point') && isfloat(this))
            dtoStr = p.DataTypeOverride;
            this.datatype = lower(dtoStr(5:end-1)); % strip away the 'True' and the 's' to get either 'double' or 'single'
        end
      case 'ScaledDoubles'
        if isequal(p.DataTypeOverrideAppliesTo,'AllNumericTypes')
            if strcmpi(this.datatype, 'fixed')
                this.datatype = 'ScaledDouble';
            elseif strcmpi(this.datatype,'single')
                this.datatype = 'double';
            end
        elseif isequal(p.DataTypeOverrideAppliesTo,'Floating-point') && isfloat(this)
            this.datatype = 'double';
        elseif isequal(p.DataTypeOverrideAppliesTo,'Fixed-point') && strcmpi(this.datatype,'fixed')
            this.datatype = 'ScaledDouble';
        end
    end
end
% Reset the numerictype DTO to inherit because we do not want to 
% propagate this setting after it has been obeyed by the fi constructor 
this.DataTypeOverride = 'Inherit';

% Set the best fractionlength for fixed-point or scaled double if
% scaling has not been set.
if autoscale && isscaledtype(this) && nnumeric>0
    this = setbestfractionlength(this,varargin{1});
    this.isautoscaled = true;
else
    this.isautoscaled = false;
end

% If copyconstructor & the numerictype has changed reset the logs
if isCopyConstructor && ~isequal(numerictype(this),numerictype(varargin{1}))
    resetlogging(this);
end

% Set the data after the numeric properties have been set.
if isCopyConstructor && ~datasetbypvpair(this) && nargin>1
  % if this is a fimathless fi then set the fimath to an empty
  if ~fimathislocal
      this.fimath = [];
  end
  % Copy constructor and the p/v pairs didn't set any "data" properties,
  % but at least one other property has been set (not B=fi(A)).  It is
  % important that at least one other property has been set, otherwise
  % "this" and "varargin{1}" are still references to each other.
  % Setting a property of "this" forces a deep copy.
  % Copying data directly like this ensures that it comes over in full precision.
  this.copydata(varargin{1});
elseif nnumeric>0 && ~isCopyConstructor && ~datasetbypvpair(this)
  if fimathislocal
      this.data = varargin{1};
  else % Set data using this special constructor that always does nearest-saturate.
      autoscale = isautoscaled(this);
      mTag = this.tag;
      this = embedded.fi(varargin{1},this.numerictype,false);
      this.isautoscaled = autoscale;
      if ~isempty(mTag)
          this.tag = mTag;
      end
  end
end

% Check for a Fixed-Point License when DataTye != 'Double'
fiLicenseCheckout(this);

return  % fi()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function this = setFiFromQuantizer(this,q)
switch lower(q.mode)
  case {'fixed','ufixed'}
    this.DataType       = 'fixed';
    this.signed         = strcmpi(q.mode,'fixed');
    this.Wordlength     = q.Wordlength;
    this.Fractionlength = q.Fractionlength;
    this.Scaling        = 'BinaryPoint';
  case {'double','single'}
    this.DataType       = q.mode;
  case 'float'
    error('fi:constructor:invalidDataTypeMode',...
          ['fi: Arbitrary precision float not supported on FI ' ...
           'objects.'])
end
this.OverflowMode = q.OverflowMode;
this.RoundMode    = q.RoundMode;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function this = setbestfractionlength(this,data)
% If data was entered and no fractionlength, pick a fractionlength for
% "best precision".
%
% The fractionlength (equivalently -fixedexponent) is the binary scaling
% of the stored integer with the bias and slope-adjustment-factor
% removed.
if any(isnan(data(:)))
  error('fixedpoint:nofixednan',...
        'NaN cannot be converted to fixed-point.');
end
if any(isinf(data(:)))
  error('fixedpoint:nofixedinf',...
        'Inf cannot be converted to fixed-point.')
end

T = numerictype(this);
if isscaledtype(T)
    if strcmpi(T.Scaling,'Unspecified')
        T.Scaling = 'BinaryPoint';
    end
    if isempty(data)
        if isempty(T.SignednessBool), T.SignednessBool=1; end
        T.FractionLength = T.WordLength - T.SignednessBool;
        this.numerictype = T;
    else
        % Not empty
        vals = double(data);
        if isreal(vals)
            vals = vals(:);
        else
            vals = [real(vals(:)); imag(vals(:))];
        end

        if isslopebiasscaled(T)
            vals = (vals - T.bias)/(T.slopeadjustmentfactor);
        end

        % Find the value greatest element A (real or imaginary) with the
        % greatest absolute value.  This number may be negative.
        A = max(vals(abs(vals)==max(abs(vals))));
        T.SetBestFractionLength(A);

        if A < 0
            % Might be different for e.g. [-1 1-eps] because -1 is the
            % max(abs(vals)), but you need an extra integer bit for the positive
            % one. 
            B = max(vals);
            if B>0
                T2 = copy(T);
                T2.SetBestFractionLength(B);
                if T.FractionLength > T2.FractionLength
                    % Prefer the one with more integer bits (i.e. bigger range)
                    T = T2;
                end
            end
        end
        this.numerictype = T;
    end
    resetlogging(this);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strval = strDataTypeMatch(strvalin,strData)
% Return true if strvalin matches strData

strvalin = lower(strvalin);
strval = strmatch(strvalin,strData);
strval = ~isempty(strval) && strval;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fiLicenseCheckout(this)
% Check for a Fixed-Point License when DataTye ~= 'Double'

if ~strcmpi(this.DataType,'double') 
    flag = builtin('license','checkout','fixed_point_toolbox');
    if ~flag
        error('fixedpoint:lmcheckout:failed',...
              'Unable to check out a license for the Fixed-Point Toolbox.')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [this fimathislocal] = setFimathAfterNumericInputs(this,ninputs,nnumeric,varargin)
% Set the fimath when it is provided with other numeric inputs

fimathislocal = false;
if ninputs>nnumeric && isfimath(varargin{nnumeric+1})
  this.fimath = varargin{nnumeric+1};
  fimathislocal = true;
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
