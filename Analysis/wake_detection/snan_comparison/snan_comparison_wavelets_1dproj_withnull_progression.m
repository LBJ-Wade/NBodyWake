function [ snan_data_nowake red_list_out_nowake snan_data_wake red_list_out_wake] = snan_comparison_wavelets_1dproj_withnull_progression(root,root_snan_in,root_snan_out,aux_path_snan_in,aux_path_snan_out,lenght_factor,resol_factor,pivot,rot_angle,cutoff,z_id_range)

%reads the data from proj1d_dm_analysis for the signal to noise analysis
%and creates the corresponding figures

%(example) snan_comparison_wavelets_1dproj_withnull_progression('/home/asus/Dropbox/extras/storage/guillimin/','/home/asus/Dropbox/extras/storage/guillimin/box_snan_s2l/','/home/asus/Dropbox/extras/storage/guillimin/box_snan_s2l_comparizon/','','',1,1,[0,0,0],[0,0],0.8,'all');
%(example) snan_comparison_wavelets_1dproj_withnull_progression('/home/asus/Dropbox/extras/storage/graham/','/home/asus/Dropbox/extras/storage/graham/snan_gra64/','/home/asus/Dropbox/extras/storage/guillimin/snan_gra64_comparizon/','','',1,2,[0,0,0],[0,0],0.4,'all');


% NBody output should be stored as root+spec+aux_path (root directory, specification in the form size_numberofcellsperdimension_number_particlesperdimension_initialredshift_wakespecification&multiplicity, aux_path is the sample number )

% data will be readed in  root_snan_in+spec+aux_path+aux_path_snan_in

% table will be saved in  aux_path_snan_out+spec+aux_path+aux_path_snan_out

% lenght_factor = the analysis cube will have a lateral size given by the
% lateral size of the simulation cube divided by this number

% resol_factor= the bin will hte the particle bin size divided by this
%number

% pivot = a 3d array containing the translation wrt to the center of the
% cube (in grid cell units)

%rot_angle = 2d aray containing the theta and phy spherical angles pointing
%to the direction where the new z axis will be rotated


% z_id_range = array with the redshift id of the requested plots and
% analysis, which starts
% with the highest one equals to 1 and decreasing by unit as the redshift
% is decreased for the id convention. If set to "all" will do for every
% redshift

%sample_id_range: an array containing the id of the samples to be analyzed.
%If set to 'all' every sample will be accounted

% info=[0,1,2,3]
% if info=0, histogram of each plot is generated
% if info=1, minimal plots are generated
% if info=2 complete plots are generated

% analysis=1 -> create a textfile with signal to noise data (peak, std, peak/std)




Markers = {'+','*','x','v','d','^','s','>','<'};
plots={};
% if ischar(z_id_range)
%     z_id_range=[1 : length(redshift_list)];
% end

fig1=figure('Visible', 'off');
% fig1=figure;
set(gcf, 'Position', [0 0 1600 800]);
fig2=figure('Visible', 'off');
% fig2=figure;
set(gcf, 'Position', [0 0 1600 800]);
%  fig3=figure;
%  set(gcf, 'Position', [0 0 1600 800]);

ax1=axes(fig1);
ax2=axes(fig2);
% ax3=axes(fig3);

 cd('../../processing');

path_comparizon_out=strcat(root_snan_out,aux_path_snan_out);
mkdir(strcat(root_snan_out,aux_path_snan_out));


path_specs_in=strcat(root_snan_in,aux_path_snan_in);

specs_nowake=dir(strcat(path_specs_in,'/*nowake*'));
specs__nowake={specs_nowake.name};

specs_list_wake=dir(strcat(path_specs_in,'/*wakeGmu*'));
specs_list_wake={specs_list_wake.name};
specs_list_wake=sort_nat(specs_list_wake);

specs_list=dir(strcat(path_specs_in,'/*'));
specs_list={specs_list.name};
specs_list=sort_nat(specs_list);
specs_list=specs_list(3:end);
display(specs_list);
% 
redshift_data=[];
peak_data=[];
std_peak_data=[];

% for Spec_Id=1:length(specs_list)
    
    cd('../processing');
    
%     spec=specs_list{Spec_Id};
    spec=specs__nowake{1};
    path_samples_in=strcat(root_snan_in,aux_path_snan_in,spec);
    sample_list=dir(strcat(path_samples_in,'/sample*'));
    sample_list={sample_list.name};
    sample_list=sort_nat(sample_list);
    
%     display(sample_list)
    
        sample_id_range=[1 : length(sample_list)];
    
    

    
    %     redshift_array=cellfun(@str2num, redshift_list(:,:));
    %     peak=ones(1,length(redshift_array));
    %     err=ones(1,length(redshift_array));
    %
    % %     errorbar(redshift_array,peak,err/2,'o');
    
    cd('../preprocessing');
    snan_data=zeros(length(z_id_range),length(sample_id_range),3);
    
%     display(sample_id_range)
    
    sample_recount=1;
    for sample=sample_id_range
        rds_recount=1;
        
        [~,redshift_list,~,~,~,~,~,~,~,~,~] = preprocessing_info(root,spec,strcat('/',sample_list{sample},'/'));
        
%         if ischar(z_id_range)
            z_id_range=[1 : length(redshift_list)];
%         end
        
        
        for rds = z_id_range
            tot_snan_path_in=strcat(root_snan_in,spec,aux_path_snan_in,'/',char(sample_list(sample)),'/snan/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj/');
            %the bove is snan_data(rds,sample,:) from 1 to 3 -> peak, average,
            %peak/aver
            snan_data(rds_recount,sample_recount,:)=dlmread(char(strcat(tot_snan_path_in,'dm/','wavelet_filtered_abs_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_snan_1dproj_cwt_z',num2str(str2num(char(redshift_list(rds)))),'_data.txt')));            
            data1(rds_recount,1)=redshift_list(1,rds);
            data1(rds_recount,2:4)=num2cell(squeeze(snan_data(rds_recount,sample_recount,:)));
            [ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw ] = preprocessing_from_path( root,spec,strcat('/',sample_list{sample},'/'));
            
            
            
            rds_recount=rds_recount+1;
        end
        sample_recount=sample_recount+1;
        
        
    end
    

    data(1:length(z_id_range),2)=num2cell(squeeze(mean(snan_data(1:length(z_id_range),1:length(sample_id_range),1),2)));
    data(1:length(z_id_range),3)=num2cell(squeeze(std(snan_data(1:length(z_id_range),1:length(sample_id_range),1),0,2)));
    data(1:length(z_id_range),4)=num2cell(squeeze(mean(snan_data(1:length(z_id_range),1:length(sample_id_range),2),2)));
    data(1:length(z_id_range),5)=num2cell(squeeze(std(snan_data(1:length(z_id_range),1:length(sample_id_range),2),0,2)));
    data(1:length(z_id_range),6)=num2cell(squeeze(mean(snan_data(1:length(z_id_range),1:length(sample_id_range),3),2)));
    data(1:length(z_id_range),7)=num2cell(squeeze(std(snan_data(1:length(z_id_range),1:length(sample_id_range),3),0,2)));
    
    redshift_array=cellfun(@str2num, redshift_list(:,:));
    peak=cellfun(@squeeze,data(1:length(z_id_range),2));
    peak_err=cellfun(@squeeze,data(1:length(z_id_range),3));
    stand=cellfun(@squeeze,data(1:length(z_id_range),4));
    stand_err=cellfun(@squeeze,data(1:length(z_id_range),5));    
    stn=cellfun(@squeeze,data(1:length(z_id_range),6));
    stn_err=cellfun(@squeeze,data(1:length(z_id_range),7));
    display([stn,stn_err]);
    
    red_list_out_nowake=redshift_array;
    snan_data_nowake=snan_data;
    
%     for rds = z_id_range

        plots{1} = scatter(ax1,(redshift_array+1).^-1,transpose(snan_data(:,1,1)));
        
         hold(ax1,'on');
        for sampl_id = 2:length(sample_id_range)
            scatter(ax1,(redshift_array+1).^-1,snan_data(:,sampl_id,1));
        end
%         legend([h1],{'no wake'});
%         hold(ax1,'off');
%     end
    
%     errorbar(ax1,(redshift_array+1).^-1,peak,peak_err);    
%     hold(ax1,'on');
%     errorbar(ax2,(redshift_array+1).^-1,stand,stand_err);    
%     hold(ax2,'on');    
%     errorbar(ax3,(redshift_array+1).^-1,stn,stn_err);
%     if Spec_Id==1
        xticks(ax1,(redshift_array+1).^-1);
        xticklabels(ax1,redshift_list);
        xtickangle(ax1,90);
        set(ax1, 'YScale', 'log');
        set(ax1, 'XScale', 'log');
        
%         title(ax1,{'Summary plot of the peak from the samples without wake'},'interpreter', 'latex', 'fontsize', 20);
% title(ax2,{'Summary plot of the standard deviation'},'interpreter', 'latex', 'fontsize', 20);
% title(ax3,{'Summary plot of the signal to noise ratio for the filtered 1d projection with high resolution'},'interpreter', 'latex', 'fontsize', 20);
xlabel(ax1,'redshift', 'interpreter', 'latex', 'fontsize', 20);
ylabel(ax1,'Peak', 'interpreter', 'latex', 'fontsize', 20);
set(ax1,'FontName','FixedWidth');
set(ax1,'FontSize',16);
set(ax1,'linewidth',2);
        
%                  hold(ax1,'off');

%     end
%     hold(ax1,'off');

peak_null=peak;
peak_err_null=peak_err;

redshift_list_nowake=redshift_list;




    
for Spec_Id=1:length(specs_list_wake)
    
    cd('../processing');
    
    spec=specs_list_wake{Spec_Id};
    path_samples_in=strcat(root_snan_in,aux_path_snan_in,spec);
    sample_list=dir(strcat(path_samples_in,'/sample*'));
    sample_list={sample_list.name};
    sample_list=sort_nat(sample_list);
    
        sample_id_range=[1 : length(sample_list)];
    
    

    
    %     redshift_array=cellfun(@str2num, redshift_list(:,:));
    %     peak=ones(1,length(redshift_array));
    %     err=ones(1,length(redshift_array));
    %
    % %     errorbar(redshift_array,peak,err/2,'o');
        cd('../preprocessing');

    clearvars redshift_list
    [~,redshift_list,~,~,~,~,~,~,~,~,~] = preprocessing_info(root,spec,strcat('/',sample_list{1},'/'));
        
%         if ischar(z_id_range)
            z_id_range=[1 : length(redshift_list)];
    
    snan_data=zeros(length(z_id_range),length(sample_id_range),3);
    
    sample_recount=1;
    for sample=sample_id_range
        rds_recount=1;
        
        [~,redshift_list,~,~,~,~,~,~,~,~,~] = preprocessing_info(root,spec,strcat('/',sample_list{sample},'/'));
        
%         if ischar(z_id_range)
            z_id_range=[1 : length(redshift_list)];
%         end
        
        
        for rds = z_id_range
            tot_snan_path_in=strcat(root_snan_in,spec,aux_path_snan_in,'/',char(sample_list(sample)),'/snan/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj/');
            %the bove is snan_data(rds,sample,:) from 1 to 3 -> peak, average,
            %peak/aver
            snan_data(rds_recount,sample_recount,:)=dlmread(char(strcat(tot_snan_path_in,'dm/','wavelet_filtered_abs_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_snan_1dproj_cwt_z',num2str(str2num(char(redshift_list(rds)))),'_data.txt')));            
            data1(rds_recount,1)=redshift_list(1,rds);
            data1(rds_recount,2:4)=num2cell(squeeze(snan_data(rds_recount,sample_recount,:)));
            [ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw ] = preprocessing_from_path( root,spec,strcat('/',sample_list{sample},'/'));
            
            
            
            rds_recount=rds_recount+1;
        end
        sample_recount=sample_recount+1;
        
        
    end
    

    data(1:length(z_id_range),2)=num2cell(squeeze(mean(snan_data(1:length(z_id_range),1:length(sample_id_range),1),2)));
    data(1:length(z_id_range),3)=num2cell(squeeze(std(snan_data(1:length(z_id_range),1:length(sample_id_range),1),0,2)));
    data(1:length(z_id_range),4)=num2cell(squeeze(mean(snan_data(1:length(z_id_range),1:length(sample_id_range),2),2)));
    data(1:length(z_id_range),5)=num2cell(squeeze(std(snan_data(1:length(z_id_range),1:length(sample_id_range),2),0,2)));
    data(1:length(z_id_range),6)=num2cell(squeeze(mean(snan_data(1:length(z_id_range),1:length(sample_id_range),3),2)));
    data(1:length(z_id_range),7)=num2cell(squeeze(std(snan_data(1:length(z_id_range),1:length(sample_id_range),3),0,2)));
    
    redshift_array=cellfun(@str2num, redshift_list(:,:));
%     peak=cellfun(@squeeze,data(1:length(z_id_range),2));
    stn=zeros(length(z_id_range),length(sample_id_range));
    for rds = z_id_range
        zid_nowake=find(str2num(char(redshift_list_nowake))==str2num(redshift_list{rds}));
        stn(rds,:)=(snan_data(rds,1:length(sample_id_range),1)-peak_null(zid_nowake))/peak_err_null(zid_nowake);
    end
    peak_samples(1:length(z_id_range))=mean(stn,2);
    peak_err_samples(1:length(z_id_range))=transpose(std(transpose(stn),1));
%     peak_err=cellfun(@squeeze,data(1:length(z_id_range),3));
%     stand=cellfun(@squeeze,data(1:length(z_id_range),4));
%     stand_err=cellfun(@squeeze,data(1:length(z_id_range),5));    
%     stn=cellfun(@squeeze,data(1:length(z_id_range),6));
%     stn_err=cellfun(@squeeze,data(1:length(z_id_range),7));
%     display([stn,stn_err]);

    red_list_out_wake=redshift_array;
    snan_data_wake=snan_data;


    display([peak_samples]);
    display(peak_err_samples);
    display(Spec_Id);
    errorbar(ax2,(redshift_array+1).^-1,peak_samples,peak_err_samples);    
    hold(ax2,'on');
%     errorbar(ax2,(redshift_array+1).^-1,stand,stand_err);    
%     hold(ax2,'on');    
%     errorbar(ax3,(redshift_array+1).^-1,stn,stn_err);
%     if Spec_Id==1
        xticks(ax2,(redshift_array+1).^-1);
        xticklabels(ax2,redshift_list);
        xtickangle(ax2,90);
%     end
    
%     xticks(ax2,(redshift_array+1).^-1);
%         xticklabels(ax2,redshift_list);
%         xtickangle(ax2,90);
        set(ax2, 'YScale', 'log');
        set(ax2, 'XScale', 'log');
    
%     hold(ax3,'on');


 plots{Spec_Id+1}=scatter(ax1,(redshift_array+1).^-1,transpose(snan_data(:,1,1)),Markers{Spec_Id});
         hold(ax1,'on');
        for sampl_id = 2:length(sample_id_range)
            scatter(ax1,(redshift_array+1).^-1,snan_data(:,sampl_id,1),Markers{Spec_Id});
        end

    clearvars redshift_array peak_samples peak_err_samples
    
     
end

test=regexp(specs_list, '_', 'split');
leg={};
for j=1:length(test)
    wake_spec=char(test{j}{5});
    if wake_spec(1)=='n'
        Gmu=0;
    end
    if wake_spec(1)=='w'
        wake_spec2=strsplit(wake_spec,{'u','t10m','zi'},'CollapseDelimiters',true);
        Gmu=str2num(char(wake_spec2(2)))*10^(-str2num(char(wake_spec2(3))));
    end
    
    leg{j}=(strcat('G\mu =',num2str(Gmu)));
end


test=regexp(specs_list_wake, '_', 'split');
leg={};
for j=1:length(test)
    wake_spec=char(test{j}{5});
    if wake_spec(1)=='n'
        Gmu=0;
    end
    if wake_spec(1)=='w'
        wake_spec2=strsplit(wake_spec,{'u','t10m','zi'},'CollapseDelimiters',true);
        Gmu=str2num(char(wake_spec2(2)))*10^(-str2num(char(wake_spec2(3))));
    end
    
    leg{j}=(strcat('G\mu =',num2str(Gmu)));

    
end

%legend with the gmu info
% legend(ax1,[plots{:}],'G\mu =0',leg{:},'Location','northwest');

%legend with the spec info
% % l = legend(ax1,[plots{:}],specs_list{:},'Location','northwest');
l = legend(ax1,[plots{:}],specs_list{:},'Location','northoutside');
set(l, 'Interpreter', 'none');

hold(ax1,'off');

    legend(ax2,leg,'Location','northoutside');

% title(ax2,{'Summary plot of the standard deviation'},'interpreter', 'latex', 'fontsize', 20);
% title(ax3,{'Summary plot of the signal to noise ratio for the filtered 1d projection with high resolution'},'interpreter', 'latex', 'fontsize', 20);
xlabel(ax2,'redshift', 'interpreter', 'latex', 'fontsize', 20);
ylabel(ax2,'Signal to noise', 'interpreter', 'latex', 'fontsize', 20);
set(ax2,'FontName','FixedWidth');
set(ax2,'FontSize',16);
set(ax2,'linewidth',2);

mkdir(path_comparizon_out);
saveas(fig1,strcat(path_comparizon_out,'peaks_dist.png'));
saveas(fig2,strcat(path_comparizon_out,'signal_to_noise.png'));


% legend(ax1,specs_list);
% legend(ax1,strcat('G\mu =',num2str(0)));

clearvars peak_null peak_err_null zid_nowake stn peak_samples peak_err_samples

snan_data_nowake_r=flip(snan_data_nowake,2);


for rds =1:length(redshift_list)
% for rds =1:2
% for rds =2
rds_nowake=find(str2num(char(redshift_list_nowake))==str2num(redshift_list{rds}));
% fig=figure('Visible', 'off');
fig=figure;
set(gcf, 'Position', [0 0 1600 800]);
ax=axes(fig);

% for nsample=2:3
for nsample=2:length(sample_id_range)

peak_null_aux(1)=num2cell(squeeze(mean(snan_data_nowake_r(rds_nowake,1:nsample,1),2)));
peak_null_aux(2)=num2cell(squeeze(std(snan_data_nowake_r(rds_nowake,1:nsample,1),0,2)));

% display(snan_data_nowake_r(1:length(z_id_range),1:nsample,1))
display(peak_null_aux)
% display(snan_data_nowake_r(1:length(z_id_range),1:length(nsample),1))

% peak_null=cellfun(@squeeze,peak_null_aux(rds_nowake,1));
% peak_err_null=cellfun(@squeeze,peak_null_aux(rds_nowake,2));

peak_null=cellfun(@squeeze,peak_null_aux(1,1));
peak_err_null=cellfun(@squeeze,peak_null_aux(1,2));

display(peak_null);

% zid_nowake=find(str2num(char(redshift_list_nowake))==str2num(redshift_list{rds}));
stn(1,:)=(snan_data_wake(rds,1:nsample,1)-peak_null)/peak_err_null;
display(stn)
peak_samples(rds,nsample)=mean(stn,2);
peak_err_samples(rds,nsample)=transpose(std(transpose(stn),1));
% display(stn)


% errorbar(1:nsample,peak_samples,peak_err_samples);

clearvars peak_null peak_err_null stn

display(peak_samples)

end

display(peak_samples)

errorbar(2:length(sample_id_range),peak_samples(rds,2:length(sample_id_range)),peak_err_samples(rds,2:length(sample_id_range)));

set(ax, 'YScale', 'log');
set(ax, 'XScale', 'log');

xlabel(ax,'number of samples', 'interpreter', 'latex', 'fontsize', 20);
ylabel(ax,'Signal to noise', 'interpreter', 'latex', 'fontsize', 20);
set(ax,'FontName','FixedWidth');
set(ax,'FontSize',16);
set(ax,'linewidth',2);
legend(ax,strcat('z =',num2str(redshift_list{rds}),' ,',leg{1}),'Location','northoutside');

mkdir(strcat(path_comparizon_out,'nsamples_z/'));
saveas(fig,strcat(path_comparizon_out,'nsamples_z/',num2str(find(str2num(char(redshift_list))==redshift_list{rds})),'_peaks_dist_z',num2str(redshift_list{rds}),'.png'));

clearvars peak_samples peak_err_samples

end
    
cd('../wake_detection/snan_comparison');


end

