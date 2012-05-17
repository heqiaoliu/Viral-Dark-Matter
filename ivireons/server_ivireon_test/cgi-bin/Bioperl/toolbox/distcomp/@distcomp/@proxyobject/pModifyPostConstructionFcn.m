function pModifyPostConstructionFcn(obj, index, fcn, varargin)
; %#ok Undocumented

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/06/24 17:01:47 $ 

assert( isequal(obj.PostConstructionFcns{index, 1}, fcn) , ...
    'distcomp:object:InvalidPostConstructionFcn', 'Attempt to modify with a different post construction function' );
% Otherwise update the arguments to the given function
obj.PostConstructionFcns{index, 2} = varargin;