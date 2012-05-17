function deletefilter(hFVT, indx)
%DELETEFILTER Delete a filter from FVTool

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2007/12/14 15:18:47 $ 

error(nargchk(2,2,nargin,'struct'));

filtobjs = get(hFVT, 'Filters');

if isa(indx, 'dfilt.dfiltwfs'),
    indx = find(filtobjs == indx);
end

% Verify that the input is valid.
if length(filtobjs) < indx,
    error(generatemsgid('IdxOutOfBound'),'Index exceeds the number of available filters.');
end

% Delete the selected filter
filtobjs(indx) = [];

% Set the new filter list
hFVT.setfilter(filtobjs);

% [EOF]
