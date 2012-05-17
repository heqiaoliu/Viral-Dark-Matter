function mhelp(topic)
%MHELP  Maple help.
%   The MHELP function is not supported and will be removed in a future release.

%   MHELP topic  prints Maple's help text for the topic when Maple is the
%   active symbolic engine.
%   MHELP('topic') does the same thing.
%
%   Example: 
%      mhelp gcd 
%
%   See also: symengine

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/11/05 18:21:16 $

if nargin == 0
    help mhelp
else
    eng = symengine;
    if strcmp(eng.kind,'maple')
        mapleengine('help',topic);
    else
        error('symbolic:mhelp:NotInstalled','The MHELP command is not available.');
    end
end
