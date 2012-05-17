function dispstr = strexpression(this)
%STREXPRESSION return the string expression of the custom regressor

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/03/09 19:14:44 $

% Author(s): Qinghua Zhang

dispstr = this.Display;
if ~isempty(dispstr)
    return
end

TimeVar = this.TimeVariable;
if isempty(TimeVar) || ~ischar(TimeVar)
    TimeVar = 't';
end

if isa(this.Function, 'function_handle')
    fstr = func2str(this.Function);
else
    dispstr = '';
    return
end

nra = length(this.Arguments);

try
    % Construct argument strings
    argstrs = cell(nra,1);
    for kra=1:nra
        argstrs{kra} = [this.Arguments{kra}, '(', TimeVar '-' num2str(this.Delays(kra)) ')'];
    end
    
    % Construct string form
    if fstr(1)=='@'
        % anonymous function with  empty Display
        dispstr = AnonymousFunStrTransform(fstr, argstrs);
    else
        % named function
        dispstr = [fstr, '('];
        for kra=1:nra
            dispstr = [dispstr, argstrs{kra}];
            if kra<nra
                dispstr = [dispstr, ','];
            end
        end
        dispstr = [dispstr, ')'];
    end
catch 
    dispstr = '<Malformed expression>';
end

%=============================================
function fstr = AnonymousFunStrTransform(fstr, trueargstrs)
% Anonymous function string transformation for explicit form

nra = length(trueargstrs);

% Find out orgargstrs
firstpend = min(strfind(fstr, ')'));
if nra==1
    orgargstrs = {fstr(3:firstpend-1)};
else
    comas = strfind(fstr(1:firstpend), ',');
    orgargstrs = cell(nra,1);
    orgargstrs{1} = fstr(3:comas(1)-1);
    for kra=2:nra-1
        orgargstrs{kra} = fstr(comas(kra-1)+1:comas(kra)-1);
    end
    orgargstrs{nra} = fstr(comas(nra-1)+1:firstpend-1);
end

% Remove @(...)
fstr = fstr(firstpend+1:end);

% Argument replacement

% Replace longest original strings first to avoid taking part of a
% long string as a short string
orgarglen = cellfun(@numel, orgargstrs(:));
[dum, sortedind] = sort(orgarglen, 1, 'descend');
sortedind = sortedind(:)'; % To be surely a row vector

% To avoid confusion between the strings in orgargstrs and trueargstrs,
% replace orgargstrs by "?#@".
for kra=sortedind
    %fstr = strrep(fstr, orgargstrs{kra}, ['?', int2str(kra)]);
    fstr = VariableRep(fstr, orgargstrs{kra}, ['?', int2str(kra), '@']);
    orgargstrs{kra} = ['?', int2str(kra), '@'];
end
for kra=sortedind
    fstr = strrep(fstr, orgargstrs{kra}, trueargstrs{kra});
end

%=============================================================
function newtext = VariableRep(text, oldpat, newpat)
% Variable replacement. Similar to strrep, but the replaced

textlen = length(text);
oldpathlen = length(oldpat);

ind = strfind(text, oldpat);
for k=1:length(ind)
    if ind(k)>1 && (isstrprop(text(ind(k)-1), 'alphanum') || text(ind(k)-1)=='_')
        ind(k) = 0;
    elseif ind(k)+oldpathlen-1<textlen ...
            && (isstrprop(text(ind(k)+oldpathlen), 'alphanum') || text(ind(k)+oldpathlen)=='_')
        ind(k) = 0;
    end
end
ind = ind(ind~=0);

if isempty(ind)
    newtext = text;
else
    newtext = text(1:ind(1)-1);
    for k=1:(length(ind)-1)
        newtext = [newtext, newpat, text(ind(k)+oldpathlen:ind(k+1)-1)];
    end
    newtext = [newtext, newpat, text(ind(end)+oldpathlen:end)];
end

% FILE END
