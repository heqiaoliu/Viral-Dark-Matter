function this = sfdr(varargin)
%SFDR   Construct a SFDR options object

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:13:38 $

this = dspopts.sfdr;

if nargin   
    set(this, varargin{:});
end
% [EOF]
