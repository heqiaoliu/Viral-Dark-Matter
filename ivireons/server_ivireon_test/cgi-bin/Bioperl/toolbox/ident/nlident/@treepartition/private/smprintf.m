function smprintf(varargin)
%SMPRINTF: fprintf conditioned by the silient mode.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:09:08 $

% Author(s): Anatoli Iouditski

persistent SITB_SMPRINTF_TRACE

if nargin==1 && ischar(varargin{1})
    switch varargin{1}
        case 'displayon'
            SITB_SMPRINTF_TRACE = 1;
        case 'displayoff'
            SITB_SMPRINTF_TRACE = 0;
    end
end

if SITB_SMPRINTF_TRACE
    if strcmp(varargin{1},'displayon')
        if nargin>1
            fprintf(varargin{2:end});
        end
    else
        fprintf(varargin{:});
    end
end
