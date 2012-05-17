function imax = intmax(rclassname)
%Embedded MATLAB Library Function

%   Limitations:
%   Only 8, 16, and 32 bit signed and unsigned integer types are supported.

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if (nargin == 0)
    imax = int32(2147483647);
else
    % The @fi/intmax input is a fi (numeric) and not a char.
    % Protect this function from erroring out when the input type
    % is ambiguous and is not a char (class name)
    % If the input type is floating point & ambiguous, return 0
    if ~ischar(rclassname) && eml_ambiguous_types && isa(rclassname,'float')
        imax = int32(0);
        return;
    elseif ~ischar(rclassname) && eml_ambiguous_types % if input is an integer
        classname = class(rclassname);
    else
        classname = rclassname;
    end
    
    eml_assert(ischar(classname),'Input must be a string, the name of an integer class.');
    switch (classname)
      case 'int8'
        imax = int8(127);
      case 'uint8'
        imax = uint8(255);
      case 'int16'
        imax = int16(32767);
      case 'uint16'
        imax = uint16(65535);
      case 'int32'
        imax = int32(2147483647);
      case 'uint32'
        imax = uint32(4294967295);
      case 'int64'
        %imax = int64(9223372036854775807);
        eml_assert(0,'Integer class "int64" not supported.');
      case 'uint64'
        %imax = uint64(18446744073709551615);
        eml_assert(0,'Integer class "uint64" not supported.');
      otherwise
        eml_assert(0,'Invalid class name.');
    end
end
