function [x,kcount]=idstrip(xstring,num)
%IDSTRIP Converts a string of numbers, separated by spaces, to numbers.
%   XSTRING:a string of numbers,
%   X:   contains the numbers
%   KCOUNT: The number of numbers in XSTRING
%   NUM: If num=='on', the X will contain numbers, otherwise it is
%        a string matrix

%   L. Ljung 4-4-94
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2008/10/31 06:12:03 $

if nargin<2
    num = 'on';
end
sl1 = xstring;
nrblank = [1,find(sl1==' '),length(sl1)+1];
kcount = 1;
nn = [];
for k = 1:length(nrblank)-1
    ntemp = deblank(sl1(nrblank(k):nrblank(k+1)-1));
    if ~isempty(ntemp),
        if strcmp(num,'on')
            try
                nn(kcount) = eval(ntemp);
            catch
                %nn(kcount) = [];
            end
        else
            ntemp = ntemp(ntemp~=' ');
            nn = str2mat(nn,ntemp);
        end
        kcount = kcount+1;
    end
end
x=nn;
if ~strcmp(num,'on')
    [nr,nc] = size(x);
    x = x(2:nr,:);
end
