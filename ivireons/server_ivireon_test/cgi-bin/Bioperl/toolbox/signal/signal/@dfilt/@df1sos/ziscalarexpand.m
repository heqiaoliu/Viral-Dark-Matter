function S = ziscalarexpand(Hd,S)
%ZISCALAREXPAND Expand empty or scalar initial conditions to a vector.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/03/30 23:59:49 $

error(nargchk(2,2,nargin,'struct'));

if ~isnumeric(S)
    error(generatemsgid('MustBeNumeric'),'States must be numeric.');
end
if issparse(S),
    error(generatemsgid('Sparse'),'States cannot be a sparse matrix.');
end

nsecs = nsections(Hd);

if nsecs ~=0
    if isempty(S),
        S = nullstate1(Hd.filterquantizer);
    end
    if length(S)==1,
        % Because the spec for setting the states for the DF1, DF1T, DF1SOS, and
        % DF1TSOS allows one to set both a FILTSTATES.DFIIR and a double
        % vector, we have to check for the class and extract the appropriate
        % portions of each.
        if strcmpi(class(S), 'filtstates.dfiir'),
            if length(S.Numerator)==1,
                S.Numerator   = S.Numerator(ones(2,nsecs));
            end
            if length(S.Denominator)==1,
                S.Denominator   = S.Denominator(ones(2,nsecs));
            end
        else
            Sinit = S;
            S = filtstates.dfiir;
            % Expand the scalar Sinit
            S.Numerator = Sinit(ones(2,nsecs));
            S.Denominator = Sinit(ones(2,nsecs));
        end
    elseif strcmpi(class(S), 'filtstates.dfiir'),
        error(generatemsgid('MustBeOneObject'),'The length of the object storing the states must be 1.');
    end
    
    if ~strcmpi(class(S), 'filtstates.dfiir'),
        Sinit = S;
        % At this point we must have a matrix with the right number of rows
        statespersec = 4;
        if size(Sinit,1) ~= statespersec,
            error(generatemsgid('InvalidDimensions'),...
                'The states must be a matrix with %d rows per channel.',statespersec);
        end
        % Always return a FILTSTATES.DFIIR object
        S = filtstates.dfiir;
        S.Numerator = Sinit(1:2,:);
        S.Denominator = Sinit(3:4,:);
    end
end
