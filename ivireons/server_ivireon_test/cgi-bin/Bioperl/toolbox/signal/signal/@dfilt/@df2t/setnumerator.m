function num = setnumerator(this, num)
%SETNUMERATOR   Set the numerator.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:27:15 $

oldlength = 0;
ncoeffs   = this.ncoeffs;
if ~isempty(ncoeffs), oldlength = ncoeffs(1); end

if oldlength~=length(this.Numerator)
    % We are in a load state. Check to see if we've saved a bad object.
    if length(this.HiddenStates) >= max(ncoeffs)
        warning(generatemsgid('corruptMATFile'), ...
            sprintf('%s\n%s', ...
                'The MAT-file you are loading appears to contain a DFILT saved', ...
                'in a previous version of MATLAB.  Please resave the MAT-file.'));
        this.HiddenStates = this.HiddenStates(1:max(ncoeffs)-1);
    end
end

num = dtfwnum_setnumerator(this, num);

% [EOF]
