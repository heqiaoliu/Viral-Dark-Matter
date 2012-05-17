function pctSetmcrappkeys( k1, k2 )
; %#ok<NOSEM> Undocumented

% Wrapper around setmcrappkeys to deal with setmcrappkeys not being 
% available (for example, on local workers).
% Throws error if setmcrappkeykeys does not exist and the keys are being
% set to non-empty values.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $   $Date: 2008/10/02 18:40:13 $

if exist( 'setmcrappkeys', 'builtin' ) && feature('isDMLWorker')
    setmcrappkeys( k1, k2 );
else
    if isempty(k1) && isempty(k2)       
        % Empty keys do nothing, so doesn't matter if we can't set them.
    else
        % This is bad though, someone expected to be able to set the keys
        % to real values and they can't 
        error( 'distcomp:pctSetmcrappkeys:UnexpectedError', ...
            'Can''t set keys to non-empty values on client or local worker.' )
    end
end
