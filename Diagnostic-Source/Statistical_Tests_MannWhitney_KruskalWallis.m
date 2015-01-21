%Victoria Lynn Ward
% Cornell University
% vlw27@cornell.edu
% August 2014

%This code is developed as a post-processing script for the metrics for
%each parameterization associated with a comparative study using the
%MOEAFramework.  Currently, it employs the Kruskal-Wallis test to determine
%if there are statistical differences in the performance of each algorithm
%on a given metric.

clc; clear all; close all;

algorithms = {'Borg', 'eMOEA', 'eNSGAII', 'NSGAII', 'MOEAD', 'GDE3'};
seeds = (1:1:50);
metrics = {'GenDist'; 'EpsInd'; 'Hypervolume';};
% work = sprintf('./SOW6_local_ref/'); %getenv('WORK');
problem = 'MyLake4ObjStoch';

%Loop through metrics
for i=1:length(metrics)
    %Loop through algorithms
    for j=1:length(algorithms)
        %Loop through seeds
        for k=1:length(seeds)
         %open and read files
            filename = ['./' metrics{i} '_' num2str(75) '_' algorithms{j} '_' num2str(seeds(k)) '.txt'];
            fh = fopen(filename);
            if(fh == -1) disp('Error opening analysisFile!'); end
            values = textscan(fh, '%*s %f', 5, 'Headerlines',1);
            fclose(fh);
            
            values = values{1};
            
            threshold(k,j,i)       = values(1);
            best(k,j,i)            = values(2);
            if strcmp(metrics{i},'Hypervolume'); best(k,j,i)   = best(k,j,i)/(threshold(k,j,i)/(75/100)); end;
            attainment(k,j,i)      = values(3);
            controllability(k,j,i) = values(4);
            efficiency(k,j,i)      = values(5);   
        end
            
    end
    
end

%Perform kruskalwallis nonparameteric test for differences in performance
%among all six algorithms on best and attainment 

P = zeros(2,length(metrics));

%Loop through metrics
for i = 1:length(metrics)
    
   P(1,i) = kruskalwallis(attainment(:,:,i),algorithms,'off');
   P(2,i) = kruskalwallis(best(:,:,i),algorithms,'off');

end


 Mann_Whitney_U_GD = zeros(length(algorithms),length(algorithms));
 Mann_Whitney_U_AEI = zeros(length(algorithms),length(algorithms));
 Mann_Whitney_U_Hyp = zeros(length(algorithms),length(algorithms));
 
for i = 1:length(algorithms)
    for j = 1:length(algorithms)
    [P1, Mann_Whitney_U_GD(i,j)] = ranksum(attainment(:,i,1),...
                                     attainment(:,j,1),...
                                  'alpha', 0.05, 'tail', 'right');
    [P2, Mann_Whitney_U_AEI(i,j)] = ranksum(attainment(:,i,2),...
                                     attainment(:,j,2),...
                                  'alpha', 0.05, 'tail', 'right');                          
    [P3, Mann_Whitney_U_Hyp(i,j)] = ranksum(attainment(:,i,3),...
                                     attainment(:,j,3),...
                                  'alpha', 0.05, 'tail', 'right');                          
    end

end

% xlswrite('test.xlsx',Mann_Whitney_U_results,3);

