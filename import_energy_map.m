function planes = import_energy_map(fn)
%
% function planes = import_energy_map(fn)
%
% import energy map exported from WinCasino v3. 
% To export the data: Select "Energy Scan" in the tree view
% and then click "Edit->Export Data"
%

fid = fopen(fn,"rt");

header=1;
planeHeader = 2;
lineDef = 3;
state=header;
lineno=0;

planes={};
while ~feof(fid)
    s = fgetl(fid);
    lineno=lineno+1;
    if mod(lineno,1000)==0
        fprintf("Reading line %d ...\r", lineno);
    end
    
    while ~isempty(s)
        switch state
            case header
                plane = parse_planeId(s);
                if ~isempty(plane)
                    state = planeHeader;
                end
                s=[];
            case planeHeader
                xx = parse_ph(s);
                if ~isempty(xx)
                    state = lineDef;
                    s=[];
                    yy=[];
                    map = [];
                else
                    return;
                end
            case lineDef
                [row, line] = parse_lineDef(s);
                if ~isempty(row)
                    yy=[yy; row];
                    map=[map; line];
                    s=[];
                else
                    planes=[planes struct('plane', plane, 'xx', xx', 'yy', yy, 'map', map)];
                    state = header;
                end
        end
    end
end

fclose(fid);

% convert to strct array
ps = [];
for i1=1:length(planes)
    pss = struct("pid", string(planes{i1}.plane.planeid), "pos", str2double(planes{i1}.plane.pos), ...
        "planeno", str2double(planes{i1}.plane.planeno), "xx", planes{i1}.xx(1:end-1), ...
        "yy", planes{i1}.yy, "map", planes{i1}.map);
    ps=[ps pss];
end
planes = ps;
end

function p = parse_planeId(s)
p = regexp(s, "(?<planeid>\w+) plane (?<planeno>\d+)\s+. Position:\s*(?<pos>[\-0-9\.eE]+).*", 'names');
end

function xx = parse_ph(s)
c=strsplit(s,'nm');
xx = str2double(c);
if ~isfinite(xx(1))
    xx=[];
end
end

function [row, line] = parse_lineDef(s)
a=extractBefore(s,"nm");
row = str2double(a);
if ~isfinite(row)
    row = [];
    line=[];
else
    b = extractAfter(s,"nm");
    line = sscanf(b,"%f")';
end
end
