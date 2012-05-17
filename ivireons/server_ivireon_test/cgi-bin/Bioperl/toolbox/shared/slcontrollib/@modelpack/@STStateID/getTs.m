function Ts = getTs(this) 
% GETTS  method to return state sampling period. Zero indicates a continuous
% state.
%
 
% Author(s): A. Stothert 21-Jul-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:41:22 $

Ts = get(this,'Ts');
