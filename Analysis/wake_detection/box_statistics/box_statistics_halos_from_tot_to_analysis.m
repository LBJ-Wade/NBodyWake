function [  ] = box_statistics_halos_from_tot_to_analysis( root_per_node_out,spec,aux_path,aux_path_per_node_out,NSIDE )

% (example) box_statistics_halos_from_tot_to_analysis('/home/asus/Dropbox/extras/storage/guillimin/old/','32Mpc_96c_48p_zi63_nowakes','/','',4);
% (example) box_statistics_halos_from_tot_to_analysis('/home/asus/Dropbox/extras/storage/','40Mpc_192c_96p_zi65_nowakes','/','',4);    


pivot=[0,0,0]; %this is the position od the origin of the rotation point with respect to the center of the box
lenght_factor=2;
resol_factor=2;

%reads the specifications and extract the information on variables
spec_arr = strsplit(spec,'_');

%extract the box size

size_box = spec_arr(1);
size_box = char(size_box);
size_box = size_box(1:end-3);
size_box = str2num(size_box);

%extract the number of cells per dimension

nc = spec_arr(2);
nc = char(nc);
nc = nc(1:end-1);
nc = str2num(nc);

%extract the number of particle per dimension

np = spec_arr(3);
np = char(np);
np = np(1:end-1);
np = str2num(np);
 
%extract the initial redshift of the simulation
  
 zi = spec_arr(4);
 zi = char(zi);
 zi = zi(3:end);
 zi = str2num(zi);
 
  % extracts the informations of the wake if there is one
 
 wake_spec = spec_arr(5);
 wake_spec = char(wake_spec);
 if wake_spec(1)=='n'
    wake_or_no_wake='no wake';
    multiplicity_of_files=wake_spec(end); 
    Gmu=0;
    ziw=0;
 end
 if wake_spec(1)=='w'
     wake_or_no_wake='wake';
     wake_spec2=strsplit(wake_spec,{'u','t10m','zi'},'CollapseDelimiters',true);
     Gmu=str2num(char(wake_spec2(2)))*10^(-str2num(char(wake_spec2(3))));
     ziw=char(wake_spec2(4));
     ziw=str2num(ziw(1:end-1));
     multiplicity_of_files=char(wake_spec(end));
 end
 
 
path_total_out=strcat(strcat(root_per_node_out,spec,aux_path),'data/',aux_path_per_node_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv','/','stat/box_statistics/halos/all_nodes_1dproj/');
path_analysis_out=strcat(strcat(root_per_node_out,spec,aux_path),'data/',aux_path_per_node_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv','/','stat/box_statistics/halos/all_nodes_1dproj_analysis/');

% 
% path_in=strcat(root_per_node_out,spec,aux_path,'data/','stat/','box_statistics/','halos/','total/');
% path_data_out=strcat(root_per_node_out,spec,aux_path,'data/','stat/','box_statistics/','halos/');
% path_analysis_out=strcat(root_per_node_out,spec,aux_path,'Analysis/stat/box_statistics/','halos/');


% path_out=strcat(path,spec,aux_path,strcat('Analysis/','stat/box_statistics/'));
%for guillimin
% path_out=strcat('/gs/scratch/cunhad/',spec,aux_path);


files_list = dir(strcat(path_total_out,'number/','*','_NSIDE',num2str(NSIDE),'.txt'));
%files_list = dir(strcat(path_in,'*'));
sorted_files_list={files_list.name};

cd('../../processing');

angles = dlmread(strcat('../../python/angles',num2str(NSIDE),'.txt'));
[angle_nuple,number_of_angle_nuple] = size(angles);

        theta=angles(1,:);
        phi=angles(2,:);

sorted_files_list=sort_nat(sorted_files_list);

display(sorted_files_list);

[aux1 aux2] = size(num2str(NSIDE));
aux3=aux2+22;
redshift_list=cellfun(@(x) x(26:end-aux3),sorted_files_list,'UniformOutput', false);

cd('../preprocessing');

for rds = 1 : length(redshift_list)  
    
    count_n=dlmread(strcat(path_total_out,'number/','_1dproj_num_count_angle_z',char(redshift_list(rds)),'_total_nodes','_NSIDE',num2str(NSIDE),'.txt'));
    count_mass_dc=dlmread(strcat(path_total_out,'mass/','_1dproj_mass_dc_angle_z',char(redshift_list(rds)),'_total_nodes','_NSIDE',num2str(NSIDE),'.txt'));
    count_mass_dc_wrt_dm_avr=dlmread(strcat(path_total_out,'mass_dc_wrt_dm_avr/','_1dproj_mass_dc_wrt_dm_avr_angle_z',char(redshift_list(rds)),'_total_nodes','_NSIDE',num2str(NSIDE),'.txt'));

    
    
    count_n=transpose(count_n);
    count_mass_dc=transpose(count_mass_dc);
    count_mass_dc_wrt_dm_avr=transpose(count_mass_dc_wrt_dm_avr);
    
    
    %     average=mean(count);
    %     count(:,:)=(count(:,:)-average(1,:))./average(1,:);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %computes the peaks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    maxi=max(count_n);
    maxi=transpose(maxi);
    
    mkdir(path_analysis_out,strcat('number/max_1dproj/'));
    dlmwrite(strcat(path_analysis_out,'number/max_1dproj/','_',num2str(rds,strcat('%0',num2str(1+floor(length(redshift_list)/10)),'d')),'_1dproj_halos_max_z',char(redshift_list(rds)),'_NSIDE',num2str(NSIDE),'.txt'),maxi,'delimiter','\t');

    
    
    maxi_dc=max(count_mass_dc);
    maxi_dc=transpose(maxi_dc);
    
    mkdir(path_analysis_out,strcat('dc/max_1dproj/'));
    dlmwrite(strcat(path_analysis_out,'dc/max_1dproj/','_',num2str(rds,strcat('%0',num2str(1+floor(length(redshift_list)/10)),'d')),'_1dproj_halos_dc_max_z',char(redshift_list(rds)),'_NSIDE',num2str(NSIDE),'.txt'),maxi_dc,'delimiter','\t');

    
    
    
    maxi_dc_wrt_dm_avr=max(count_mass_dc_wrt_dm_avr);
    maxi_dc_wrt_dm_avr=transpose(maxi_dc_wrt_dm_avr);
    
    mkdir(path_analysis_out,strcat('dc_wrt_dm_avr/max_1dproj/'));
    dlmwrite(strcat(path_analysis_out,'dc_wrt_dm_avr/max_1dproj/','_',num2str(rds,strcat('%0',num2str(1+floor(length(redshift_list)/10)),'d')),'_1dproj_halos_dc_wrt_dm_avr_max_z',char(redshift_list(rds)),'_NSIDE',num2str(NSIDE),'.txt'),maxi_dc_wrt_dm_avr,'delimiter','\t');

    
    
% %     % histogram fo the peaks 
%     
% %     maxi=transpose(maxi);
%     
%     bins=[0:0.1:10];
% 
%     [hist_max edges mid loc] = histcn(maxi,bins);
%     hist_max=transpose(hist_max);
% %     
% %     bins=[0:0.001:10];
% %     non_zero_ind_of_maxi=find(~hist_max(1,:)==0);
% %     
% %      fig=figure('Visible', 'off');
% %     hold on;
% %     
% %     %xlim([0 4]);
% %     bins(end)=[];
% %     plot(bins(non_zero_ind_of_maxi(1:end)),hist_max(non_zero_ind_of_maxi(1:end)),'DisplayName',strcat('z = ',char(redshift_list(rds))),'LineWidth',2);
% %     legend('show');
% %     xlabel('maximum density', 'interpreter', 'latex', 'fontsize', 20);
% %     ylabel('number count', 'interpreter', 'latex', 'fontsize', 20);
% %     set(gca,'FontName','FixedWidth');
% %     set(gca,'FontSize',16);
% %     set(gca,'linewidth',2);
% %     
% %    title({strcat('Maximum density of the '),strcat('1d projection for $G\mu=$ ',num2str(Gmu,'%.1E')),strcat('skewness',num2str(skewness(hist_max(1,:)))),strcat('kurtosis',num2str(kurtosis(hist_max(1,:))))},'interpreter', 'latex', 'fontsize', 20);
% % %     title({strcat('Maximum density of the '),strcat('1d projection for $G\mu=$ ',num2str(Gmu,'%.1E'))},'interpreter', 'latex', 'fontsize', 20);
% % 
% %     mkdir(path_analysis_out,strcat('max_1dproj/histogram_zoom/'));
% %     path_file_out=strcat(path_analysis_out,'max_1dproj/histogram_zoom/','_',num2str(rds),'_histogram_z',char(redshift_list(rds)),'.png');
% %     saveas(fig,path_file_out);
% %     
% %     hold off;
% %     
%          fig=figure('Visible', 'off');
%     hold on;
%     
%     %fix range of the above
%     %xlim([0 4]);
% %     bins=[0:0.1:10];
%     bins(end)=[];
% %     axis([0 10 0 50000]);
%     plot(bins(1,:),hist_max(1,:),'LineWidth',2);
%     legend(strcat('z = ',char(redshift_list(rds))),strcat('skewness',num2str(skewness(hist_max(1,:)))));
%     xlabel('maximum density', 'interpreter', 'latex', 'fontsize', 20);
%     ylabel('number count', 'interpreter', 'latex', 'fontsize', 20);
%     set(gca,'FontName','FixedWidth');
%     set(gca,'FontSize',16);
%     set(gca,'linewidth',2);
%     
%    title({strcat('Maximum density of the '),strcat('1d projection for $G\mu=$ ',num2str(Gmu,'%.1E')),strcat('skewness',num2str(skewness(hist_max(1,:)))),strcat('kurtosis',num2str(kurtosis(hist_max(1,:))))},'interpreter', 'latex', 'fontsize', 20);
% %     title({strcat('Maximum density of the '),strcat('1d projection for $G\mu=$ ',num2str(Gmu,'%.1E'))},'interpreter', 'latex', 'fontsize', 20);
% 
%     mkdir(path_analysis_out,strcat('max_1dproj/histogram/'));
%     path_file_out=strcat(path_analysis_out,'max_1dproj/histogram/','_',num2str(rds),'_histogram_z',char(redshift_list(rds)),'.png');
%     saveas(fig,path_file_out);
%     
%     hold off;

    
      % % signal to noise stat
  
% %     %computes the histogram
% %     
%   %  cd('../../preprocessing');
% %     
%    %  bins=[-1:0.01:10];
%   %   for i = 1:12*NSIDE^2
% %     
%  %    [result(i) edges mid loc] = histcn(count(:,i),bins);
% %     
% %     sk(:,i) = skewness(count_1d(:,i));
% %     kur(:,i)= kurtosis(count_1d(:,i));
%             
%         fig=figure('Visible', 'off');
%         %fig=figure;
%         
%      hold on;


      st = std(count_n);
      st = transpose(st);

      mkdir(path_analysis_out,strcat('number/sigma/'));  
      dlmwrite(strcat(path_analysis_out,'number/sigma/','_',num2str(rds,strcat('%0',num2str(1+floor(length(redshift_list)/10)),'d')),'_1dproj_halos_std_z',char(redshift_list(rds)),'_NSIDE',num2str(NSIDE),'.txt'),st,'delimiter','\t');
      
      mkdir(path_analysis_out,strcat('number/sig_to_noise/'));  
      dlmwrite(strcat(path_analysis_out,'number/sig_to_noise/','_',num2str(rds,strcat('%0',num2str(1+floor(length(redshift_list)/10)),'d')),'_1dproj_sig_halos_to_noise_z',char(redshift_list(rds)),'_NSIDE',num2str(NSIDE),'.txt'),maxi(:,1)./st(:,1),'delimiter','\t')
      
      st_dc = std(count_mass_dc);
      st_dc = transpose(st_dc);

      mkdir(path_analysis_out,strcat('dc/sigma/'));  
      dlmwrite(strcat(path_analysis_out,'dc/sigma/','_',num2str(rds,strcat('%0',num2str(1+floor(length(redshift_list)/10)),'d')),'_1dproj_halos_std_dc_z',char(redshift_list(rds)),'_NSIDE',num2str(NSIDE),'.txt'),st_dc,'delimiter','\t');
      
      mkdir(path_analysis_out,strcat('dc/sig_to_noise/'));  
      dlmwrite(strcat(path_analysis_out,'dc/sig_to_noise/','_',num2str(rds,strcat('%0',num2str(1+floor(length(redshift_list)/10)),'d')),'_1dproj_sig_dc_halos_to_noise_z',char(redshift_list(rds)),'_NSIDE',num2str(NSIDE),'.txt'),maxi_dc(:,1)./st_dc(:,1),'delimiter','\t')
    

    
      st_dc_wrt_dm_avr = std(count_mass_dc_wrt_dm_avr);
      st_dc_wrt_dm_avr = transpose(st_dc_wrt_dm_avr);

      mkdir(path_analysis_out,strcat('dc_wrt_dm_avr/sigma/'));  
      dlmwrite(strcat(path_analysis_out,'dc_wrt_dm_avr/sigma/','_',num2str(rds,strcat('%0',num2str(1+floor(length(redshift_list)/10)),'d')),'_1dproj_halos_std_dc_z',char(redshift_list(rds)),'_NSIDE',num2str(NSIDE),'.txt'),st_dc_wrt_dm_avr,'delimiter','\t');
      
      mkdir(path_analysis_out,strcat('dc_wrt_dm_avr/sig_to_noise/'));  
      dlmwrite(strcat(path_analysis_out,'dc_wrt_dm_avr/sig_to_noise/','_',num2str(rds,strcat('%0',num2str(1+floor(length(redshift_list)/10)),'d')),'_1dproj_sig_dc_halos_to_noise_z',char(redshift_list(rds)),'_NSIDE',num2str(NSIDE),'.txt'),maxi_dc_wrt_dm_avr(:,1)./st_dc_wrt_dm_avr(:,1),'delimiter','\t')
    
      
      
      
    
end

cd('../wake_detection/box_statistics');

end

