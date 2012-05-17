function import(this,TunedZPKSnapshot)
% Imports compensator data.
%

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2006/01/26 01:46:32 $


utRestoreTunedZPK(TunedZPKSnapshot,this);

% After importing compensator data make the parameterspec dirty
this.resetZPKParameterSpec;

