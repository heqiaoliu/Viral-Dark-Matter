function imin = intmin(rclassname)
%Embedded MATLAB Library Function
%
%   Limitations:
%   Only 8, 16, and 32 bit signed and unsigned integer types are supported.

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if (nargin == 0)
    imin = int32(-2147483648);
else
    % The @fi/intmin input is a fi (numeric) and not a char.
    % Protect this function from erroring out when the input type
    % is ambiguous and is not a char (class name)
    % If the input type is floating point & ambiguous, return 0.
    if ~ischar(rclassname) && eml_ambiguous_types && isa(rclassname,'float')
        imin = int32(0);
        return;
    elseif ~ischar(rclassname) && eml_ambiguous_types % if input is an integer
        classname = class(rclassname);
    else
        classname = rclassname;
    end
    eml_assert(ischar(classname),'Input must be a string, the name of an integer class.');
    switch (classname)
      case 'int8'
        imin = int8(-128);
      case 'uint8'
        imin = uint8(0);
      case 'int16'
        imin = int16(-32768);
      case 'uint16'
        imin = uint16(0);
      case 'int32'
        imin = int32(-2147483648);
      case 'uint32'
        imin = uint32(0);
      case 'int64'
        %imin = int64(-9223372036854775808);
        eml_assert(0,'Integer class "int64" not supported.');
      case 'uint64'
        %imin = uint64(0);
        eml_assert(0,'Integer class "uint64" not supported.');
      otherwise
        eml_assert(0,'Invalid class name.');
    end
end


