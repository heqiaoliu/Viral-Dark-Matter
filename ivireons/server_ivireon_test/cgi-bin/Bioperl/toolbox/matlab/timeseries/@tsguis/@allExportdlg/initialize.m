function initialize(h,type,tsfigure,tsobj)
% Builds the export dialog for all the file types
%   type='all': open export dialog gui to export multiple ts objects
%   type='workspace': export single ts object (tsname) into workspace
%   type='file': export single ts object (tsname) into a file

% Copyright 2004 The MathWorks, Inc.

if strcmpi(type,'all')
    % to be implemented
    return
elseif  strcmpi(type,'file')
    h.Handles.Excel=[];
    h.exportsinglefile(tsfigure,tsobj);
else
    return
end
