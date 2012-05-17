function [Hd index] = findfilters(hFVT, varargin)
%FINDFILTERS Finds filters in a variable number of inputs

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.7.4.5 $  $Date: 2009/07/27 20:32:12 $

% This should be a private method

% We want to make sure we dont get any  warnings.
w = warning('off');

Hd              = {};
b               = [];
index.object    = [];
index.objectwfs = [];

for indx = 1:length(varargin)
    
    % If the input is a filter, use it.
    if isa(varargin{indx}, 'dfilt.basefilter') || ...
           any(strcmp(class(varargin{indx}), {'dfilt.dfiltwfs'})),
        
        % If we have something in b, create the filter using it
        if ~isempty(b),
            Hd{end+1} = dfilt.dffir(b);
            b = [];
        end
        
        for jndx = 1:length(varargin{indx}),
            Hd{end + 1} = varargin{indx}(jndx);
            if isa(varargin{indx}(jndx), 'dfilt.dfiltwfs')
                index.objectwfs = [index.objectwfs length(Hd)];
            end
            index.object = [index.object length(Hd)];
        end
        
    elseif isnumeric(varargin{indx})
        
        % If the input is numeric it is either a num or a den
        if isempty(b),
            b = varargin{indx};
        else
            
            % If b is not empty the new input must be the den
            Hd{end+1} = dfilt.df2t(b, varargin{indx});
            b = [];
        end
    elseif ~isempty(b),
        
        % If we find something else and we have a num, it must be FIR
        Hd{end+1} = dfilt.dffir(b);
        b = [];
    end
end

% Use any stored b to create a dffir filter
if ~isempty(b),
    Hd{end+1} = dfilt.dffir(b);
end

for indx = 1:length(Hd),
    if ~isa(Hd{indx}, 'dfilt.dfiltwfs'),
        Hd{indx} = dfilt.dfiltwfs(Hd{indx});
    end
end

Hd = [Hd{:}];

warning(w);

% [EOF]
