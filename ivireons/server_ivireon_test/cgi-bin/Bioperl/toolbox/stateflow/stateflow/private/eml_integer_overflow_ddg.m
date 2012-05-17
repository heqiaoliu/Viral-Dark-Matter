function G = eml_integer_overflow_ddg(row,cols)

% Copyright 2005-2008 The MathWorks, Inc.

G.Name = message('Name');[''];
G.Type = 'checkbox';

G.ObjectProperty = 'SaturateOnIntegerOverflow';
G.RowSpan = [row row];
G.ColSpan = cols;      

function s = message(id,varargin)

s = DAStudio.message(['Stateflow:dialog:SaturateOnIntegerOverflow' id], varargin{:});
