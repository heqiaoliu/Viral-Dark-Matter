function g = get(this,varargin)
% GET function.
% Calling syntax:
%   GET(OP) -> get a struct of operating point specification object's
%              properties. 
%   GET(OP, 'Input') -> get struct representing 'Input' property of object.
%   GET(OP, 'Output')-> get struct representing 'Output' property of object.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:52:25 $

ni = nargin;

error(nargchk(1,2,ni,'struct'))

if ni==1
    g = struct('Input',this.Input,'Output',this.Output);
else
    v =  varargin{1};
    if strncmpi(v,'Input',length(v))
        g = this.Input;
    elseif strncmpi(v,'Output',length(v))
        g = this.Output;
    else
        ctrlMsgUtils.error('Ident:utility:nlarxhwspecGetCheck','idnlhwopspec/get')
    end
end
