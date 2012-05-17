function this = flattopwin(n, sflag)
%FLATTOPWIN Construct a Flat Top window object
%   H = SIGWIN.FLATTOPWIN(N, S) constructs a Flat Top window object with length N
%   and sampling flag S.  If N or S is not specified, they default to 64 and
%   'symmetric' respectively.  The sampling flag can also be 'periodic'.
%
%   See also SIGWIN.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.2.4.7 $  $Date: 2009/05/23 08:15:46 $

this = sigwin.flattopwin;
this.Name = 'Flat Top';

if nargin > 0, this.Length       = n;     end
if nargin > 1, this.SamplingFlag = sflag; end

% [EOF]
