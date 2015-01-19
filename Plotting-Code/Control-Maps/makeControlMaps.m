clc;
clear all;

%AWR CONTROL MAPS
%JDH - August 2011
%revised by VLW August 2014 for Lake Problem Diagnostics

algorithms = {'Borg'; 'GDE3'; 'MOEAD'; 'eMOEA'; 'eNSGAII'; 'NSGAII'};

%~~~~~~~~~~~~~~~~~~~~~~~~~
%Below here is stuff to make control maps (right now, 6 subplots)
%Requires Jon's conplotJDH.m function
%~~~~~~~~~~~~~~~~~~~~~~~~~

set(0,'units','pixels');
scrnsize=get(0,'ScreenSize');
pos=[scrnsize(4)*0.02, scrnsize(3)*0.02, scrnsize(3)*.99, scrnsize(4)*.90];
fig = figure('Position',pos); 

spx = 0.06;     % space between plots in x
spy = 0.08;    % space between plots in y
pbase = 0.021;   % x location of first column of subplots
pbasey = 0.72; %y location of top row of subplots
pw = 0.175;      % width of subplot
ph = 0.21;      % height of subplots

for i=1:1:length(algorithms)
    
    nfe = 1;
    popsize = 2;
    metric = 1;
    
    %plotYTicks on only the leftmost plots
    if(i==1 || i==4)
        plotYTicks = 1;
    else
        plotYTicks = 0;
    end
    %plotXTicks on only the bottom plots
    if(i == 4 || i == 5 || i ==6)
        plotXTicks = 1;
    else
        plotXTicks = 0;
    end
    
    %Specify the location of the current algorithm's plot
    h = subplot(2,3,i);
    %Call ConplotJDH function
    conplotJDH(algorithms{i},'myLake4ObjStoch',metric,[popsize, nfe], plotXTicks, plotYTicks); %make control map
    
    if(i <= 3)
       set(h,'Position',[pbase+(i-1)*(pw+spx) pbasey pw ph]);
    else
       set(h,'Position',[pbase+(i-4)*(pw+spx) (pbasey-(ph+spy)) pw ph]);
    end
    
end
% 
% conplot('NSGAII', 'ZDT1', 2, [1, 2])
% where the first two arguments are the algorithm and problem name, the metric,
% and the indices of the two parameters you want to plot.
% metric 1 = hypervolume
% metric 5 = epsilon indicator; [1, 2] is usually population and NFE
% but it's [1, 3] for IBEA, SPEA2, and OMOPSO

