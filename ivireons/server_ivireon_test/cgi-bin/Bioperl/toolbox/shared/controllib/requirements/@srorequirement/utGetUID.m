function uid = utGetUID 
% UTGETUID generate unique id
%
 
% Author(s): A. Stothert 26-Feb-2008
%   Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:21 $

uid = tempname(' ');  %see tempname for uniqueness props
uid = uid(5:end);
