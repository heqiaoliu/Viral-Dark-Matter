function s = sumblk(OutputNames,varargin)
%SUMBLK   Helps specify summing junctions in name-based interconnections.
%
%   S = SUMBLK(OUTPUT,INPUT1,...,INPUTN) returns the transfer function S 
%   for the summing junction OUTPUT = INPUT1 + ... + INPUTN.   The output
%   signal name(s) OUTPUT and input signal name(s) INPUT1,...,INPUTN are 
%   specified as strings for scalar-valued signals, and commensurate
%   cell arrays of strings for vector-valued signals. For example,
%      s = sumblk('u','u1','u2','u3')
%   specifies the summing junction u = u1 + u2 + u3, and
%      s = sumblk({'v1','v2'},{'u1','u2'},{'d1','d2'})
%   specifies the summing junction v = u + d where u,d,v are vector-valued
%   signals of length two. For MIMO systems, use STRSEQ to quickly
%   generate numbered channel names like {'e1';'e2';'e3'}. For example to
%   define e = r-y for vectors of length n, type
%      ej = strseq('e',1:n); %{'e1';'e2';...}
%      rj = strseq('r',1:n); %{'r1';'r2';...}
%      yj = strseq('y',1:n); 
%      s = sumblk(ej,rj,yj,'+-');
%
%   S = SUMBLK(OUTPUTNAME,INPUT1,...,INPUTN,SIGNS) further specifies a sign
%   for each input signal. For example
%      s = sumblk('e','r','y','+-')
%   specifies the relationship e = r - y.
%   
%   You can use SUMBLK in conjunction with CONNECT to quickly and reliably 
%   connect LTI models and derive aggregate models for block diagrams.
%
%   See also  STRSEQ, CONNECT, SERIES, PARALLEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/03/13 17:20:58 $
ni = nargin;

% Check output
if ischar(OutputNames)
   OutputNames = {OutputNames};
elseif ~iscellstr(OutputNames)
    ctrlMsgUtils.error('Control:combination:sumblk1')
end
nsig = numel(OutputNames);  % width of signal vector

% Look for sign input
Signs = varargin{ni-1};
if ischar(Signs) && all(Signs=='+' | Signs=='-')
   nu = ni-2;
   if numel(Signs)~=nu
       ctrlMsgUtils.error('Control:combination:sumblk2')
   end
   gain(1,Signs=='+') = 1;
   gain(1,Signs=='-') = -1;
else
   nu = ni-1;
   gain = ones(1,nu);
end
gain = kron(gain,eye(nsig)); % gain matrix

% Process inputs
if nu<2
   ctrlMsgUtils.error('Control:combination:sumblk3')
else
   for ct=1:nu
      Inct = varargin{ct};
      if ischar(Inct)
         Inct = {Inct};
      elseif ~iscellstr(Inct)
          ctrlMsgUtils.error('Control:combination:sumblk4')
      elseif length(Inct)~=nsig
          ctrlMsgUtils.error('Control:combination:sumblk5')
      end
      varargin{ct} = Inct(:);
   end
   InputNames = cat(1,varargin{1:nu});
end

% Construct transfer function
s = tf(gain,'InputName',InputNames,'OutputName',OutputNames);
