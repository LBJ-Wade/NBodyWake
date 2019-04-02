function [  ] = curve_2d_from_2d_slices_anali_all(  )

root='/home/asus/Dropbox/extras/storage/graham/ht/';
root_anali_2d_in='/home/asus/Dropbox/extras/storage/graham/ht/data_cps512_1024_2dcurv_s5lv3_anali/';
root_anali_2d_out='/home/asus/Dropbox/extras/storage/graham/ht/data_cps512_1024_2dcurv_s5lv3_anali_all/';
root_visual_2d='/home/asus/Dropbox/extras/storage/graham/ht/data_cps512_1024_2dcurv_s5lv3_visual_all/';

filename='3.000xv0.dat';
lenght_factor=1;
resol_factor=1;
pivot=[0,0,0];
rot_angle=[1.5708,0,0];
slices=512;
% lev=2;
% sigma=5;
% step_of_degree=1;
% wavel_removal_factor=1/2;
% % snapshot=[];
% % snapshot=[13,28]*(128/32);
% snapshot=[9,29]*(128/32);
% visual_type=[1:2]; %if 1, shows the 2d proj; if 2 shows the ridgelet transformation
%  visual_in_or_out=[1,2]; %if 1 do visualization of the input, if 2 of the output

addpath('../../../../processing');
% addpath('../../../../preprocessing');



path_specs_in=strcat(root_anali_2d_in);

specs_nowake=dir(strcat(root_anali_2d_in,'/*nowake*'));
specs_nowake={specs_nowake.name};
specs_wake=dir(strcat(root_anali_2d_in,'/*wakeGmu*'));
specs_wake={specs_wake.name};

specs_list=dir(strcat(path_specs_in,'/*'));
specs_list={specs_list.name};
specs_list=sort_nat(specs_list);
specs_list=specs_list(3:end);

display(specs_list);

spec_nowake=specs_nowake{1};
path_samples_in=strcat(root_anali_2d_in,spec_nowake);
sample_list=dir(strcat(path_samples_in,'/sample*'));
sample_list=strcat('/',{sample_list.name},'/');
sample_list_nowake=sort_nat(sample_list)

spec_wake=specs_wake{1};
path_samples_in=strcat(root_anali_2d_in,spec_wake);
sample_list=dir(strcat(path_samples_in,'/sample*'));
sample_list_short=strcat('/',{sample_list.name},'/');
sample_list=strcat('/',{sample_list.name},'/half_lin_cutoff_half_tot_pert_nvpw/');
sample_list_wake=sort_nat(sample_list)
sample_list_wake_short=sort_nat(sample_list_short);

%
% fig_pk=figure;
% set(gcf, 'Position', [0 0 300 800]);
% ax_pk=axes(fig_pk);

%  fig=figure('Visible', 'off')
fig1=figure;
fig2=figure;
fig3=figure;
fig4=figure;
fig5=figure;

ax1=axes(fig1);
ax2=axes(fig2);
ax3=axes(fig3);
ax4=axes(fig4);
ax5=axes(fig5);




cd('../../../../preprocessing')
% [xv_files_list,redshift_list,nodes_list,size_box,nc,np,zi,wake_or_no_wake,multiplicity_of_files,Gmu,ziw] = preprocessing_info(root,spec,sample_list_wake{1} );
[~,redshift_list,~,~,~,~,~,~,~,~,~] = preprocessing_info(root,spec_wake,sample_list_wake_short{1} );

z_string=char(filename);
z_string=z_string(1:end-7);
z=str2num(z_string);
z_glob=z;



for w_nw=1:2
    % for w_nw=2
    
    if w_nw==1
        % [xv_files_list,redshift_list,nodes_list,size_box,nc,np,zi,wake_or_no_wake,multiplicity_of_files,Gmu,ziw] = preprocessing_info(root,spec,sample_list_wake{1} );
        [~,redshift_list,~,~,~,~,~,~,~,~,~] = preprocessing_info(root,spec_nowake,sample_list_nowake{1} );
        spec=specs_nowake{1};
        sample_list=sample_list_nowake;
        coul='b';
    else
        % [xv_files_list,redshift_list,nodes_list,size_box,nc,np,zi,wake_or_no_wake,multiplicity_of_files,Gmu,ziw] = preprocessing_info(root,spec,sample_list_wake{1} );
        [~,redshift_list,~,~,~,~,~,~,~,~,~] = preprocessing_info(root,spec_wake,sample_list_wake{1} );
        spec=specs_wake{1};
        sample_list=sample_list_wake;
        coul='r';
    end
    
    % if w_nw==1
    %              signal_nw=[];
    %     else
    %             signal_w=[];
    % end
    
    for sample = 1:length(sample_list)
        
        path_in=strcat(strcat(root_anali_2d_in,spec,char(sample_list(sample))),'anali/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2)),'-',num2str(rot_angle(3))),'ra','/','2dproj/dm/')
        
        filename=strcat(path_in,'_',num2str(find(str2num(char(redshift_list))==z_glob)),'_2dproj_curv_z',num2str(z_glob),'_anali.txt')
        
        info = dlmread(filename);
        
        anali(w_nw,sample,:,:,:)=reshape(info,slices,4,5);
        
        a(:)=max(anali(w_nw,sample,:,:,1),[],3);
        b(:)=max(anali(w_nw,sample,:,:,2),[],3);
        c(:)=max(anali(w_nw,sample,:,:,3),[],3);
        d(:)=max(anali(w_nw,sample,:,:,4),[],3);
        e(:)=max(anali(w_nw,sample,:,:,5),[],3);
        
        plot1{sample}=   plot(ax1,a,coul);
        plot2{sample}=   plot(ax2,b,coul);
        plot3{sample}=   plot(ax3,c,coul);
        plot4{sample}=   plot(ax4,d,coul);
        plot5{sample}=   plot(ax5,e,coul);
        
        clearvars a b c d
        
        hold(ax1,'on');
        hold(ax2,'on');
        hold(ax3,'on');
        hold(ax4,'on');
        hold(ax5,'on');
        
    end
    
end

set(ax1, 'YScale', 'log');
title(ax1,'map curvelet from 2dcurv plus curv');
set(ax2, 'YScale', 'log');
title(ax2,'ridgelet from sum 2dcurv curv');
set(ax3, 'YScale', 'log');
title(ax3,'ridgelet normalized from 2dcurv plus curv');
set(ax4, 'YScale', 'log');
title(ax4,'ridgelet normalized with wavelet from 2dcurv plus curv');
set(ax5, 'YScale', 'log');
title(ax5,'ridgelet normalized with 2dwavelet from 2dcurv plus curv');


nowake=reshape(permute(anali(1,1:length(sample_list_nowake),:,4,1),[1,3,2,4,5]),[1,numel(anali(1,1:length(sample_list_nowake),:,2,1))])
wake=reshape(permute(anali(2,1:length(sample_list_wake),:,4,1),[1,3,2,4,5]),[1,numel(anali(1,1:length(sample_list_wake),:,2,1))])
mean_wake=mean(wake)
mean_nowake=mean(nowake)
std_nowake=std(nowake,1)
stn_nowake=(nowake-mean_nowake)/std_nowake
stn_wake=(wake-mean_nowake)/std_nowake
mean_stn=mean(stn_wake)
std_stn=std(stn_wake,1)
mean_stn-std_stn
wake_slices = reshape(wake,[slices,length(sample_list_wake)])'
nowake_slices = reshape(nowake,[slices,length(sample_list_nowake)])'
max_wake_slices_=sort(wake_slices')
max_nowake_slices_=sort(nowake_slices')
max_wake_slices=max_wake_slices_(end,:)
max_nowake_slices=max_nowake_slices_(end,:)
mean_wake=mean(max_wake_slices)
mean_nowake=mean(max_nowake_slices)
std_nowake=std(max_nowake_slices,1)
stn_nowake=(max_nowake_slices-mean_nowake)/std_nowake
stn_wake=(max_wake_slices-mean_nowake)/std_nowake
mean_stn=mean(stn_wake)
std_stn=std(stn_wake,1)
mean_stn-std_stn


cd('../wake_detection/curvelet/curvelab/2d/')


end