function sftab2chk(xindex,yindex,table)
%SFTAB2CHK Checks input to SFTABLE2 for correctness.
%   SFTAB2CHK(XINDEX,YINDEX,TABLE) makes sure that all of the arguments
%   to SFTABLE2 are appropriate.

%   Copyright 1990-2007 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $
%   Ned Gulley 3-9-92

xlen = length(xindex);
ylen = length(yindex);
[m,n] = size(table);
if m ~= xlen,
  DAStudio.error('Simulink:blocks:mustHaveSameNumberOfElements', 'XINDEX', 'rows');
end
if n ~= ylen,
  DAStudio.error('Simulink:blocks:mustHaveSameNumberOfElements', 'YINDEX', 'columns');
end

if any(diff(xindex) <= 0),
  DAStudio.error('Simulink:blocks:indexMustMonotonicallyIncrease', 'XINDEX');
end
if any(diff(yindex) <= 0),
  DAStudio.error('Simulink:blocks:indexMustMonotonicallyIncrease', 'YINDEX');
end
