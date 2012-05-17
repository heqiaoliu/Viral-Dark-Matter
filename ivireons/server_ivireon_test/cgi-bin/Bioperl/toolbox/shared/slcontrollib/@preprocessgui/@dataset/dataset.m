function h = dataset(data,time,varargin)
%DATASET
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:28:38 $

h = preprocessgui.dataset;
h.Data = data;
h.Time = time;
if nargin==2
    h.Name = 'default';
end
h.headings = cell(size(data,2),1);
for k=1:size(data,2)
   h.headings{k} = ['Column ' num2str(k)];
end