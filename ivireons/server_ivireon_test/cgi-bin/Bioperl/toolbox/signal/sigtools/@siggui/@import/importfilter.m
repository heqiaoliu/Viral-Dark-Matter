function importfilter(this)
%IMPORT Import the filter into the Filter Target

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.18.4.6 $  $Date: 2009/07/27 20:32:16 $

sendstatus(this, 'Importing Filter ...');

hcs = getcomponent(this, '-class', 'siggui.coeffspecifier');
hfs = getcomponent(this, '-class', 'siggui.fsspecifier');

% Get the constructor from the Filter Structure popup
object = getshortstruct(hcs,'object');

% Get the selected coefficient strings
coeffStrs = getselectedcoeffs(hcs);

[coeffVals, errStr] = evaluatevars(coeffStrs);

% This check is to allow the importing of filters which are already
% contained within objects.
if strcmpi(errStr,[coeffStrs{1} ' is not numeric.']),
    errStr = '';
end
if ~isempty(errStr), error(generatemsgid('SigErr'),errStr); end

% SOS Is the one "special" case
if strcmpi(get(hcs, 'SOS'), 'on'),
    object = [object 'sos'];
end

% If the coefficient specified is already an object just assign it, as long
% as it is of the correct type.
if isa(coeffVals{1}, 'dfilt.basefilter')
    if isa(coeffVals{1},object)
        data.filter = copy(coeffVals{1});
    else
        error(generatemsgid('GUIErr'),'Imported filter does not match selected filter structure.');
    end
else
        
    % Lattice Allpass is another special case, we only use the first coeff
    if strcmpi(object,'dfilt.latticeallpass')
        coeffVals = coeffVals(1);
    end
    
    % Create the filter object using the constructor and coefficients
    data.filter = feval(str2func(object),coeffVals{:});
end

% Send the new filter
data.fs = getfsvalue(hfs);

send(this, 'FilterGenerated', ...
    sigdatatypes.sigeventdata(this, 'FilterGenerated', data));
set(this, 'isImported', 1);

sendstatus(this, 'Importing Filter ... done');


% [EOF]
