function this = InferenceReport(varargin)
% code - emlcoder.InferenceReport class constructor.

% Copyright 2003-2009 The MathWorks, Inc.

% Instantiate class
this = emlcoder.InferenceReport();
this.DocumentTitle = '';
if nargin > 0
    this.Document = varargin{1};
    if nargin > 1
        this.DocumentTitle = varargin{2};
    end
end

