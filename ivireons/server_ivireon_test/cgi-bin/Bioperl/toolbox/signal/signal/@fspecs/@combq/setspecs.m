function setspecs(this, varargin)
%SETSPECS   Set the specifications

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:53 $

if nargin>1
    %combtype was prevously added in fdesign as the last argument of
    %varargin. Set CombType and delete it before setting the rest of the
    %specs
    this.CombType = varargin{end};
    varargin(end) = [];
    if ~isempty(varargin)
        if varargin{1} < 2
            error(generatemsgid('invalidFilterOrderForNQSpecs'), ...
                ['Filter order must be greater than one when using ''N,Q''',...
                ' specification ']);
        end
    end    
end
aswfs_setspecs(this,varargin{:});

% [EOF]
