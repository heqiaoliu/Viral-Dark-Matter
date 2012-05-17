function Hd = optimizestopbandfir(this,Href,WL,varargin) %#ok<STOUT,INUSD>
%OPTIMIZESTOPBANDFIR 
%   This should be a private method.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:32:14 $

error(generatemsgid('unsupportedFilterStructure'),...
    [ 'This function is not supported for ', class(this), ' filters.']');

% [EOF]
