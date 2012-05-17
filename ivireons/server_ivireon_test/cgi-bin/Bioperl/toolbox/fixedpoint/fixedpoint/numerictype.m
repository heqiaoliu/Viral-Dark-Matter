function this = numerictype(varargin)
%NUMERICTYPE Object which encapsulates numeric type information
%   Syntax:
%     T = numerictype
%     T = numerictype(s)
%     T = numerictype(s, w)
%     T = numerictype(s, w, f)
%     T = numerictype(s, w, slope, bias)
%     T = numerictype(s, w, slopeadjustmentfactor, fixedexponent, bias)
%     T = numerictype('boolean')
%     T = numerictype('double')
%     T = numerictype('single')
%     T = numerictype(property1, value1, ...)
%     T = numerictype(T1, property1, value1, ...)
%
%   Description:
%     T = numerictype creates a numerictype object.
%
%     T = numerictype(s) creates a numerictype object with Fixed-point:
%     unspecified scaling, Signed property value s, and 16-bit word length. s can be 0 
%     or false for unsigned or 1 or true for signed.
%
%     T = numerictype(s,w) creates a numerictype object with Fixed-point:
%     unspecified scaling, Signed property value s, and word length w.
%
%     T = numerictype(s,w,f) creates a numerictype object with Fixed-point:
%     binary point scaling, Signed property value s, word length w and fraction length f.
%
%     T = numerictype(s,w,slope,bias) creates a numerictype object with
%     Fixed-point: slope and bias scaling, Signed property value s, word length w, slope
%     and bias.
%
%     T = numerictype(s,w,slopeadjustmentfactor,fixedexponent,bias) creates
%     a numerictype object with Fixed-point: slope and bias scaling,
%     Signed property value s, word length w, slopeadjustmentfactor, fixedexponent and
%     bias.
%
%     T = numerictype('boolean') creates a boolean numerictype object.
%     T = numerictype('double')  creates a double  numerictype object.
%     T = numerictype('single')  creates a single  numerictype object.
%
%     T = numerictype(property1,value1, ...) creates a numerictype object
%     with specified property/values.
%
%     The numerictype object properties and values can be set by using the
%     dot notation will the following syntax:
%       T = numerictype;
%       T.PropertyName = Value
%       Value = T.PropertyName
%     For example,
%       T = numerictype
%       T.WordLength = 80
%       w = T.WordLength
%
%     T = numerictype(T1, property1,value1, ...) copies numerictype
%     object T1 to T, and sets T's property/value pairs.
%
%   The valid properties and values are as follows (defaults are set apart
%   by <>)
%
%              DataTypeMode: {<'Fixed-point: binary point scaling'>,
%                             'Fixed-point: slope and bias scaling',
%                             'Fixed-point: unspecified scaling',
%                             'Scaled double: binary point scaling',
%                             'Scaled double: slope and bias scaling',
%                             'Scaled double: unspecified scaling',
%                             'boolean',
%                             'double',
%                             'single'}
%                  DataType: {<'Fixed'>,
%                             'boolean',
%                             'double',
%                             'single'}
%                   Scaling: {<'BinaryPoint'>,
%                             'SlopeBias',
%                             'Unspecified'}
%                    Signed: {<true>, false}
%                Signedness: {<signed>, unsigned, auto}                 
%                WordLength: Positive integer, <16>
%            FractionLength: Integer = -FixedExponent, <15>
%             FixedExponent: Integer = -FractionLength, <-15>
%                     Slope: Double, <2^-15>
%     SlopeAdjustmentFactor: Double, <1>, must greater than 1 and less than or equal to 2
%                      Bias: Double, <0>
%
%   Only fixed-point and integer numeric types are allowed in FI objects.
%
%   Fixed-point numbers are specified by one of the following formulas:
%
%   (1) If
%         DataTypeMode='Fixed-point: binary point scaling'
%         (equivalently, DataType='Fixed', Scaling='BinaryPoint')
%       then
%          Real-world value = (-1)^Signed * 2^(-FractionLength)  * (Stored Integer).
%
%   (2) If
%         DataTypeMode='Fixed-point: slope and bias scaling'
%         (equivalently, DataType='Fixed', Scaling='SlopeBias')
%       then
%         Real-world value = (-1)^Signed * SlopeAdjustmentFactor * 2^FixedExponent * (Stored Integer) + Bias.
%       The Slope is defined by
%         Slope = SlopeAdjustmentFactor * 2^FixedExponent
%
%   Examples:
%
%     T1 = numerictype
%     T2 = numerictype(1, 16, 15) % signed, wordlength = 16, fraclength = 15
%     T3 = numerictype(1, 32, 1.0, 0, 2.0)
%     T4 = numerictype('WordLength', 80, 'FractionLength', 40)
%     T5 = numerictype('Scaling', 'SlopeBias', 'SlopeAdjustmentFactor', 1.8, 'Bias', 10, 'FixedExponent', -14)
%
%     T6 = numerictype
%     T6.WordLength = 80
%     T6.FractionLength = 40
%
%     T7 = numerictype(T6, 'FractionLength', 50)
%
%   See also FI, FIMATH, FIPREF, QUANTIZER, SAVEFIPREF, FORMAT, FIXEDPOINT

%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $Date: 2009/05/14 16:53:36 $

if nargin == 1 && ischar(varargin{1})
    % numerictype('double'), numerictype('single'), numerictype('boolean')
    this = embedded.numerictype;
    this.datatype = varargin{1};
elseif nargin > 0 &&  ...
          (isnumeric(varargin{1}) || islogical(varargin{1}))
    % FIXDT-like signature
    % check rest of arguments
    error(nargchk(1, 5, nargin, 'struct'));
    for ii = 2 : nargin
        if ~isnumeric(varargin{ii})
            error('fixedpoint:numerictype:inputsNotNumeric','Invalid arguments (must be numeric).');
        end
    end
    this = embedded.numerictype;
    switch nargin
        case 1
            % signed
            % numerictype(true), numerictype(false)
            this.DataTypeMode = 'Fixed-point: unspecified scaling';
            this.SignednessBool = varargin{1};
            this.WordLength     = 16;
        case 2
            % signed, wordlength
            % numerictype(true, 32)
            this.DataTypeMode = 'Fixed-point: unspecified scaling';
            this.SignednessBool = varargin{1};
            this.WordLength     = varargin{2};
        case 3
            % signed, wordlength, fractionlength
            % numerictype(true, 32, 30)
            this.DataTypeMode   = 'Fixed-point: binary point scaling';
            this.SignednessBool = varargin{1};
            this.WordLength     = varargin{2};
            this.FractionLength = varargin{3};
        case 4
            % signed, wordlength, slope, bias
            % numerictype(true, 32, 0.1, 10)
            this.DataTypeMode   = 'Fixed-point: slope and bias scaling';
            this.SignednessBool = varargin{1};
            this.WordLength     = varargin{2};
            this.Slope          = varargin{3};
            this.Bias           = varargin{4};
        case 5
            % signed, wordlength, slopeadjustmentfactor, fixedexponent, bias
            % numerictype(true, 32, 1.2, -30, 10)
            this.DataTypeMode          = 'Fixed-point: slope and bias scaling';
            this.SignednessBool        = varargin{1};
            this.WordLength            = varargin{2};
            this.SlopeAdjustmentFactor = varargin{3};
            this.FixedExponent         = varargin{4};
            this.Bias                  = varargin{5};
        otherwise
    end
else
    % PV pair signature (with or w/o initial numerictype)
    n1=0;
    if nargin > 0 && isnumerictype(varargin{1})
        this = varargin{1};
        n1=n1+1;
    else
        this = embedded.numerictype;
    end
    n2 = nargin - n1;
    if fix(n2/2)~=n2/2
        error('fixedpoint:numerictype:invalidPVPairs','Invalid property/value pair arguments.');
    end
    for k=(n1+1):2:n2
        this.(varargin{k}) = varargin{k+1};
    end
end
