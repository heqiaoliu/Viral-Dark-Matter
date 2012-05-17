function resetParameterSpec(this)
% Make param spec dirty for pzgroups

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2005/12/22 17:40:48 $

this.ParamSpec = handle(zeros(0,1));