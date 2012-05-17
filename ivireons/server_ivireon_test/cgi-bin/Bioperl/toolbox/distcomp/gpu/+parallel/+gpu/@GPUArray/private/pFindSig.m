function inputSig = pFindSig(varargin)
% helper function to find input signature.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $  $Date: 2010/06/10 14:27:29 $

numelvarargin = numel(varargin);
inputSig = char(1:3*numelvarargin);

for ik = 1:numelvarargin
    
    if isa(varargin{ik},'parallel.gpu.GPUArray')
        
        switch classUnderlying(varargin{ik})
            case 'double',  inputSig( 1 + 3*(ik-1) ) = 'D';
            case 'single',  inputSig( 1 + 3*(ik-1) ) = 'F';
            case 'int32',   inputSig( 1 + 3*(ik-1) ) = 'I';
            case 'uint32',  inputSig( 1 + 3*(ik-1) ) = 'U';
            case 'logical', inputSig( 1 + 3*(ik-1) ) = 'B';
            otherwise
                error('parallel:GPU:pFindSig','Only types double, single, int32, uint32, and logical are supported.');
        end
        
    else
        
        switch class(varargin{ik})
            case 'double',  inputSig( 1 + 3*(ik-1) ) = 'D';
            case 'single',  inputSig( 1 + 3*(ik-1) ) = 'F';
            case 'int32',   inputSig( 1 + 3*(ik-1) ) = 'I';
            case 'uint32',  inputSig( 1 + 3*(ik-1) ) = 'U';
            case 'logical', inputSig( 1 + 3*(ik-1) ) = 'B';
            otherwise
                error('parallel:GPU:pFindSig','Only types double, single, int32, uint32, and logical are supported.');
        end
        
    end
    
    if 1 == numel(varargin{ik})
        inputSig( 2 + 3*(ik-1) ) = 's';   % scalar
    else
        inputSig( 2 + 3*(ik-1) ) = 'a';   % array
    end
    
    if isreal(varargin{ik})
       inputSig( 3 + 3*(ik-1) ) = 'r';  % real 
    else
       inputSig( 3 + 3*(ik-1) ) = 'c';  % complex         
    end
    
end

end



