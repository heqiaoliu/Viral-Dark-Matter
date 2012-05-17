function tf = iscolon(indices)
%ISCOLON Check if a set of indices is ':'.

%   Copyright 2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:10 $

% Check ischar first.  isequal(58,':') alone is true,
% and strcmp({':'},':') is also true
tf = ischar(indices) && strcmp(indices,':');