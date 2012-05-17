function unselect(this,opt)
%UNSELECT Turn off selected signal
%   To un-select all signals and blocks in the system, use UNSELECT('all')
%   To un-select only those signals in the current connection,
%   use UNSELECT('current') or omit the option.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2007/08/03 21:38:23 $

% Is this all signals in the model?
if nargin<2
    allSigs = false;
else
    idx=strmatch(opt,{'current','all'});
    if isempty(idx)
        error(generatemsgid('InvalidOption'), 'Option must be either ''current'' or ''all''.')
    end
    allSigs = (idx==2);
end

if allSigs
    for indx = 1:length(this)
        % Unselect all signals in current system
        lines = gsl(this(indx).System.handle);
        if ~isempty(lines)
            set(lines,'selected','off')
        end

        % Unselect all blocks as well
        blks = gsb(this(indx).System.handle);
        if ~isempty(blks)
            set(blks,'selected','off');
        end
    end
else
    % Just unselect the current signal
    select(this,'off');
end

% [EOF]
