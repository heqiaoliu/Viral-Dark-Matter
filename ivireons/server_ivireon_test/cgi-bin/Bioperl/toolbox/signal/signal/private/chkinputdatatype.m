function chkinputdatatype(varargin)
%CHKINPUTDATATYPE Check that all inputs are double

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:10:19 $


for n = 1:nargin
    if ~isa(varargin{n},'double')
        error(generatemsgid('NotSupported'),'Input arguments must be ''double''.');
    end
end



% [EOF]
