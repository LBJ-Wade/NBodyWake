function [  ] = snan_comparison_1dproj(root,root_snan_in,root_snan_out,aux_path_snan_in,aux_path_snan_out,lenght_factor,resol_factor,pivot,rot_angle,z_id_range,id_specs,info,analysis)

%reads the data from proj1d_dm_analysis for the signal to noise analysis
%and creates the corresponding figures

%(example) snan_comparison_1dproj('/home/asus/Dropbox/extras/storage/guillimin/','/home/asus/Dropbox/extras/storage/guillimin/snan/','/home/asus/Dropbox/extras/storage/guillimin/snan_comparizon/','','',1,1,[0,0,0],[0,0],'all','all',[1,2,3],[1,2,3]);


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





% if ischar(z_id_range)
%     z_id_range=[1 : length(redshift_list)];
% end

fig1=figure('Visible', 'off');
set(gcf, 'Position', [0 0 1600 800]);
fig2=figure('Visible', 'off');
set(gcf, 'Position', [0 0 1600 800]);
fig3=figure;
set(gcf, 'Position', [0 0 1600 800]);


ax1=axes(fig1);
ax2=axes(fig2);
ax3=axes(fig3);

 cd('../../processing');

path_comparizon_out=strcat(root_snan_out,aux_path_snan_out,'comparison/');
mkdir(strcat(root_snan_out,aux_path_snan_out));
mkdir(strcat(root_snan_out,aux_path_snan_out),strcat('comparison/'));

path_specs_in=strcat(root_snan_in,aux_path_snan_in);
specs_list=dir(strcat(path_specs_in,'/*'));
specs_list={specs_list.name};
specs_list=sort_nat(specs_list);
specs_list=specs_list(3:end);
display(specs_list);
% 


for Spec_Id=1:length(specs_list)
    
    cd('../processing');
    
    spec=specs_list{Spec_Id};
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
            snan_data(rds_recount,sample_recount,:)=dlmread(char(strcat(tot_snan_path_in,'dm/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_snan_1dproj_z',num2str(str2num(char(redshift_list(rds)))),'_data.txt')));            
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
    
    

    
    errorbar(ax1,(redshift_array+1).^-1,peak,peak_err);    
    hold(ax1,'on');
    errorbar(ax2,(redshift_array+1).^-1,stand,stand_err);    
    hold(ax2,'on');    
    errorbar(ax3,(redshift_array+1).^-1,stn,stn_err);
    if Spec_Id==1
        xticks(ax3,(redshift_array+1).^-1);
        xticklabels(ax3,redshift_list);
        xtickangle(ax3,90);
    end
    hold(ax3,'on');
    
    
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


legend(ax1,specs_list);
legend(ax2,specs_list);
legend(ax3,leg);

title(ax1,{'Summary plot of the peak'},'interpreter', 'latex', 'fontsize', 20);
title(ax2,{'Summary plot of the standard deviation'},'interpreter', 'latex', 'fontsize', 20);
title(ax3,{'Summary plot of the signal to noise ratio'},'interpreter', 'latex', 'fontsize', 20);
xlabel(ax3,'redshift', 'interpreter', 'latex', 'fontsize', 20);
ylabel(ax3,'Signal to noise', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);


    
cd('../wake_detection/snan_comparison');


end

