function next = interstg(hTar, S1, S2, order)
%INTERSTG Interconnect adjacent stages of filter structures.
%   INTERSTG(SYS, S1, S2) forms the connections between two
%   adjacent filter stages in system SYS by adding lines between
%   the Simulink paths indicated in cell arrays S1 and S2.  SYS
%   is the Simulink system name, and is a non-empty string.
%
%   Interconnections require specification of the Simulink paths
%   to both the "source" and "sink" ports.  Paths are stored in
%   individual cells of S1 and S2, where the i'th cell in S1
%   describes the connections to the i'th cell in S2.  Additional
%   entries in the cell vectors describe additional interconnections.
%   Only those paths stored in the first row of the cell array
%   are employed; any additional rows are ignored.  Both S1 and
%   S2 must have the same number of cells entries.
%
%   For example, if SYS='MyModel', S1={'Gain1/1','Sum1/1'},
%   and S2={'Sum2/1','Sum2/2'}, then INTERSTG(SYS,S1,S2) connects
%   port 1 of Gain1 to port 1 of Sum2, and port 1 of Sum1 to
%   port 2 of Sum2.
%
%   NEXT = INTERSTG(...) returns the ...
%
%   INTERSTG(SYS,S1,S2,ORDER) allows specification of the direction
%   of interconnection.  By default, S1 represents the source and S2
%   the sink of every interconnection.  ORDER is a vector with the same
%   number of entries as rows in S1 and S2, and specifies the inter-
%   connection direction according to the following table:
%          ORDER SOURCE SINK
%            12    S1    S2   '->'
%            21    S2    S1   '<-'
%   For example, suppose S1 and S2 contain 3 cells each.  The first
%   two interconnections are from S1 to S2, and the third from S2
%   to S1.  In this case, ORDER=[12 12 21].
%
%   Multiple sink destinations may be specified by entering a cell
%   array vector containing multiple destination strings, in place
%   of a single string for the destination.
%
%   There are several special interconnection actions that may be
%   specified in S1 or S2, in place of the usual Simulink paths strings.
%
%   *  An empty string indicates that no connection is to be made.
%      Note that either the sink or the source or both entries may
%      be left empty; in each case, no interconnection is made.
%
%   *  'feedthru' indicates that the connection simply passes through
%      this stage, and that the interconnection should be postponed.
%      This information is passed back to the caller in NEXT for use
%      during the next call the INTERSTG.  This option may only appear
%      in S2.  Currently, if feedthru is specified, it must be the ONLY
%      entry specified in the sink cell-entry.
%
%   *  a numeric entry in S1 or S2 indicates a "short" to be placed
%      across entries in S2 or S1, respectively.  For example, if S2(i)=j,
%      then a connection from S1(i) to S1(j) is to be made.  In this
%      case, S1(j) itself may specify multiple sinks which will all be
%      connected to S1(i).  Shorting to a feedthru is supported.  Currently,
%      multiple shorting indices are NOT supported.

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:39 $

sys = hTar.system;

error(nargchk(3,4,nargin,'struct'));
if isempty(sys) | ~isstr(sys),
  error(generatemsgid('MustBeAString'),'SYS must be a path string.');
end
if ~isequal(size(S1,2),size(S2,2)) | ~iscell(S1) | ~iscell(S2),
  error(generatemsgid('InvalidDimensions'),'S1 and S2 must be identically sized cell arrays.');
end

% Number of columns = number of connections:
num_conns = size(S1,2);

if nargin<4,
  % Default connection order: S1->S2 for all connections
  order = 12*ones(1,num_conns);
else
  % Check entries in ORDER:
  %   - entries must be either 12 or 21
  %   - order must be a vector with num_conns entries
  if length(order)~=num_conns,
    error(generatemsgid('InvalidDimensions'),['ORDER must be a vector with length equal ' ...
           'to the number of rows in S1 and S2.']);
  end
  i = find(order==12 | order==21);
  if ~isequal(length(i),length(order)),
    error(generatemsgid('GUIErr'),'All direction entries in ORDER must be 12 or 21.');
  end
end

% Initialize return connection list for next invocation:
next = S2;

% Loop over all connections:
for i = 1:num_conns,

  % Make the connection only if the current entries in both
  %   the source or sink lists are not empty:
  if ~isempty(S1{1,i}) & ~isempty(S2{1,i}),

    % Do special cases first:
    if ischar(S1{1,i}) & strcmp(S1{1,i},'feedthru'),
      % Disregard this case

    elseif ischar(S2{1,i}) & strcmp(S2{1,i},'feedthru'),
      % Feedthru condition:
      next{2,i} = S1{1,i};

    else
      % Form general connections

      % Determine connection direction, and copy appropriate list:
      if order(i)==21,
        % Connect from S2 (source) -> S1 (sinks):
        Ssrc=S2; Ssnk=S1;
      else
        % Connect from S1 (source) -> S2 (sinks):
        Ssrc=S1; Ssnk=S2;
      end

      % Except for shorts, multiple connections can only be specified
      % in the sinks array, i.e., Ssnk may contain multiple connections,
      % but not Ssrc.
      sink_list = Ssnk{1,i};       % Get sink connection list
      if ~iscell(sink_list),
        sink_list = {sink_list};   % sink_list must be a cell array
      end

      for j = 1:length(sink_list), % Loop over all sinks for this connection
        curr_sink = sink_list{j};  % Get current sink
        
        if isempty(curr_sink),
           % safeguard a feedthru for multiple-sink case
           
        elseif isnumeric(curr_sink),
          % Shorting wire specified in curr_sink - place a short from
          %   Ssrc(1,i) to Ssrc(curr_sink).  Note that multiple sink
          %   entries may appear in Ssrc(curr_sink).  Also, note that
          %   Ssrc(curr_sink) should be a sink, otherwise an error
          %   will occur.
          %
          %   To verify this, ORDER(i) should be opposite (not equal) to
          %   ORDER(curr_sink), which implies in particular that curr_sink
          %   should never be equal to i (i.e., we cannot connect Ssrc(1,i)
          %   to itself!).
          if any(order(i) == order(curr_sink)),
            error(generatemsgid('GUIErr'),'Cannot short a source to another source.');
          end

          % NOTE: curr_sink is the short-index (possibly multiple indices):

          % Here is where multiple-short indices are not handled properly.
          % We need to concatenate into a single cell-vector all the
          % contents of Ssrc(1,curr_sink) for curr_sink=vector of indices.
          % The contents of each Ssrc{1,curr_sink(m)} may or may not be
          % a cell itself, making this more tiresome.
          %
          if length(curr_sink)>1,
            error(generatemsgid('NotSupported'),'Multiple short indices are not currently supported.');
          end

          % Could this just be a recursion?
          % next=interstg(sys,Ssrc(1,curr_sink),Ssnk(1,short_sink),order);

          short_list = Ssrc{1,curr_sink};  % Get sinks for shorting
          if ~iscell(short_list),
            short_list = {short_list};   % short_list must be a cell array
          end
          for k = 1:length(short_list),  % Loop over sinks to short to
            short_sink = short_list{k};
            if ~isempty(short_sink),     % Respect empty sink status
              if strcmp(short_sink,'feedthru'),
                % Feedthru condition on the short:
                next{2,curr_sink} = Ssrc{1,i};
              elseif isnumeric(short_sink),
                % Short the short, but no more recursions after this!
                add_line(sys, Ssrc{1,i}, Ssnk{1,short_sink},'autorouting','on');
              else
                add_line(sys, Ssrc{1,i}, short_sink,'autorouting','on');
              end % short-feedthru
            end % short-empty exception
          end % short list

        else
           % Normal connection between source and curr_sink:
           
           if isnumeric(Ssrc{1,i}),
              error(generatemsgid('InternalError'),['Unhandled short-circuit interconnection - ' ...
                     'diagram will be missing one or more wires.']);
           end
           
          add_line(sys, Ssrc{1,i}, curr_sink,'autorouting','on');

        end % isnumeric(curr_sink)

      end  % loop over all sinks for this connection
    end % special connection specifiers
  end % empty connection specifier
end % loop over connection number

% end of interstg.m
