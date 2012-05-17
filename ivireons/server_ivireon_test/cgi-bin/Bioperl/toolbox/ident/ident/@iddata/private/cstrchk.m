function [a,errflag] = cstrchk(a,Name)
%CSTRCHK Determines if argument is a vector cell of single line strings.

%	P. Gahinet 5-1-96
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.7.4.6 $  $Date: 2008/05/19 23:02:40 $

errflag = struct([]);
if isempty(a)
    return
end

errflag1 = struct('identifier','','message','');
if ndims(a)>2 || (~ischar(a) && ~isa(a,'cell'))
    errflag1.identifier = 'Ident:iddata:cstrchk1';
    errflag1.message = sprintf(['%s must be a 2D array of padded strings (like [''a'' ; ''b'' ; ''c''])\n' ...
        'or a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).'],Name);
    errflag = errflag1;
    return
elseif ischar(a),
    % A is a 2D array of paded strings
    a = cellstr(a);
end%else

% A is a cell array
if min(size(a))>1
    errflag1.identifier = 'Ident:iddata:cstrchk2';
    errflag1.message = [Name ' must be a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).'];
    errflag = errflag1;
    return
end

if strcmp(Name,'Unit')
    a = a(:)';
    if length(unique(a))>1
        errflag1.identifier = 'Ident:iddata:cstrchk3';
        errflag1.message = 'All experiments must have the same Unit.';
        errflag = errflag1;
        return
    end
else
    a = a(:);
end%was (:)'

for k=1:length(a),
    str = a{k};
    if isempty(str),
        a{k} = '';
    elseif ~ischar(str) || ndims(str)>2 || size(str,1)>1
        errflag1.identifier = 'Ident:iddata:cstrchk4';
        errflag1.message = ['All cell entries of ' Name ' must be single-line strings'];
        errflag = errflag1;
        return
    elseif strcmpi(Name,'InterSample') && ~any(strcmpi(str,{'zoh','foh','bl'}))
        errflag1.identifier = 'Ident:iddata:cstrchk5';
        errflag1.message = 'InterSample must be one of ''zoh'' (zero order hold) ,''foh'' (first order hold), or ''bl'' (band limited)';
        errflag = errflag1;
        return
    elseif strcmpi(Name,'Unit')
        if lower(str(1))=='h'
            a{k} = 'Hz';
            %elseif lower(str(1))=='r'
            %a{k} = 'rad/s';
        elseif ~any(lower(str(1))==['r','c','1']) || isempty(findstr(str,'/'))
            errflag1.identifier = 'Ident:iddata:cstrchk6';
            errflag1.message = 'The frequency unit must be ''rad/TimeUnit'', ''1/TimeUnit'', ''cycles/TimeUnit'', or ''Hz''.';
            errflag = errflag1;
        end
    end
end
%end

% end cstrchk
