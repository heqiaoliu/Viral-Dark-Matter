function n = numel( obj, varargin )
%NUMEL Composite numel method
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/06/24 17:03:21 $
   
% Simply defer to the KeyVector
    n = numel( obj.KeyVector, varargin{:} );
end
