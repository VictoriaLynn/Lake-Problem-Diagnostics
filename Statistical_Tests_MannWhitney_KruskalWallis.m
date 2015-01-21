%Victoria Lynn Ward
% Cornell University
% vlw27@cornell.edu
% August 2014

%This code is developed as a post-processing script for the metrics for
%each parameterization associated with a comparative study using the
%MOEAFramework.  Currently, it employs the Kruskal-Wallis test to determine
%if there are statistical differences in the performance of each algorithm
%on a given metric.

clc; clear all;

algorithms = {'Borg', 'eMOEA', 'eNSGAII', 'NSGAII', 'MOEAD', 'GDE3'};
work = sprintf('./SOW6_local_ref/'); %getenv('WORK');
problem = 'MyLake4ObjStoch';
        
for i = 1:length(algorithms)
    name = sprintf('%s_%s.localref.metrics', char(algorithms(i)), problem);
    results = load(strcat(work, name), '-ascii');
    Hypervolume(:,i) = results(:,1);
    Generational_Distance(:,i) = results(:,2);
    Additive_Epsilon_Indicator(:,i) = results(:,5);
    
end

[P,ANOVATAB,STATs] = kruskalwallis(Hypervolume,algorithms,'on');

Mann_Whitney_U_results = zeros(length(algorithms),length(algorithms));

for i = 1:length(algorithms)
    for j = 1:length(algorithms)
    Mann_Whitney_U_results(i,j) = ranksum(Hypervolume(:,i),Hypervolume(:,j),...
                                  'alpha', 0.05, 'tail', 'right');
    end

end

% xlswrite('test.xlsx',Mann_Whitney_U_results,3);

