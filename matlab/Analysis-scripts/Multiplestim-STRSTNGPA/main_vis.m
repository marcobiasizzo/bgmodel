%% Date Created: 04.04.18 by M. Mohagheghi

% This script visualizes the results generated by main.m which contains the
% time when disinhibition happened and also the population average firing
% rate of all nuclei.
function [] = main_vis()
    
    base_ind = 2;
    adding_ind = 3:4;
    thre = 0.95;
    
    dir_name = '/home/mohaghegh-data/temp-storage/18-03-28-separatesims-sensoryinSTNGPA-rampinSTR/';
    Figdir   = fullfile(dir_name,'Figsold');
    fl_name = [dir_name,'all_proc_data18-03-28.mat'];
    if exist('procdata','var') ~= 1
        load(fl_name);
    end

    strstn = procdata{1,1};
    strstn.stim_param(:,[1,4]) = [];
    strstn.stim_param_ISI(:,[1,4]) = [];
    str = procdata{1,end};
    
    disp('Combining all related data in structure to one ...')
    strstngpa = struct_conc(procdata,base_ind,adding_ind);
    
    % All stimuli parameters
    disp('Separating all stimulus parameters ...')
    str_f = unique(strstngpa.stim_param(:,2));
    stn_f = unique(strstngpa.stim_param(:,3));
    gpa_f = unique(strstngpa.stim_param(:,1));
    relsg = unique(strstngpa.stim_param(:,4));
    relss = unique(strstngpa.stim_param(:,5));
    
    Ws = unique(strstngpa.nuclei_trials_ISI(:,3));
    
    numtrs = max(str.nuclei_trials_ISI(:,2));
    
    % Choosing which nucleus to process
    disp('Choosing which nucleus to process ...')
    ncs_sel = 'SN';
    ncs = {'FS','GA','GF','GI','M1','M2','SN','ST'};
%     ncs = str.nuclei.nc_names;
    nc_ind = find(strcmpi(ncs,ncs_sel));
    
    % Taking all relevant data to the nucleus
    
%     str = NOI_data(str,nc_ind);
%     strstn = NOI_data(strstn,nc_ind);
%     strstngpa = NOI_data(strstngpa,nc_ind);
    
    % Putting all stim parameters together
    
    all_stim_par = combvec(str_f',stn_f',gpa_f',relss',relsg');
    
    % Measuring delays
%     [delay_gpastn,delay_stn,diffdelay_stnvsgpa,...
%      off_str,off_stn] = trbytr_delay_measure(str,strstn,strstngpa);
 
    % Counting number of suppressed, delayed, advanced decrease
    disp('Processing delays, suppresses and ...')
    [spda_data,delays] = supp_prom_del_adv(str,strstn,strstngpa);
    
    % Decrease Failed Bar plot
    disp('Visualizing no suppression data ...')
    nodecinSN(spda_data.no_decrease,numtrs,Figdir)
    
    % Delays of averages
    disp('Computing the average delays NOT tr-by-tr')
    Avg_dels = delay_measure_average(str,strstn,strstngpa,all_stim_par,Ws);
    
    % Finding parameter combinations where GPA stimulation was
    % significantly effective (> 0.95)
    
    disp('Finding significant paramters with respect to delay ...')
    effective_params(spda_data.pos_delay_gpvsst,all_stim_par,Ws,numtrs,Figdir,thre,'EffcPosDelay-GPAvsSTN')
    
    disp('Finding significant paramters with respect to suppression ...')
    effective_params(spda_data.suppressed_gp_vs_st,all_stim_par,Ws,numtrs,Figdir,thre,'EffcSupp-GPAvsSTN')
    
    
    disp('Visualizing delays ...')
    disp('Positive delays for GPA & STN...')
    disp('Negative delays for GPA & STN...')
    
    for str_ind = 1:length(str_f)
        delayvis(spda_data.pos_delay_gp,numtrs*length(stn_f)*length(relss),Figdir,str_f(str_ind),'PositiveDelay-GPASTN')
        delayvis(spda_data.neg_delay_gp,numtrs*length(stn_f)*length(relss),Figdir,str_f(str_ind),'NegativeDelay-GPASTN')
        delayvis(spda_data.suppressed_gp,numtrs*length(stn_f)*length(relss),Figdir,str_f(str_ind),'Supp-GPASTN')
        delayvis(spda_data.promoted_gp,numtrs*length(stn_f)*length(relss),Figdir,str_f(str_ind),'Prom-GPASTN')
        delayvis(spda_data.pos_delay_gp,spda_data.nosupp_noprom_gp,Figdir,str_f(str_ind),'PositiveDelay-GPASTN-correcttr')
        delayvis_avgval(delays.GPASTN,Figdir,str_f(str_ind),'AverageDelay-trbytr-GPASTN')
        avgdelayvis(Avg_dels,Figdir,str_f(str_ind),'AverageDelay-GPA')
    end
    
    disp('Positive delays for STN ...')
    disp('Negative delays for STN ...')
    
    for str_ind = 1:length(str_f)
        delayvis_stn(spda_data.pos_delay_st,numtrs,Figdir,str_f(str_ind),'PositiveDelay-STN')
        delayvis_stn(spda_data.neg_delay_st,numtrs,Figdir,str_f(str_ind),'NegativeDelay-STN')
        delayvis_stn(spda_data.suppressed_st,numtrs,Figdir,str_f(str_ind),'Supp-STN')
        delayvis_stn(spda_data.promoted_st,numtrs,Figdir,str_f(str_ind),'Prom-STN')
        delayvis_stn(spda_data.promoted_st,spda_data.nosupp_noprom_st,Figdir,str_f(str_ind),'PositiveDelay-STN-correcttr')
        delayvis_avgval_stn(delays.STN,Figdir,str_f(str_ind),'AverageDelay-trbytr-STN')
        avgdelayvis_stn(Avg_dels,Figdir,str_f(str_ind),'AverageDelay-STNSTR')
    end
    % Distribution of off times in SNr for each individual rate
    
    dist_offtime_each_w(str,strstn,strstngpa,Figdir)
    
end

function data_struct_out = struct_conc(data,base_ind,adding_ind)
    for a_ind = 1:length(adding_ind)
        disp(['adding ',num2str(adding_ind(a_ind)),' to ',num2str(base_ind)])
        data{1,base_ind}.stim_param = [data{1,base_ind}.stim_param;...
                                            data{1,adding_ind(a_ind)}.stim_param];
        data{1,base_ind}.nuclei_trials = [data{1,base_ind}.nuclei_trials;...
                                            data{1,adding_ind(a_ind)}.nuclei_trials];
        data{1,base_ind}.average_fr = [data{1,base_ind}.average_fr;...
                                            data{1,adding_ind(a_ind)}.average_fr];
        data{1,base_ind}.average_fr_no_overlap = [data{1,base_ind}.average_fr_no_overlap;...
                                            data{1,adding_ind(a_ind)}.average_fr_no_overlap];
        data{1,base_ind}.offtime = [data{1,base_ind}.offtime;...
                                            data{1,adding_ind(a_ind)}.offtime];
        data{1,base_ind}.stim_param_ISI = [data{1,base_ind}.stim_param_ISI;...
                                            data{1,adding_ind(a_ind)}.stim_param_ISI];
        data{1,base_ind}.nuclei_trials_ISI = [data{1,base_ind}.nuclei_trials_ISI;...
                                            data{1,adding_ind(a_ind)}.nuclei_trials_ISI];
        data{1,base_ind}.num_units = [data{1,base_ind}.num_units;...
                                            data{1,adding_ind(a_ind)}.num_units];
    end
    data_struct_out = data{1,base_ind};
end

function [DAT_red] = NOI_data(DAT,nc_ind)
    IND = DAT.nuclei_trials_ISI(:,1) == nc_ind;
    DAT.nuclei_trials_ISI = DAT.nuclei_trials_ISI(IND,:);
    DAT.stim_param_ISI = DAT.stim_param_ISI(IND,:);
    DAT.offtime = DAT.offtime(IND,:);
    DAT_red = DAT;
end

function avg_delays = delay_measure_average(STR,STN,GPA,all_stim_params,Ws)
%     all_stim_par = combvec(str_f',stn_f',gpa_f',relss',relsg');
    gpa_str_delay = zeros(length(Ws),size(all_stim_params,2));
    stn_str_delay = zeros(length(Ws),size(all_stim_params,2));
    gpa_stn_delay = zeros(length(Ws),size(all_stim_params,2));
    for w_ind = 1:length(Ws)
        for asp_ind = 1:size(all_stim_params,2)
            sel_gpa = GPA.stim_param_ISI(:,2) == all_stim_params(1,asp_ind) & ...
                      GPA.stim_param_ISI(:,3) == all_stim_params(2,asp_ind) & ...
                      GPA.stim_param_ISI(:,1) == all_stim_params(3,asp_ind) & ...
                      GPA.stim_param_ISI(:,5) == all_stim_params(4,asp_ind) & ...
                      GPA.stim_param_ISI(:,4) == all_stim_params(5,asp_ind) & ...
                      GPA.nuclei_trials_ISI(:,3) == Ws(w_ind);
            sel_stn = STN.stim_param_ISI(:,1) == all_stim_params(1,asp_ind) & ...
                      STN.stim_param_ISI(:,2) == all_stim_params(2,asp_ind) & ...
                      STN.stim_param_ISI(:,3) == all_stim_params(4,asp_ind) & ...
                      STN.nuclei_trials_ISI(:,3) == Ws(w_ind);
            sel_str = STR.stim_param_ISI      == all_stim_params(1,asp_ind) & ...
                      STR.nuclei_trials_ISI(:,3) == Ws(w_ind);
                  
            tmp_offgpa = GPA.offtime(sel_gpa);
            tmp_offstn = GPA.offtime(sel_stn);
            tmp_offstr = GPA.offtime(sel_str);
            
            gpa_str_delay(w_ind,asp_ind) = mean(tmp_offgpa(~isnan(tmp_offgpa))) - ...
                                           mean(tmp_offstr(~isnan(tmp_offstr)));
                        
            stn_str_delay(w_ind,asp_ind) = mean(tmp_offstn(~isnan(tmp_offstn))) - ...
                                           mean(tmp_offstr(~isnan(tmp_offstr)));
                        
            gpa_stn_delay(w_ind,asp_ind) = mean(tmp_offgpa(~isnan(tmp_offgpa))) - ...
                                           mean(tmp_offstn(~isnan(tmp_offstn)));
        end
    end
    avg_delays = struct('GPASTR',gpa_str_delay,...
                        'STNSTR',stn_str_delay,...
                        'GPASTN',gpa_stn_delay,...
                        'stim_pars',all_stim_params,...
                        'weights',Ws);
end

function [gpa_str_delay,stn_str_delay,gpa_stn_delay,...
          offtime_str,offtime_stn] = trbytr_delay_measure(STR,STN,GPA)
    offtime_str = zeros(size(GPA.offtime));
    offtime_stn = zeros(size(GPA.offtime));
    for ind = 1:size(GPA.offtime,1)
        str_ind = STR.stim_param_ISI == GPA.stim_param_ISI(ind,2) & ...
                  STR.nuclei_trials_ISI(:,2) == GPA.nuclei_trials_ISI(ind,2) & ...
                  STR.nuclei_trials_ISI(:,3) == GPA.nuclei_trials_ISI(ind,3);
                   
        stn_ind = STN.stim_param_ISI(:,1) == GPA.stim_param_ISI(ind,2) & ...
                  STN.stim_param_ISI(:,2) == GPA.stim_param_ISI(ind,3) & ...
                  STN.stim_param_ISI(:,3) == GPA.stim_param_ISI(ind,4) & ...
                  STN.nuclei_trials_ISI(:,2) == GPA.nuclei_trials_ISI(ind,2) & ...
                  STN.nuclei_trials_ISI(:,3) == GPA.nuclei_trials_ISI(ind,3);
        
        offtime_str(ind) = STR.offtime(str_ind);
        offtime_stn(ind) = STN.offtime(stn_ind);
%         ind

    end
    gpa_str_delay = GPA.offtime - offtime_str;
    stn_str_delay = offtime_stn - offtime_str;
    gpa_stn_delay = GPA.offtime - offtime_stn;
end

function [stn_str_delay,offtime_str] = trbytr_delay_measure_stn(STR,STN)
    offtime_str = zeros(size(STN.offtime));
    for ind = 1:size(STN.offtime,1)
        str_ind = STR.stim_param_ISI == STN.stim_param_ISI(ind,1) & ...
                  STR.nuclei_trials_ISI(:,2) == STN.nuclei_trials_ISI(ind,2) & ...
                  STR.nuclei_trials_ISI(:,3) == STN.nuclei_trials_ISI(ind,3);
        
        offtime_str(ind) = STR.offtime(str_ind);

    end
    stn_str_delay = STN.offtime - offtime_str;
end

function [] = nodecinSN(data_in,numtr,data_path)
%     Ws = unique(data_in)
%     disp(data_in)
    
    fig_dir = fullfile(data_path,'NoDecreaseinSN');
    
    if exist(fig_dir,'dir') ~= 7
        mkdir(fig_dir)
    end
    
    Ws = unique(data_in.del_w(:,3));
    stim = unique(data_in.stim_par);
    nodec_ratio = zeros(length(Ws),length(stim));
    
    for w_ind = 1:length(Ws)
        for s_ind = 1:length(stim)
            sel = data_in.del_w(:,3) == Ws(w_ind) & data_in.stim_par == stim(s_ind);
            nodec_ratio(w_ind,s_ind) = sum(sel)/numtr;
        end
    end
    figure;
    h = bar(Ws,1-nodec_ratio);
    legend(h,num2str(stim),'Location','northwest')
    GCA = gca;
    GCA.FontSize = 14;
    box off
    GCA.TickDir = 'out';
    xlabel('W_{GP_{Arky}\rightarrow STR}')
    ylabel('Ratio')
    fig_print(gcf,fullfile(fig_dir,'DecRatio'))
    close(gcf)
    figure;
    imagesc(stim,Ws,1-nodec_ratio,[0,1])
    colorbar()
    GCA = gca;
    GCA.FontSize = 14;
    box off
    GCA.TickDir = 'out';
    GCA.YTick = Ws;
    GCA.XTick = stim;
%     ylabel('W_{GP_{Arky}\rightarrow STR}')
    ylabel('W')
    xlabel('STR stim')
    fig_print(gcf,fullfile(fig_dir,'DecRatio-heatmap'))
    close(gcf)
    
%     GCA
end

function sig_params = effective_params(data_in,all_pars,weight_vec,numtr,data_path,thr,flname_str)
    
    strf = [];
    stnf = [];
    gpaf = [];
    rlss = [];
    rlsg = [];
    wght = [];
    
    Ws = data_in.del_w(:,3);
    stim = data_in.stim_par;
    for w_ind = 1:length(weight_vec)
        for p_ind = 1:size(all_pars,2)
            inds = stim(:,2) == all_pars(1,p_ind) & ...
                   stim(:,3) == all_pars(2,p_ind) & ...
                   stim(:,1) == all_pars(3,p_ind) & ...
                   stim(:,5) == all_pars(4,p_ind) & ...
                   stim(:,4) == all_pars(5,p_ind) & ...
                   Ws        == weight_vec(w_ind);
               
            if sum(inds)/numtr >= thr
                strf = [strf,all_pars(1,p_ind)];
                stnf = [stnf,all_pars(2,p_ind)];
                gpaf = [gpaf,all_pars(3,p_ind)];
                rlss = [rlss,all_pars(4,p_ind)];
                rlsg = [rlsg,all_pars(5,p_ind)];
                wght = [wght,weight_vec(w_ind)];
            end
            if sum(inds)/numtr > 1
                disp('weird!')
            end
        end
    end
    sel_params = [strf;stnf;gpaf;rlss;rlsg;wght];
    str_params = {'str','stn','gpa','rlss','rlsg','weight'};
    
    sig_params = struct('par',sel_params,...
                        'str',str_params);
end

function [] = delayvis(data_in,numtr,data_path,strf,flname_str)
    
    num_flag = isnumeric(numtr);
    
    if num_flag
        fig_dir = fullfile(data_path,'Delay');
    else
        fig_dir = fullfile(data_path,'Delay-CorrectTr');
    end
    
    if exist(fig_dir,'dir') ~= 7
        mkdir(fig_dir)
    end
    
    Ws = unique(data_in.del_w(:,3));
    stim = unique(data_in.stim_par(:,1));
    rel = unique(data_in.stim_par(:,4));
    pos_delay_ratio = zeros(length(Ws),length(stim));
%     f1 = figure;
    f2 = figure;
    for r_ind = 1:length(rel)
        for w_ind = 1:length(Ws)
            for s_ind = 1:size(stim,1)
                sel = data_in.del_w(:,3) == Ws(w_ind) & data_in.stim_par(:,1) == stim(s_ind,1) & ...
                      data_in.stim_par(:,2) == strf & data_in.stim_par(:,4) == rel(r_ind);
                if num_flag  
                    pos_delay_ratio(w_ind,s_ind) = sum(sel)/numtr;
                else
                    sel_tr = numtr.del_w(:,3) == Ws(w_ind) & numtr.stim_par(:,1) == stim(s_ind,1) & ...
                             numtr.stim_par(:,2) == strf & numtr.stim_par(:,4) == rel(r_ind);
                    pos_delay_ratio(w_ind,s_ind) = sum(sel)/sum(sel_tr);
                end
            end
        end
        
%         % Barplot
%         
%         figure(f1);
%         subplot(2,ceil(length(rel)/2),r_ind)
%         h = bar(Ws,pos_delay_ratio);
%         if r_ind == 1
%             legend(h,num2str(stim),'Location','northeast')
%         end
%         GCA = gca;
%         GCA.FontSize = 14;
%         box off
%         GCA.TickDir = 'out';
%         xlabel('W_{GP_{Arky}\rightarrow STR}')
%         ylabel('Ratio')
%         title(['REL=',num2str(rel(r_ind))])
%         xlim([min(Ws)-0.1,max(Ws)+0.1])
%         ylim([0,1])
%         GCA.XTick = Ws;
        
        % Heatmap
        
        figure(f2);
        subplot(2,ceil(length(rel)/2),r_ind)
        imagesc(stim,Ws,pos_delay_ratio,[0,1])
        colorbar()
        GCA = gca;
        GCA.FontSize = 14;
        box off
        GCA.TickDir = 'out';
%         ylabel('W_{GP_{Arky}\rightarrow STR}')
        ylabel('W')
        xlabel('GPA Stim')
        title(['REL=',num2str(rel(r_ind))])
%         xlim([min(Ws)-0.1,max(Ws)+0.1])
%         ylim([0,1])
%         GCA.XTick = Ws;
        
    end
%     fig_print(f1,fullfile(fig_dir,[num2str(strf),flname_str]))
    fig_print(f2,fullfile(fig_dir,[flname_str,num2str(strf),'-heatmap']))
    close(gcf)
end

function [] = delayvis_stn(data_in,numtr,data_path,strf,flname_str)
    num_flag = isnumeric(numtr);
    
    if num_flag
        fig_dir = fullfile(data_path,'Delay');
    else
        fig_dir = fullfile(data_path,'Delay-CorrectTr');
    end
    if exist(fig_dir,'dir') ~= 7
        mkdir(fig_dir)
    end
    
    Ws = unique(data_in.del_w(:,3));
    stim = unique(data_in.stim_par(:,2));
    rel = unique(data_in.stim_par(:,3));
    pos_delay_ratio = zeros(length(Ws),length(stim));
%     f1 = figure;
    f2 = figure;
    for r_ind = 1:length(rel)
        for w_ind = 1:length(Ws)
            for s_ind = 1:size(stim,1)
                sel = data_in.del_w(:,3) == Ws(w_ind) & data_in.stim_par(:,2) == stim(s_ind) & ...
                      data_in.stim_par(:,1) == strf & data_in.stim_par(:,3) == rel(r_ind);
                  
                if num_flag
                    pos_delay_ratio(w_ind,s_ind) = sum(sel)/numtr;
                else
                    sel_tr = numtr.del_w(:,3) == Ws(w_ind) & numtr.stim_par(:,2) == stim(s_ind) & ...
                             numtr.stim_par(:,1) == strf & numtr.stim_par(:,3) == rel(r_ind);
                    pos_delay_ratio(w_ind,s_ind) = sum(sel)/sum(sel_tr);
                end
            end
        end
        
        % Heatmap
        
        figure(f2);
        subplot(2,ceil(length(rel)/2),r_ind)
        imagesc(stim,Ws,pos_delay_ratio,[0,1])
        colorbar()
        GCA = gca;
        GCA.FontSize = 14;
        box off
        GCA.TickDir = 'out';
%         ylabel('W_{GP_{Arky}\rightarrow STR}')
        ylabel('W')
        xlabel('STN Stim')
        title(['REL=',num2str(rel(r_ind))])
%         xlim([min(Ws)-0.1,max(Ws)+0.1])
%         ylim([0,1])
%         GCA.XTick = Ws;
        
    end
%     fig_print(f1,fullfile(fig_dir,[num2str(strf),flname_str]))
    fig_print(f2,fullfile(fig_dir,[flname_str,num2str(strf),'-heatmap']))
    close(gcf)
end

function [] = delayvis_avgval(data_in,data_path,strf,flname_str)
    
    
    fig_dir = fullfile(data_path,'Delay-val');
    
    if exist(fig_dir,'dir') ~= 7
        mkdir(fig_dir)
    end
    
    Ws = unique(data_in.del_w(:,3));
    stim = unique(data_in.stim_par(:,1));
    rel = unique(data_in.stim_par(:,4));
    del_val = zeros(length(Ws),length(stim));
%     f1 = figure;
    f2 = figure;
    for r_ind = 1:length(rel)
        for w_ind = 1:length(Ws)
            for s_ind = 1:size(stim,1)
                sel = data_in.del_w(:,3) == Ws(w_ind) & data_in.stim_par(:,1) == stim(s_ind,1) & ...
                      data_in.stim_par(:,2) == strf & data_in.stim_par(:,4) == rel(r_ind);
                tmp_val = data_in.delay(sel);
                del_val(w_ind,s_ind) = mean(tmp_val(~isnan(tmp_val)));
            end
        end
        % Heatmap
        
        figure(f2);
        subplot(2,ceil(length(rel)/2),r_ind)
        imagesc(stim,Ws,del_val)
        colorbar()
        GCA = gca;
        GCA.FontSize = 14;
        box off
        GCA.TickDir = 'out';
%         ylabel('W_{GP_{Arky}\rightarrow STR}')
        ylabel('W')
        xlabel('GPA Stim')
        title(['REL=',num2str(rel(r_ind))])
%         xlim([min(Ws)-0.1,max(Ws)+0.1])
%         ylim([0,1])
%         GCA.XTick = Ws;
        
    end
%     fig_print(f1,fullfile(fig_dir,[num2str(strf),flname_str]))
    fig_print(f2,fullfile(fig_dir,[flname_str,num2str(strf)]))
    close(gcf)
end

function [] = delayvis_avgval_stn(data_in,data_path,strf,flname_str)
    
    
    fig_dir = fullfile(data_path,'Delay-val');
    
    if exist(fig_dir,'dir') ~= 7
        mkdir(fig_dir)
    end
    
    Ws = unique(data_in.del_w(:,3));
    stim = unique(data_in.stim_par(:,2));
    rel = unique(data_in.stim_par(:,3));
    del_val = zeros(length(Ws),length(stim));
%     f1 = figure;
    f2 = figure;
    for r_ind = 1:length(rel)
        for w_ind = 1:length(Ws)
            for s_ind = 1:size(stim,1)
                sel = data_in.del_w(:,3) == Ws(w_ind) & data_in.stim_par(:,2) == stim(s_ind,1) & ...
                      data_in.stim_par(:,1) == strf & data_in.stim_par(:,3) == rel(r_ind);
                tmp_val = data_in.delay(sel);
                del_val(w_ind,s_ind) = mean(tmp_val(~isnan(tmp_val)));
            end
        end
        % Heatmap
        
        figure(f2);
        subplot(2,ceil(length(rel)/2),r_ind)
        imagesc(stim,Ws,del_val)
        colorbar()
        GCA = gca;
        GCA.FontSize = 14;
        box off
        GCA.TickDir = 'out';
%         ylabel('W_{GP_{Arky}\rightarrow STR}')
        ylabel('W')
        xlabel('GPA Stim')
        title(['REL=',num2str(rel(r_ind))])
%         xlim([min(Ws)-0.1,max(Ws)+0.1])
%         ylim([0,1])
%         GCA.XTick = Ws;
        
    end
%     fig_print(f1,fullfile(fig_dir,[num2str(strf),flname_str]))
    fig_print(f2,fullfile(fig_dir,[flname_str,num2str(strf)]))
    close(gcf)
end


function [] = avgdelayvis_stn(data_in,data_path,strf,flname_str)
    
    
    fig_dir = fullfile(data_path,'Avg-delay-val');
    
    if exist(fig_dir,'dir') ~= 7
        mkdir(fig_dir)
    end
    
    Ws = data_in.weights;
    stim = unique(data_in.stim_pars(2,:));
    rel = unique(data_in.stim_pars(4,:));
    del_val = zeros(length(Ws),length(stim));
    
%     f1 = figure;
    f2 = figure;
    for r_ind = 1:length(rel)
        for w_ind = 1:length(Ws)
            for s_ind = 1:length(stim)
                sel = data_in.stim_pars(2,:) == stim(s_ind) & ...
                      data_in.stim_pars(1,:) == strf & data_in.stim_pars(4,:) == rel(r_ind);
                tmp_val = data_in.STNSTR(w_ind,sel);
                del_val(w_ind,s_ind) = mean(tmp_val(~isnan(tmp_val)));
            end
        end
        % Heatmap
        
        figure(f2);
        subplot(2,ceil(length(rel)/2),r_ind)
        imagesc(stim,Ws,del_val)
        colorbar()
        GCA = gca;
        GCA.FontSize = 14;
        box off
        GCA.TickDir = 'out';
%         ylabel('W_{GP_{Arky}\rightarrow STR}')
        ylabel('W')
        xlabel('GPA Stim')
        title(['REL=',num2str(rel(r_ind))])
%         xlim([min(Ws)-0.1,max(Ws)+0.1])
%         ylim([0,1])
%         GCA.XTick = Ws;
        
    end
%     fig_print(f1,fullfile(fig_dir,[num2str(strf),flname_str]))
    fig_print(f2,fullfile(fig_dir,[flname_str,num2str(strf)]))
    close(gcf)
end

function [] = avgdelayvis(data_in,data_path,strf,flname_str)
    
    
    fig_dir = fullfile(data_path,'Avg-delay-val');
    
    if exist(fig_dir,'dir') ~= 7
        mkdir(fig_dir)
    end
    
    Ws = data_in.weights;
    stim = unique(data_in.stim_pars(3,:));
    rel = unique(data_in.stim_pars(5,:));
    del_val = zeros(length(Ws),length(stim));
    del_val_gs = zeros(length(Ws),length(stim));
    
    f1 = figure;
    f2 = figure;
    for r_ind = 1:length(rel)
        for w_ind = 1:length(Ws)
            for s_ind = 1:length(stim)
                sel = data_in.stim_pars(3,:) == stim(s_ind) & ...
                      data_in.stim_pars(1,:) == strf & data_in.stim_pars(5,:) == rel(r_ind);
                tmp_val = data_in.GPASTR(w_ind,sel);
                del_val(w_ind,s_ind) = mean(tmp_val(~isnan(tmp_val)));
                tmp_val = data_in.GPASTN(w_ind,sel);
                del_val_gs(w_ind,s_ind) = mean(tmp_val(~isnan(tmp_val)));
            end
        end
        
        % Heatmap
        
        figure(f1);
        subplot(2,ceil(length(rel)/2),r_ind)
        imagesc(stim,Ws,del_val_gs)
        colorbar()
        GCA = gca;
        GCA.FontSize = 14;
        box off
        GCA.TickDir = 'out';
%         ylabel('W_{GP_{Arky}\rightarrow STR}')
        ylabel('W')
        xlabel('GPA Stim')
        title(['REL=',num2str(rel(r_ind))])
        
        % Heatmap
        
        figure(f2);
        subplot(2,ceil(length(rel)/2),r_ind)
        imagesc(stim,Ws,del_val)
        colorbar()
        GCA = gca;
        GCA.FontSize = 14;
        box off
        GCA.TickDir = 'out';
%         ylabel('W_{GP_{Arky}\rightarrow STR}')
        ylabel('W')
        xlabel('GPA Stim')
        title(['REL=',num2str(rel(r_ind))])
%         xlim([min(Ws)-0.1,max(Ws)+0.1])
%         ylim([0,1])
%         GCA.XTick = Ws;
        
    end
    fig_print(f1,fullfile(fig_dir,[flname_str,'STN',num2str(strf)]))
    fig_print(f2,fullfile(fig_dir,[flname_str,'STR',num2str(strf)]))
    close(gcf)
end

function [] = dist_offtime_each_w(str_d,stn_d,gpa_d,dir_path)
    edges = -100:10;
    Ws = unique(str_d.nuclei_trials_ISI(:,3));
    figdir = fullfile(dir_path,'DistributionOfftimes/');
    if exist(figdir,'dir') ~= 7
        mkdir(figdir)
    end
    for w_ind = 1:length(Ws)
        figure;
        histogram(str_d.offtime(str_d.nuclei_trials_ISI(:,3) == Ws(w_ind)),...
                  edges,'Normalization','probability')
        hold on
        histogram(stn_d.offtime(stn_d.nuclei_trials_ISI(:,3) == Ws(w_ind)),...
                  edges,'Normalization','probability')
        histogram(gpa_d.offtime(gpa_d.nuclei_trials_ISI(:,3) == Ws(w_ind)),...
                  edges,'Normalization','probability')
              
        legend({'NoSen','STN-Sen','STNGPA-Sen'},'Location','northwest')
        title(['GPe_{Arky}\rightarrow STR = ',num2str(Ws(w_ind))])
        xlabel('Off time relative to STR stimulation offset')
        fig_print(gcf,[figdir,'W',num2str(Ws(w_ind)*100,'%i')])
        close(gcf)
    end
end

function [SPDA_data,delay_data] = supp_prom_del_adv(STR,STN,GPA)

    disp('Measuring delays ...')
    [delay_gpastn,delay_stn,diffdelay_stnvsgpa,...
     off_str,off_stn] = trbytr_delay_measure(STR,STN,GPA);
    
    % How many and for which parameters SNr does not decrease to 0
 
    NDC_ind = isnan(STR.offtime);
    no_nodec_str = sum(NDC_ind);
    nodec_par = STR.stim_param_ISI(NDC_ind);
    nodec_tw  = STR.nuclei_trials_ISI(NDC_ind,:);
    
    % How many of decreases in SNr are suppressed due to stim in GPA & STN
    
    tmp_ind = ~isnan(off_str) & isnan(GPA.offtime);
    no_supp_dec_gpa = sum(tmp_ind);
    suppdec_par_gpa = GPA.stim_param_ISI(tmp_ind,:);
    suppdec_tw_gpa  = GPA.nuclei_trials_ISI(tmp_ind,:);
    
    % How many of decreases in SNr were not suppressed
    
    tmp_ind = ~isnan(off_str) & ~isnan(GPA.offtime);
    dec_dec_gpa = sum(tmp_ind);
    dec_dec_par_gpa = GPA.stim_param_ISI(tmp_ind,:);
    dec_dec_tw_gpa  = GPA.nuclei_trials_ISI(tmp_ind,:);
    
    % Promoted suppresses GPA & STN
    
    tmp_ind = isnan(off_str) & ~isnan(GPA.offtime);
    no_prom_dec_gpa = sum(tmp_ind);
    promdec_par_gpa = GPA.stim_param_ISI(tmp_ind,:);
    promdec_tw_gpa  = GPA.nuclei_trials_ISI(tmp_ind,:);
    
    % How many of decreases in SNr are suppressed due to stim in STN
    
    [delay_str_stn,off_str_stn] = trbytr_delay_measure_stn(STR,STN);
    tmp_ind = ~isnan(off_str_stn) & isnan(STN.offtime);
    no_supp_dec_stn = sum(tmp_ind);
    suppdec_par_stn = STN.stim_param_ISI(tmp_ind,:);
    suppdec_tw_stn  = STN.nuclei_trials_ISI(tmp_ind,:);
    
    % How many of decreases in SNr were not suppressed
    
    tmp_ind = ~isnan(off_str_stn) & ~isnan(STN.offtime);
    dec_dec_stn = sum(tmp_ind);
    dec_dec_par_stn = GPA.stim_param_ISI(tmp_ind,:);
    dec_dec_tw_stn  = GPA.nuclei_trials_ISI(tmp_ind,:);
    
    % Promoted suppresses STN
    
    tmp_ind = isnan(off_str_stn) & ~isnan(STN.offtime);
    no_prom_dec_stn = sum(tmp_ind);
    promdec_par_stn = STN.stim_param_ISI(tmp_ind,:);
    promdec_tw_stn  = STN.nuclei_trials_ISI(tmp_ind,:);
    
    % Negative delay STN & GPA
    
    neg_ind = delay_gpastn < 0;
    neg_del_par_gpa = GPA.stim_param_ISI(neg_ind,:);
    neg_del_tw_gpa  = GPA.nuclei_trials_ISI(neg_ind,:);
    
    % Positive delay STN & GPA
    
    pos_ind = delay_gpastn >= 0;
    pos_del_par_gpa = GPA.stim_param_ISI(pos_ind,:);
    pos_del_tw_gpa = GPA.nuclei_trials_ISI(pos_ind,:);
    
    % Negative delay STN
    
    neg_ind = delay_str_stn < 0;
    neg_del_par_stn = STN.stim_param_ISI(neg_ind,:);
    neg_del_tw_stn  = STN.nuclei_trials_ISI(neg_ind,:);
    
    % Positive delay STN
    
    pos_ind = delay_str_stn >= 0;
    pos_del_par_stn = STN.stim_param_ISI(pos_ind,:);
    pos_del_tw_stn  = STN.nuclei_trials_ISI(pos_ind,:);
    
    % Positive delay GPA+STN vs. STN
    
    pos_ind = diffdelay_stnvsgpa >= 0;
    pos_del_par_gpa_vs_stn = GPA.stim_param_ISI(pos_ind,:);
    pos_del_tw_gpa_vs_stn  = GPA.nuclei_trials_ISI(pos_ind,:);
    
    % Additional suppresses in GPA+STN than STN
    
    add_ind = ~isnan(off_str) & ~isnan(off_stn) & isnan(GPA.offtime);
    suppdec_par_gp_vs_stn = GPA.stim_param_ISI(add_ind,:);
    suppdec_tw_gp_vs_stn = GPA.nuclei_trials_ISI(add_ind,:);
    
    
    SPDA_data = struct('no_decrease',struct('count',no_nodec_str,...
                                            'stim_par',nodec_par,...
                                            'del_w',nodec_tw),...
                       'suppressed_gp',struct('count',no_supp_dec_gpa,...
                                              'stim_par',suppdec_par_gpa,...
                                              'del_w',suppdec_tw_gpa),...
                       'suppressed_st',struct('count',no_supp_dec_stn,...
                                              'stim_par',suppdec_par_stn,...
                                              'del_w',suppdec_tw_stn),...
                       'nosupp_noprom_gp',struct('count',dec_dec_gpa,...
                                              'stim_par',dec_dec_par_gpa,...
                                              'del_w',dec_dec_tw_gpa),...
                       'nosupp_noprom_st',struct('count',dec_dec_stn,...
                                              'stim_par',dec_dec_par_stn,...
                                              'del_w',dec_dec_tw_stn),...                                              
                       'promoted_gp',struct('count',no_prom_dec_gpa,...
                                            'stim_par',promdec_par_gpa,...
                                            'del_w',promdec_tw_gpa),...
                       'promoted_st',struct('count',no_prom_dec_stn,...
                                            'stim_par',promdec_par_stn,...
                                            'del_w',promdec_tw_stn),...
                       'pos_delay_gp',struct('stim_par',pos_del_par_gpa,...
                                             'del_w',pos_del_tw_gpa),...
                       'neg_delay_gp',struct('stim_par',neg_del_par_gpa,...
                                             'del_w',neg_del_tw_gpa),...
                       'pos_delay_st',struct('stim_par',pos_del_par_stn,...
                                             'del_w',pos_del_tw_stn),...
                       'neg_delay_st',struct('stim_par',neg_del_par_stn,...
                                             'del_w',neg_del_tw_stn),...
                       'pos_delay_gpvsst',struct('stim_par',pos_del_par_gpa_vs_stn,...
                                                 'del_w',pos_del_tw_gpa_vs_stn),...
                       'suppressed_gp_vs_st',struct('stim_par',suppdec_par_gp_vs_stn,...
                                                    'del_w',suppdec_tw_gp_vs_stn),...
                       'stimstr',struct('par',STR.stim_param_ISI,...
                                        'trw',STR.nuclei_trials_ISI),...
                       'stimstn',struct('par',STN.stim_param_ISI,...
                                        'trw',STN.nuclei_trials_ISI),...
                       'stimgpa',struct('par',GPA.stim_param_ISI,...
                                        'trw',GPA.nuclei_trials_ISI));
    delay_data  = struct('GPASTN',struct('delay',delay_gpastn,...
                                         'delay_stn',delay_stn,...
                                         'delay_vsstn',diffdelay_stnvsgpa,...
                                         'off_str',off_str,...
                                         'off_stn',off_stn,...
                                         'stim_par',GPA.stim_param_ISI,...
                                         'del_w',GPA.nuclei_trials_ISI),...
                         'STN',struct('delay',delay_str_stn,...
                                      'off_str',off_str_stn,...
                                      'stim_par',STN.stim_param_ISI,...
                                      'del_w',STN.nuclei_trials_ISI));
end

% function [] = avgdelayvis(data_in,data_path,strf,flname_str)
%     
%     
%     fig_dir = fullfile(data_path,'Avg-delay-val');
%     
%     if exist(fig_dir,'dir') ~= 7
%         mkdir(fig_dir)
%     end
%     
%     Ws = data_in.weights;
%     stim = unique(data_in.stim_pars(:,3));
%     rel = unique(data_in.stim_pars(:,5));
%     del_val = zeros(length(Ws),length(stim));
%     
% %     f1 = figure;
%     f2 = figure;
%     for r_ind = 1:length(rel)
%         for w_ind = 1:length(Ws)
%             for s_ind = 1:size(stim,1)
%                 sel = data_in.stim_pars.stim_par(:,3) == stim(s_ind,1) & ...
%                       data_in.stim_pars(:,1) == strf & data_in.stim_pars(:,5) == rel(r_ind);
%                 tmp_val = data_in.GPASTN(w_ind,sel);
%                 del_val(w_ind,s_ind) = mean(tmp_val(~isnan(tmp_val)));
%             end
%         end
%         % Heatmap
%         
%         figure(f2);
%         subplot(2,ceil(length(rel)/2),r_ind)
%         imagesc(stim,Ws,del_val)
%         colorbar()
%         GCA = gca;
%         GCA.FontSize = 14;
%         box off
%         GCA.TickDir = 'out';
% %         ylabel('W_{GP_{Arky}\rightarrow STR}')
%         ylabel('W')
%         xlabel('GPA Stim')
%         title(['REL=',num2str(rel(r_ind))])
% %         xlim([min(Ws)-0.1,max(Ws)+0.1])
% %         ylim([0,1])
% %         GCA.XTick = Ws;
%         
%     end
% %     fig_print(f1,fullfile(fig_dir,[num2str(strf),flname_str]))
%     fig_print(f2,fullfile(fig_dir,[flname_str,num2str(strf)]))
%     close(gcf)
% end
