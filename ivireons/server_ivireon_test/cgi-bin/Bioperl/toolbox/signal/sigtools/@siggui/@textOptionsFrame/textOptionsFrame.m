function h = textOptionsFrame(varargin)
%TESTOPTIONSFRAME  constructor for the TEXTOPTIONSFRAME
%   H = TEXTOPTIONSFRAME(TEXT, NAME)
%   TEXT    -   The text to set as a default
%   NAME    -   The name for the 

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:10:27 $

% Since the construcotr needs to be callable from sub-classes, actual constructor code is in another methods
% however builtin constructor is called here
h = siggui.textOptionsFrame;

% Inputs handled in duplicated constructor
construct_tOF(h, varargin{:});

% [EOF]

