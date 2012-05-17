function tf = isequaltemplate( nansAreEqual, varargin )
%ISEQUALTEMPLATE - for ISEQUAL and ISEQUALWITHEQUALNANS

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:25 $

varSizes = cellfun(@size, varargin, 'UniformOutput', false);
isSizeCompatible = isequal(varSizes{:});
if ~isSizeCompatible
    tf = false;
    return
end

% Compare the first element with each other element.
tf = true;

try
    % Only cast this argument once
    compareAgainst = pGPU( varargin{1} );
    for ii=2:length( varargin )
        % Force comparison on the GPU
        tf = tf && all( hElementwiseComparison( compareAgainst, ...
                                                pGPU( varargin{ii} ), ...
                                                nansAreEqual ) );
        if ~tf
            % Early return for when we fail
            return
        end
    end
catch E
    if isequal( E.identifier, 'parallel:gpu:BadDataType' )
        % Couldn't cast
        tf = false;
        return
    else
        rethrow( E );
    end
end

end
