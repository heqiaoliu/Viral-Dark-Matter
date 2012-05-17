function htmlOut = coveragerpt(dirname)
%COVERAGERPT  Audit a folder for profiler line coverage
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   COVERAGERPT checks which lines of which files have been executed by the
%   last generated profile.
%
%   COVERAGERPT(DIRNAME) scans the specified folder.
%
%   HTMLOUT = COVERAGERPT(...) returns the generated HTML text as a cell array
%
%   See also PROFILE, MLINT, DEPRPT, HELPRPT, CONTENTSRPT

% Copyright 1984-2010 The MathWorks, Inc.

reportName = sprintf('Profiler Coverage Report');

if nargout == 0
    internal.matlab.codetools.reports.displayLoadingMessage(reportName);
end

if nargin < 1
    dirname = cd;
end 

d = internal.matlab.codetools.reports.buildCoverageInfo(dirname);

%% Make the Header
help = sprintf('Run the Coverage Report after you run the Profiler to identify how much of a file ran when it was profiled ');
docPage = 'matlab_env_coverage_rpt';
rerunAction = sprintf('coveragerpt(''%s'')', dirname);
thisDirAction = 'coveragerpt';

% Now generate the HTML
s = internal.matlab.codetools.reports.makeReportHeader(reportName, help, docPage, rerunAction, thisDirAction);

s{end+1} = sprintf('Report for folder %s<p>', dirname);

% pixel gif location
pixelPath = ['file:///' fullfile(matlabroot,'toolbox','matlab','codetools','private')];
whitePixelGif = fullfile(pixelPath, 'one-pixel-white.gif');
bluePixelGif = fullfile(pixelPath, 'one-pixel.gif');

% Make sure there is something to show before you build the table
if numel(d) == 1 && isempty(d.name)
    s{end+1} = sprintf('No MATLAB code files in this folder<p>');
else
    [~, ndx] = sort([d.coverage]);
    d = d(fliplr(ndx));

    s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';
    % Loop over all the files in the structure
    for n = 1:length(d)
        if isempty(d(n).funlist)
            s{end+1} = sprintf('<tr><td valign="top" colspan="2" class="td-linetop"><a href="matlab: edit(urldecode(''%s''))"><span class="mono">%s</span></a></td></tr>', ...
                urlencode(fullfile(dirname, d(n).name)),d(n).name);
        else
            % First put a header on for the whole file
            s{end+1} = '<tr><td valign="top" class="td-linetop">';

            s{end+1} = sprintf('<a href="matlab: edit(urldecode(''%s''))"><span class="mono">%s</span></a></td>', ...
                urlencode(fullfile(dirname, d(n).name)), d(n).name);
            s{end+1} = '<td valign="top" class="td-linetopleft">';
            s{end+1} = '<div style="border:1px solid black; padding:2px; margin:4px; width: 100px;">';
            s{end+1} = sprintf('<img src="%s" width="%d" height="10" />', ...
                bluePixelGif, round(d(n).coverage));
            s{end+1} = sprintf('<img src="%s" width="%d" height="10" /></div>', ...
                whitePixelGif, round(100-d(n).coverage));

            if length(d(n).funlist) == 1

                s{end+1} = sprintf('<a href="matlab: profview(%d,profile(''info''))">Coverage</a>: %4.1f%%<br/>', ...
                    d(n).funlist(1).profindex, ...
                    d(n).funlist(1).coverage);
                s{end+1} = ['<span style="font-size:small;">' sprintf('Total time: %4.1f seconds', d(n).funlist(1).totaltime) '</span><br/>'];
                s{end+1} = ['<span style="font-size:small;">' sprintf('Total lines: %', d(n).funlist(1).runnablelines) '</span><br/>'];
                s{end+1} = '</td>';
                s{end+1} = '</tr>';

            else

                s{end+1} = ['<span style="font-size:small;">' sprintf('Total coverage: %4.1f %%', ...
                    d(n).coverage) '</span></td>'];
                s{end+1} = '</tr>';

                for m = 1:length(d(n).funlist)
                    s{end+1} = sprintf('<tr><td valign="top" class="td-dashtop">&nbsp;&nbsp;<a href="matlab: opentoline(''%s'',%d)"><span class="mono">%s</span></a></td>', ...
                        fullfile(dirname,d(n).name), d(n).funlist(m).firstline, d(n).funlist(m).name);

                    if d(n).funlist(m).coverage == 0
                        s{end+1} = '<td valign="top" class="td-dashtopleft"></td>';
                    else
                        s{end+1} = '<td valign="top" class="td-dashtopleft">';
                        s{end+1} = sprintf('<a href="matlab: profview(%d,profile(''info''))">Coverage</a>: %4.1f%%<br/>', ...
                            d(n).funlist(m).profindex, ...
                            d(n).funlist(m).coverage);
                        s{end+1} = ['<span style="font-size:small;">' sprintf('Total time: %4.1f seconds', d(n).funlist(m).totaltime) '</span><br/>'];
                        s{end+1} = ['<span style="font-size:small;">' sprintf('Total lines: %d', d(n).funlist(m).runnablelines) '</span><br/>'];
                        s{end+1} = '</td>';
                    end
                    s{end+1} = '</tr>';
                end
            end
            
        end
    end
    s{end+1} = '</table>';
end

s{end+1} = '</body></html>';

if nargout==0
    sOut = [s{:}];
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = s;
end
%#ok<*AGROW>
