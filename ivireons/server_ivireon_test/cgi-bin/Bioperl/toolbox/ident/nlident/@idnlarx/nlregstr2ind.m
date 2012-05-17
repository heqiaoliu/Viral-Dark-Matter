function nlrind = nlregstr2ind(sys, nlr)
%NLREGSTR2IND Convert string form of NonlinearRegressors values to indices.
%
% Syntax: nlrind = nlregstr2ind(sys, nlr)
%
% sys: idnlarx object
% nlr: NonlinearRegressors value possibly containing strings 'input','output','standard','custom', 'all'.
% nlrind: returned NonlinearRegressors value, an integer vector for single
% output model or a cell array of integer vectors for multiple output model.
%
% Note: the validity of nlr is not checked here, because it is done in pvset.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:53:15 $

% Author(s): Qinghua Zhang

ny = size(sys, 'ny');

% Quick exit for empty nlr
if isempty(nlr)
    if ny==1
        nlrind = [];
    else
        nlrind = cell(ny,1);
    end
    return
end

% Duplicate string form if necessary
if ny>1 && ischar(nlr)
    Vcell = cell(ny,1);
    [Vcell{:}] = deal(nlr);
    nlr = Vcell;
    clear Vcell
end

% number of standard regerssors
na = pvget(sys, 'na');
nb = pvget(sys, 'nb');
numyregs = sum(na,2);
numuregs = sum(nb,2);
if isempty(numyregs)
    numyregs = zeros(ny,1);
end
if isempty(numuregs)
    numuregs = zeros(ny,1);
end

%number of custom regerssors
cregs = pvget(sys, 'CustomRegressors');
if isempty(cregs)
    numcustregs = zeros(ny,1);
else
    if iscell(cregs)
        numcustregs = cellfun(@numel, cregs);
    else
        numcustregs = numel(cregs);
    end
end

if ~iscell(nlr)
    if ny>1
        ctrlMsgUtils.error('Ident:general:incorrectPropVal',...
            'NonlinearRegressors','IDNLARX','idnlarx')
    end
    nlr = {nlr};
end
nlrind = cell(ny,1);
for ky=1:ny
    nlrind{ky} = Str2RegInd(nlr{ky}, numyregs(ky), numuregs(ky), numcustregs(ky));
end

if ny==1
    nlrind = nlrind{1};
end

%==========================================================================
function  nlr = Str2RegInd(nlr, numyregs, numuregs, numcustregs)
if ischar(nlr)
    switch lower(strtrim(nlr))
        case {'input','u'}
            nlr = numyregs+1:numyregs+numuregs;
        case {'output', 'y'}
            nlr = 1:numyregs;
        case 'standard'
            nlr = 1:numyregs+numuregs;
        case 'custom'
            nlr = numyregs+numuregs+1:numyregs+numuregs+numcustregs;
        case 'all'
            nlr = 1:numyregs+numuregs+numcustregs;
        case 'search'
            % Do nothing
        otherwise
            ctrlMsgUtils.error('Ident:idnlmodel:idnlarxInvalidNLRStr')
    end
end

% nlr remains inchanged if not string

% FILE END
