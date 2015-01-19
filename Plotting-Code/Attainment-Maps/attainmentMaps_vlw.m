clc;
clear all;

%Victoria Lynn Ward
% vlw27@cornell.edu
% Cornell University
%Visualize Lake Problem outputs
%Adapted from code written by others for Reed et al. 2013

%Specify values to use in loops for evaluating all analysis files
algorithms = {'Borg'; 'GDE3'; 'MOEAD'; 'eMOEA'; 'eNSGAII'; 'NSGAII';};%List algorithms
percentiles = (1:1:100);%percentiles for which attainment was calculated
metrics = {'GenDist'; 'EpsInd'; 'Hypervolume';}; %metrics I calculated using MOEAFramework
problem = 'LakeProblem';


%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Maps of attainment probability
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

attainH = figure('Position',[100, 100, 1800, 1000]);


%%
threshold       = zeros(length(percentiles),length(algorithms),length(metrics));
best            = zeros(length(percentiles),length(algorithms),length(metrics));
attainment      = zeros(length(percentiles),length(algorithms),length(metrics));
controllability = zeros(length(percentiles),length(algorithms),length(metrics));
efficiency      = zeros(length(percentiles),length(algorithms),length(metrics));

%Loop through metrics
for i=1:length(metrics)
    %Loop through algorithms
    for j=1:length(algorithms)
        %Loop through percentiles
        for k=1:length(percentiles)
            
            %open and read files
            
            %specify file name.  Mine were in a directory called 
            %./local_ref_metrics/ in this case
            filename = ['./local_ref_metrics/' metrics{i} '_' num2str(percentiles(k)) '_' algorithms{j} '.txt']; 
            fh = fopen(filename);
            if(fh == -1) disp('Error opening analysisFile!'); end
            values = textscan(fh, '%*s %f', 5, 'Headerlines',1);
            fclose(fh);
            
            values = values{1};
            
            threshold(k,j,i)       = values(1);
            best(k,j,i)            = values(2);
            %correct the "best values for the hypervolume metric to be
            %normalized
            if strcmp(metrics{i},'Hypervolume'); best(k,j,i)   = best(k,j,i)/(threshold(k,j,i)/(percentiles(k)/100)); end;
            attainment(k,j,i)      = values(3);
            controllability(k,j,i) = values(4);
            efficiency(k,j,i)      = values(5);    
    
        end
    end
end

figure(attainH);
% adjust colormap so that red indicates best and values are normalized
cmap = colormap(jet(128));
cmap = flipud(cmap);
colormap(cmap);

for i=1:length(metrics)
    
    subplot(1,3,i);
    hold on;
    caxis([0.0 1.0]);
    colorbar;
    gridX = [0.5:1:5.5];
    gridY = [0:1:length(percentiles)]; 
     
    imagesc(gridX, gridY, attainment(:,:,i));
    scatter([0.5:5.5],best(1,:,i).*100,90,'ok','MarkerFaceColor','k');
    
    if strcmp(metrics{i},'Hypervolume'); title([problem ': Hypervolume Attainment']); end;
    if strcmp(metrics{i},'GenDist'); title([problem ': Generational Distance Attainment']); end;
    if strcmp(metrics{i},'EpsInd'); title([problem ': Additive e-Indicator Attainment']); end;
    
    ylabel('% of Best Metric Value');
    set(gca,'YTick',[1, 10:10:100]);
    set(gca,'YTickLabel','0|10|20|30|40|50|60|70|80|90|100');
    set(gca,'XTick',[0.5:1:5.5]);
    set(gca,'XTickLabel',['Borg|GDE3|MOEAD|eMOEA|eNSGAII|NSGAII']);
    xlim([0 6]);
    ylim([1 100]);
    rotateticklabel(gca,-90);
    
    box on;
    grid on;
    


end


