function this = SrcSLEvent(varargin)
% SRCSLEVENT constructor
%
% Used as a scope data source for blocks in Simulink models that throw events.
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:51 $

this = checkpack.SrcSLEvent;
this.initSource(varargin{:});
end
