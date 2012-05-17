function obj = setNameFromSource(obj)
%

% SETNAMEFROMSOURCE - utility method to be construct a name to
% display from the source (blk,portnum,signalname) information.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:25:58 $

% Read source information
blkname = obj.Source.Block;
portnum = obj.Source.PortNumber;
signame = obj.Source.SignalName;

% Get rid of new lines in block name
blkname = regexprep(blkname,'\n',' ');
blkstr = [blkname ' : ' num2str(portnum)];
str = blkstr;
if ~isempty(signame)
    str = [blkstr ' (' signame ')'];
end
% Limit to 45 characters
charlimit = 45;
if numel(str) > charlimit    
    % Find separators in block/port    
    sep = findstr(blkstr,'/');
    strlen = numel(blkstr);
    seplen = strlen-sep+3; % Count for 3 dots
    if isempty(signame)           
        sepind = find(seplen < charlimit,1,'first');
        str = ['.../' blkstr(sep(sepind)+1:end)];
    else
        charlimit = charlimit-numel(signame)-3;
        sepind = find(seplen < charlimit,1,'first');
        str = ['.../' blkstr(sep(sepind)+1:end) '(' signame ')']; 
    end
end
% Set the name
obj.Name = str;
