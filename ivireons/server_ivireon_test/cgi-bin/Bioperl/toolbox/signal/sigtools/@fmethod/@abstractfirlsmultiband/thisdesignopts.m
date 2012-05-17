function s = thisdesignopts(this, s, N)
%THISDESIGNOPTS   

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 18:00:17 $

if nargin < 3,
    % Called by info method
    for k = 1:10,
        str = [sprintf('B%d',k),'Weights'];
        if isempty(get(this,str)),
            s = rmfield(s, str);
        end
    end
else    
    if N<10,
        s = rmfield(s, {'B10Weights'});
    end
    if N<9,
        s = rmfield(s, {'B9Weights'});
    end
    if N<8,
        s = rmfield(s, {'B8Weights'});
    end
    if N<7,
        s = rmfield(s, {'B7Weights'});
    end
    if N<6,
        s = rmfield(s, {'B6Weights'});
    end
    if N<5,
        s = rmfield(s, {'B5Weights'});
    end
    if N<4,
        s = rmfield(s, {'B4Weights'});
    end
    if N<3,
        s = rmfield(s, {'B3Weights'});
    end
    if N<2,
        s = rmfield(s, {'B2Weights'});
    end
end
% [EOF]
