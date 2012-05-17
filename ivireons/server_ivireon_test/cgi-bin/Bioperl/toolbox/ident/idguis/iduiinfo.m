function res = iduiinfo(arg,obj,inf)
%IDUIINFO Manages the info-texts of the GUI objects

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2006/11/17 13:30:08 $

switch arg
    case 'set'
        %if ~iscell(inf)
        %  inf1=inf;
        %end
        if isstruct(obj)
            res = obj;
            res.Notes = inf;
        else
            res = pvset(obj,'Notes',inf);
        end
    case 'get'
        res =pvget(obj,'Notes');
        if isempty(res)
            res =[];
            return
        end
        if nargin<3
            inf = 'str';
        end
        if strcmp(inf,'str')
            strres = '';
            strres = decell(strres,res);
            res = strres;
        end
    case 'add'
        if isstruct(obj)
            inf1 = obj.Notes;
            if iscell(inf1),inf1=decell('',inf1);end
            inf2 = str2mat(inf1,inf);
            obj.Notes=inf2;
            res = obj;
        else
            inf1 = pvget(obj,'Notes');
            if iscell(inf1),inf1=decell('',inf1);end
            inf2 = str2mat(inf1,inf);

            res = pvset(obj,'Notes',inf2);
        end
end
%%%%%
function str = decell(str,res)
% makes a string matrix from possibly nested cellarrays of strings
if isempty(res)
    return
end

if ischar(res)
    if isempty(str)
        str = res;
    else
        str = str2mat(str,res);
    end

elseif iscell(res)
    str = decell(str,res{1});
    res = res(2:end);
    if ~isempty(res)
        str = decell(str,res);
    end
end
