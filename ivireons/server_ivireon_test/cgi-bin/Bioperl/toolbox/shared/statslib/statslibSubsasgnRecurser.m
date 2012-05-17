function a = statslibSubsasgnRecurser(a,s,b)
%STATSLIBSUBSASGNRECURSER Utility for overloaded subsasgn methods in statslib.

% Call builtin, to get correct dispatching even if b is an object.
a = builtin('subsasgn',a,s,b);

