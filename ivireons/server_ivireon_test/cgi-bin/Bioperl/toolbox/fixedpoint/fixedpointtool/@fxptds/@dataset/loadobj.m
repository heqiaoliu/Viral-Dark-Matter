function ds = loadobj(s)
%LOADOBJ Load dataset
%   DS = LOADOBJ(S) is called by LOAD when an object is loaded from a .MAT
%   file. The return value DS is subsequently used by LOAD to populate the
%   workspace.
%
%   LOADOBJ will be separately invoked for each object in the .MAT file.
%
%   See also LOAD, SAVEOBJ.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/17 21:48:58 $

if(~isstruct(s)); return; end
%create dataset
ds = fxptds.dataset;
%initialize the dataset
ds.init;
%for each run
for i = 1:length(s)
    ds.adddata(s(i).Run, fxptds.resultsdata(s(i)));
end

% [EOF]