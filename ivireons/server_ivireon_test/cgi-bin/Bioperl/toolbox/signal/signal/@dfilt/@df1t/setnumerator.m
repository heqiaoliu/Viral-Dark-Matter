function num = setnumerator(this, num)
%SETNUMERATOR   Set the numerator.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:18:44 $

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
        
            % The R13 version of the DF1T used to append a zero to end of 
            % the states vector (S(end)) for both the numerator and denoimator.  
            % The R14 version does not require any zero-padding of the
            % states.
            if ~strcmpi(class(this.HiddenStates),'filtstates.dfiir'),
                nb = this.ncoeffs(1);
                na = this.ncoeffs(2);
                Sinit = this.HiddenStates;
                S = filtstates.dfiir;
                % Negate the denominator states to ensure that output
                % signal matches the R13 result
                S.Denominator = -(Sinit(1:na-1,:));
                S.Numerator = Sinit(na+1:end-1,:);
                this.HiddenStates = S;
            end
    end
end

num = dtfwnum_setnumerator(this, num);

% [EOF]
