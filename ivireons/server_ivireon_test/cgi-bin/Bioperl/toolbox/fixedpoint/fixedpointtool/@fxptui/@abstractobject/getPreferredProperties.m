function props = getPreferredProperties(h)
%GETPREFERREDPROPERTIES   Get the preferredProperties.

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 06:52:39 $

props = {...
    'Run',...
    'SimDT',...
    'SpecifiedDT'...
    'ProposedDT', ...
    'Accept',...
    'DesignMin', ...
    'SimMin',...
    'ProposedMin',...
    'DesignMax', ...
    'SimMax',...
    'ProposedMax',...
    'OvfWrap',...
    'OvfSat', ...
        };

% [EOF]
