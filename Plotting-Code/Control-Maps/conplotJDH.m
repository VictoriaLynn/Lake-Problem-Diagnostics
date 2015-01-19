function [] = conplotJDH(algorithm, problem, metric, index, plotXTicks, plotYTicks)
%specify name of file to be read.  
name = sprintf('%s_%s.average', algorithm, problem);
%specify directory in which file resides.
work = sprintf('../SOW4/metrics/average_replace_NaNs/'); %getenv('WORK');

metricNames = { ...
    'Hypervolume', ...
    'Generational Distance', ...
    'Inverse Generational Distance', ...
    'Spacing', ...
    'Epsilon Indicator', ...
    'Maximum Pareto Front Error', ...
    'Runtime'};

%Include value of Hypervolume for best known approximation to the Pareto 
%front on the given problem.
if(strcmp(problem,'HBV'))
    refSetHV = 0.44752865117546625; %0.517;
elseif(strcmp(problem,'LTM'))
    refSetHV = 0.784;
elseif(strcmp(problem,'LRGV'))
    refSetHV = 0.327;
elseif(strcmp(problem,'myLake4ObjStoch'))
    refSetHV = 0.8635;
end

%Open parameter file for algorithm
fid = fopen(strcat('../', algorithm, '_params.txt'), 'r');
settings = textscan(fid, '%s %f %f');
fclose(fid);

%Open file containing Latin Hypercube Sample values for the parameters
%of the given algorithm
parameters = load(strcat('../', algorithm, '_Latin'), '-ascii');
%load metrics files
metrics = load(strcat(work, name), '-ascii');

%Divide first column of metrics file (Hypervolume) by the reference set
%Hypervolume to normalize it.
metrics(:,1) = metrics(:,1)/refSetHV;
            
%This loop deals with areas where the algorithm failed to find feasible
%solutions.  To read the files in, I had replaced NaNs with 9999.  This is
%now replaced with the worst value for each of the metrics where a low
%value is preferrred. This does not impact hypervolume as those values
%ranged from 0 to 1 since a higher value is preferred.
for i = 1:length(metrics(:,1))
    for j = 1:length(metrics(1,:))
        if (metrics(i,j) == 9999)
            metrics(i,j) =  max(metrics(:,j));
        end
    end
end

steps = 5;
% if(strcmp(problem,'LRGV'))
%     steps = 3;
% end

% compute average of points within each grid
sum = zeros(steps+1, steps+1);
count = zeros(steps+1, steps+1);
entries = min(size(parameters, 1), size(metrics, 1));

for i=1:entries
    index1 = round(steps * (parameters(i, index(1)) - settings{2}(index(1))) / (settings{3}(index(1)) - settings{2}(index(1)))) + 1;
    index2 = round(steps * (parameters(i, index(2)) - settings{2}(index(2))) / (settings{3}(index(2)) - settings{2}(index(2)))) + 1;
    sum(index1, index2) = sum(index1, index2) + metrics(i, metric);
    count(index1, index2) = count(index1, index2) + 1;
end

Z = zeros(steps+1, steps+1);
for i=1:steps+1
    for j=1:steps+1
        if (count(i, j) > 0)
            Z(i, j) = sum(i, j) / count(i, j);
        end
    end
end
Z = Z';

X = zeros(1, steps+1);
Y = zeros(1, steps+1);
for i=1:steps+1
    X(1, i) = (settings{3}(index(1)) - settings{2}(index(1)))*((i-1)/steps) + settings{2}(index(1));
    Y(1, i) = (settings{3}(index(2)) - settings{2}(index(2)))*((i-1)/steps) + settings{2}(index(2));
end

% generate contour plot
hold on;
    
[C, h] = contourf(X, Y, Z, 50);
% scatter(parameters(:,index(1)),parameters(:,index(2)),60,metrics(:,metric), 'filled');
set(h, 'LineColor', 'none');

% adjust colormap so that blue indicates best and values are normalized
cmap = colormap('jet');
minM = 0;
maxM = max(metrics(:, metric));

%Adjust colormap for Hypervolume with the continued designation that blue
% is better.
if(metric == 1)
    caxis([0 1]);
%     if(strcmp(problem,'LRGV'))
%         caxis([0 0.2]);
%     end
    cmap = flipud(cmap);
    colormap(cmap);
else
    caxis([0 1]);
   colormap(cmap);
end
%colorbar;
colorbar('YTick',0:0.2:1);

% if Z is constant, contourf fails to render; fill background with Z's value
if (isempty(C))
    cindex = round((size(cmap, 1)-1) * (Z(1, 1) - minM) / (maxM - minM))+1;
    set(gca, 'Color', cmap(cindex, :));
    set(gcf, 'InvertHardCopy', 'off');
end


%set(gcf, 'PaperPositionMode', 'auto');
set(gca, 'XTick', [100 500 1000]);

if(strcmp(problem,'HBV'))
    set(gca, 'YTick', [100000 200000]);
elseif(strcmp(problem,'LRGV') || strcmp(problem,'LTM'))
    set(gca, 'YTick', [50000 100000]);
end

if(~plotXTicks)
    set(gca, 'XTickLabel', []);
end

if(~plotYTicks)
    set(gca, 'YTickLabel', []);
end
% set(gca, 'XTickLabel', 0:500:1000);
% set(gca, 'YTickLabel', 0:100000:200000);
%Label each map with Algorithm name
title([algorithm], 'FontName', 'Arial', 'FontSize', 14);

set(gca, 'FontName', 'Arial', 'FontSize', 14);

end