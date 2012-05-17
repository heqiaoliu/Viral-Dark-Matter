function [Q,R,S,E,Flags,OldSyntax] = arecheckin(Type,A,B,Q,varargin)
% Checks input arguments to CARE and DARE.
% Type is the command ('are','dare') that is using this function so that 
% error messages can refer to the command 

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2008/01/15 18:47:20 $

% Flags
isFlag = cellfun('isclass',varargin,'char');
Flags = varargin(:,isFlag);
OldSyntax = strncmpi(Flags,'i',1);
Flags(OldSyntax) = {'factor'};
OldSyntax = any(OldSyntax);

% Extra numeric arguments
[n,m] = size(B);
varargin = varargin(~isFlag);
ni = length(varargin);
if ni<1 || isempty(varargin{1})
   R = eye(m);
else
   R = varargin{1};
end
if ni<2 || isempty(varargin{2})
   S = zeros(n,m);
else
   S = varargin{2};
end
if ni<3 || isempty(varargin{3})
   E = eye(n);
else
   E = varargin{3};
end

% Size of A,E,B,S
if any(size(A)~=n)
    ctrlMsgUtils.error('Control:foundation:ARE03',sprintf('%s(A,B,Q,...)',Type))
elseif any(size(E)~=n),
    ctrlMsgUtils.error('Control:foundation:ARE01',sprintf('%s(A,B,Q,R,S,E)',Type),'E','A')
elseif any(size(S)~=[n m]),
    ctrlMsgUtils.error('Control:foundation:ARE01',sprintf('%s(A,B,Q,R,S,...)',Type),'S','B')
end

% Check that Q and R are the correct size and symmetric
if any(size(Q) ~= n),
    ctrlMsgUtils.error('Control:foundation:ARE01',sprintf('%s(A,B,Q,...)',Type),'A','Q')
elseif norm(Q-Q',1) > 100*eps*norm(Q,1),
    ctrlMsgUtils.error('Control:foundation:ARE02',sprintf('%s(A,B,Q,...)',Type),'Q')
else
   Q = (Q+Q')/2;
end

if any(size(R) ~= m),
   ctrlMsgUtils.error('Control:foundation:ARE04',sprintf('%s(A,B,Q,R,...)',Type))
elseif norm(R-R',1) > 100*eps*norm(R,1),
    ctrlMsgUtils.error('Control:foundation:ARE02',sprintf('%s(A,B,Q,R,...)',Type),'R')
else
   R = (R+R')/2;
end
