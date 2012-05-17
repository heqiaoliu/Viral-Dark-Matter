function X = haltonPoints(obj, Start, Count)
%HALTONPOINTS Generate Halton set points
%   HALTONPOINTS generates the points that are accessed through the
%   HALTONSET object.
%
%   See also HALTONSET.
    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:20:41 $

% This file contains 4 similar copies of the same algorithm that cover each
% case of having no permute/permuting and looping over specified indices or
% looping across successive points.  The reasons for the copies instead of 
% pluggable subfunctions are performance.

if nargin==2
    if obj.PerformCoeffPermute
        X = subIndexedPermute(obj.Bases, Start, obj.CoeffPermutations);
    else
        X = subIndexedNoPermute(obj.Bases, Start);
    end
else
    if obj.PerformCoeffPermute
        X = subLoopPermute(obj.Bases, Start, Count, obj.Leap, obj.CoeffPermutations);
    else
        X = subLoopNoPermute(obj.Bases, Start, Count, obj.Leap);
    end
end



function X = subLoopPermute(Bases, Start, Count, Leap, Perms)
Ns = numel(Bases);
Leap = Leap+1;

X = zeros(Count, Ns);

PermsAreDone = ~isempty(Perms);

% Loop version.  This is at least as fast as an equivalent program in C.
for k = 1:Ns
    b = Bases(k);
    
    if PermsAreDone
        P = Perms{k};
    else
        % Generate the permutation
        P = getRR2Perm(b);
    end
    
    PointSetIndex = Start;
    for n = 1:Count
        Idx = PointSetIndex;
         
        x = 0;
        Radix = b;
        while Idx>0
            % Divide by base and work out remainder 
            IdxNew = floor(Idx/b);
            a = Idx - b.*IdxNew;
            Idx = IdxNew;
            
            % Permute coefficients
            a = P(a+1);
            
            x = x + a./Radix;
            Radix = Radix*b;
        end
        X(n,k) = x;

        PointSetIndex = PointSetIndex + Leap;
    end
end



function X = subLoopNoPermute(Bases, Start, Count, Leap)
Ns = numel(Bases);
Leap = Leap+1;

X = zeros(Count, Ns);
% Loop version.  This is at least as fast as an equivalent program in C.
for k = 1:Ns
    b = Bases(k);
    
    PointSetIndex = Start;
    for n = 1:Count
        Idx = PointSetIndex;
         
        x = 0;
        Radix = b;
        while Idx>0
            % Divide by base and work out remainder 
            IdxNew = floor(Idx/b);
            a = Idx - b.*IdxNew;
            Idx = IdxNew;

            x = x + a./Radix;
            Radix = Radix*b;
        end
        X(n,k) = x;

        PointSetIndex = PointSetIndex + Leap;
    end
end


function X = subIndexedPermute(Bases, Index, Perms)
Ns = numel(Bases);
Count = numel(Index);

X = zeros(Count, Ns);

PermsAreDone = ~isempty(Perms);

% Loop version.  This is at least as fast as an equivalent program in C.
for k = 1:Ns
    b = Bases(k);
    
    if PermsAreDone
        P = Perms{k};
    else
        % Generate the permutation
        P = getRR2Perm(b);
    end

    for n = 1:Count
        Idx = Index(n);
         
        x = 0;
        Radix = b;
        while Idx>0
            % Divide by base and work out remainder 
            IdxNew = floor(Idx/b);
            a = Idx - b.*IdxNew;
            Idx = IdxNew;
            
            % Permute coefficients
            a = P(a+1);
            
            x = x + a./Radix;
            Radix = Radix*b;
        end
        X(n,k) = x;
    end
end



function X = subIndexedNoPermute(Bases, Index)
Ns = numel(Bases);
Count = numel(Index);

X = zeros(Count, Ns);
% Loop version.  This is at least as fast as an equivalent program in C.
for k = 1:Ns
    b = Bases(k);
    
    for n = 1:Count
        Idx = Index(n);
         
        x = 0;
        Radix = b;
        while Idx>0
            % Divide by base and work out remainder 
            IdxNew = floor(Idx/b);
            a = Idx - b.*IdxNew;
            Idx = IdxNew;

            x = x + a./Radix;
            Radix = Radix*b;
        end
        X(n,k) = x;
    end
end
