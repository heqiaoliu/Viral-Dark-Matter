function pModifyPostConfigurationFcn(obj, index, fcn, varargin)
; %#ok Undocumented

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/08/26 18:13:19 $ 

assert( isequal(obj.PostConfigurationFcns{index, 1}, fcn) , ...
    'distcomp:object:InvalidPostConfigurationFcn', 'Attempt to modify with a different PostConfigurationFcn' );
% Otherwise update the arguments to the given function
obj.PostConfigurationFcns{index, 2} = varargin;