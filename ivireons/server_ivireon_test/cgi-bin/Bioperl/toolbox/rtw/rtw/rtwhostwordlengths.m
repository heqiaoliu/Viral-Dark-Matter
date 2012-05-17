function value = rtwhostwordlengths()
% RTWHOSTWORDLENGTHS - returns the word lengths for the host computer
% inside a MATLAB structure.
%
% See also RTWWORDLENGTHS, EXAMPLE_RTW_INFO_HOOK.

% Copyright 1994-2010 The MathWorks, Inc.
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
    
    value.CharNumBits  = host_cpu(4);
    value.ShortNumBits = host_cpu(5);
    value.IntNumBits   = host_cpu(6);
    value.LongNumBits  = host_cpu(7);
    value.FloatNumBits = 32;
    value.DoubleNumBits = 64;
    % the native word size cannot be determined dynamically.  the best guess is
    % currently the size of the long, which is currently true on all
    % supported platforms:
    % 'PCWIN', 'PCWIN64', 'GLNX86', 'GLNXA64', 'MACI', 'SOL64'
    value.WordSize     = value.LongNumBits;
    value.PointerNumBits = value.WordSize;

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
