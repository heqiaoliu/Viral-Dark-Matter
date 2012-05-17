function str = getInputTypeString(in)
%

% GETINPUTTYPESTRING return the string that has the input type name in a
% I18N friendly manner.

%  Author(s): Erman Korkut 24-Mar-2009
%  Revised: 
%   Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:18:40 $

if isa(in,'frest.Sinestream');
    str = ctrlMsgUtils.message('Slcontrol:frest:LabelSinestream');
elseif isa(in,'frest.Chirp')
    str = ctrlMsgUtils.message('Slcontrol:frest:LabelChirp');
elseif isa(in,'frest.Random')
    str = ctrlMsgUtils.message('Slcontrol:frest:LabelRandom');
else
    str = ctrlMsgUtils.message('Slcontrol:frest:LabelCustom');
end
