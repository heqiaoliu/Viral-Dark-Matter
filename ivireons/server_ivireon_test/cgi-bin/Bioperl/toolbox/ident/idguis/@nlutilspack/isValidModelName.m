function boo = isValidModelName(Name,Type)
%Check if the specified model name is a valid variable name and unique for
% the specified model Type. If Type is not specified or is empty, uniqueness
% of the name among all model names is checked.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:32:28 $

if nargin<2
    % model class not specified
    Type = ''; %uniquesnes among ALL models would be returned
end

boo =  isvarname(Name) && ~ismember(Name,nlutilspack.getAllModels(Type,true));
