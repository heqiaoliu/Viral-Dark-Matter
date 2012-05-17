function [textCellArray err] = pGetMcode(filename, bufferSize)
% modified for mpiprofview from pgetmcode original
%GETMCODE  Returns a cell array of the text in a file
%   textCellArray = getmcode(filename)
%   textCellArray = getmcode(filename, bufferSize)

% Copyright 1984-2006 The MathWorks, Inc.
if nargin < 2
    bufferSize = 30000;
end
 err = '';
fid = fopen(filename,'r');
if fid < 0
    textCellArray = {};

    err = sprintf('Unable to read file %s', filename);
    return;
end
txt = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',bufferSize);
fclose(fid);

textCellArray = txt{1};