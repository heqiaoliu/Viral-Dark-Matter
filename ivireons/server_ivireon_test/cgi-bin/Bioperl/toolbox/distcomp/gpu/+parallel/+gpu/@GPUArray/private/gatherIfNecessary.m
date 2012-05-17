function [objIsGpu, varargout] = gatherIfNecessary( shouldBeObj, varargin )
% gatherIfNecessary call gather if required on non-data arguments

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:32 $

CLASSNAME = 'parallel.gpu.GPUArray';

varargout = varargin;
for ii=1:length( varargout )
    if isa( varargout{ii}, CLASSNAME )
        varargout{ii} = gather( varargout{ii} );
    end
end
objIsGpu = isa( shouldBeObj, CLASSNAME );

end

