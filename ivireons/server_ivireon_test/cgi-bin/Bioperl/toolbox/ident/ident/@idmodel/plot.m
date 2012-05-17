function plot(varargin)
% IDMODEL/PLOT: The same as VIEW. 
% See help for idmodel/view.
%
% See also idmodel/view, idnlarx/plot, idnlhw/plot, idmodel/bode,
% idmodel/step, idmodel/nyquist, idmodel/impulse, idmodel/pzmap.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.5 $ $Date: 2008/10/02 18:48:20 $


if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:plots:cstbRequired')
end

view(varargin{:})
