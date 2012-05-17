function addfilter(hFVT, varargin)
%ADDFILTER Add a filter to FVTool
%   ADDFILTER(hFVT, NUM, DEN) Add a DF2T filter to FDATool specified by a
%   numerator NUM and a denominator DEN.
%
%   ADDFILTER(hFVT, NUM) Add a DF2T filter to FDATool specified by the
%   numerator NUM.
%
%   ADDFILTER(hFVT, FILTOBJ) Add a filter to FDATool specified by the filter
%   object FILTOBJ.
%
%   See also SETFILTER.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/12/14 15:18:46 $ 

error(nargchk(2,3,nargin,'struct'))

oldfilt = hFVT.Filters;
newfilt = hFVT.findfilters(varargin{:});

newfilt = [oldfilt(:); newfilt(:)];
hFVT.setfilter(newfilt);

% [EOF]
