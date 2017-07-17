%% Read a neurofield output file and return a neurofield output struct.
%
% ARGUMENTS:
%        fname -- .
%        himem -- himem = 1 uses slower method that can avoid out of memory errors in some cases
%
% OUTPUT:
%        obj -- .
%
% REQUIRES:
%           -- <description>
%           -- <description>
%
% REFERENCES:
%
% AUTHOR:
%     Romesh Abeysuriya (2012-03-22).
%
% USAGE:
%{
    %
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = read(fname, himem)
    %
    if nargin < 2 || isempty(himem)
        himem = 0;
    end

    if ~exist(fname, 'file')
        fname = [fname, '.output'];
    end
    
    % if himem
    %     nrows = count_lines(fname) - 2;
    % end

    fid = fopen(fname, 'r'); % Open file for read access

    % Skip through to the start of the output
    buffer = fgetl(fid);
    while isempty(strfind(buffer, '======================='))
        if ~isempty(strfind(buffer, 'Time  |'))
            error('Did you try and open and old-style output file? Found a | that looked like a delimiter')
        end
        buffer = fgetl(fid);
    end
    fgetl(fid);

    headers = fgetl(fid);
    nodes = fgetl(fid);

    obj.fields = strsplit(headers);
    obj.fields = obj.fields(2:end-1);

    [obj.nodes, base_index] = get_nodes(nodes, obj.fields);

    % if himem
    %     data = zeros(nrows, sum(cellfun(@length, obj.nodes)));
    %     for j = 1:nrows
    %         tmp = textscan(fid, '%f', 1, 'CollectOutput', true);
    %         data(j, :) = tmp{1};
    %     end
    % else
    data = textscan(fid, '%f', 'CollectOutput', true);
    data = reshape(data{1}, length(obj.fields), []).';
    %end

    for j = 1:length(obj.nodes)
        obj.data{j} = data(:, base_index{j});
    end

    % idx_start = 1;
    % for j = 1:length(obj.nodes) % For each output trace
    %     obj.data{j} = data(:, idx_start:idx_start+length(obj.nodes{j})-1);
    %     idx_start = idx_start + length(obj.nodes{j});
    % end    
    fclose(fid);

    % Finally, move the time to an array of its own
    obj.time = obj.data{1};
    obj.data = obj.data(2:end);
    obj.fields = unique(obj.fields(2:end), 'stable');
    obj.nodes = obj.nodes(2:end);

    obj.deltat = obj.time(2) - obj.time(1);
    obj.npoints = length(obj.time);
end %function read()


function [locs, base_index] = get_nodes(line, headers)
    % Given a line with contents like '1 | 1 2 | 1 |
    % return a number of nodes {1,1:2,1}
    % nentries stores the number of entries per line
    nodes = cellfun(@(x) str2double(x), strsplit(line(1:end-2)));
    nodes(1) = 1; % Number of time columns (there is only ever one)
    traces = unique(headers, 'stable');
    locs = cell(1,length(traces));
    base_index = locs;
    for j = 1:length(traces)
        base_index{j} = strcmp(traces{j}, headers);
        locs{j} = nodes(base_index{j});
    end
end %function get_nodes()

% function numlines = count_lines(fname)
%     if (isunix) %# Linux, mac
%         [status, result] = system( ['wc -l ',fname,' | cut -d'' '' -f1'] );
%         numlines = str2num(result);

%     elseif (ispc) %# Windows
%         numlines = str2num( perl('countlines.pl',fname) );

%     else
%         error('...');

%     end
%end %function count_lines()
