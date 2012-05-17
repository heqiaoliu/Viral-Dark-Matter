function value = rtw_host_implementation_props()
% RTW_HOST_IMPLEMENTATION_PROPS - returns C specific implementation
% properties for the host computer inside a MATLAB structure.
%
% See also RTW_IMPLEMENTATION_PROPS, EXAMPLE_RTW_INFO_HOOK.
  
% Copyright 1994-2008 The MathWorks, Inc.
% $Revision: 1.3.4.11 $
  
  
try  
  % hostcpuinfo returns an array of doubles containing information about the
  % host cpu.  This information is dynamically calculated, so should be
  % host independent.  The array contains the following information:
  %
  % element #   Value/descrtiption
  %    1        Shift right behavior
  %               0 == logical
  %               1 == arithmetic
  %    2        Signed Integer division rounding
  %               1 == round toward floor
  %               2 == round toward 0
  %               3 == undefined rounding behavior
  %    3        Byte ordering
  %               0 == Little Endian
  %               1 == Big Endian
  %    4        Number of bits per char
  %    5        Number of bits per short
  %    6        Number of bits per int
  %    7        Number of bits per long
  host_cpu           = hostcpuinfo;

  value.ShiftRightIntArith   = (host_cpu(1) == 1);
  if (host_cpu(2) == 1)
    value.IntDivRoundTo        = 'Floor';
  elseif (host_cpu(2) == 2)
    value.IntDivRoundTo        = 'Zero';
  else
    value.IntDivRoundTo        = 'Undefined';
  end
  if (host_cpu(3) == 0)
    value.Endianess            = 'LittleEndian';
  else
    value.Endianess            = 'BigEndian';
  end    

catch myException
    %
    % This error should not occur for a shipping version of Real Time Workshop.
    % It should only occur if a new MATLAB Host is being developed, but the
    % existence of that new host has not been coordinated Real Time Workshop.
    %
    errID  = 'RTW:buildProcess:unknownHost';
    errText = DAStudio.message(errID);
    newExc = MException(errID,errText);
    newExc = newExc.addCause(myException);
    throw(newExc) 
end
  
  
