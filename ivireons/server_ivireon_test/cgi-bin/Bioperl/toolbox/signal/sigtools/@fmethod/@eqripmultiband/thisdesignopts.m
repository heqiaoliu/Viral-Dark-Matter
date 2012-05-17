function s = thisdesignopts(this, s, N)
%THISDESIGNOPTS

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:27:09 $


if nargin < 3,
    % Called by info method

    for k = 1:10,
        str = [sprintf('B%d',k),'Weights'];
        if isempty(get(this,str)),
            s = rmfield(s, str);
        end
    end
else

    s = rmfield(s, {'MinPhase'});
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
