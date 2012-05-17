function tipText = maketip(h,varargin)

% Copyright 2004 The MathWorks, Inc.

%% Maketip must return an empty string so that the @LocalTipFcn in
%% @dataview/addtip will use the maketip method of the characteristic view
%% to create the characteristic tip.

tipText = '';