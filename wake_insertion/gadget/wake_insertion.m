function [  ] = wake_insertion(path_in,file_in,path_out,file_out ,Gmu,z_insert)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%(example) wake_insertion('/home/asus/Dropbox/extras/storage/laptop/simulations_gadget/32Mpc_64c_64p_zi63_nowakem/sample0001/gadget_out/','snapshot_001','/home/asus/Dropbox/extras/storage/laptop/simulations_gadget/32Mpc_64c_64p_zi63_wakeGmu1t10m7zi31m/sample0001/ic/','ics_gadget',1E-7,31)

% filename_in='/home/asus/Programs/Gadget-2.0.7/cosmology/old/snapshot_000';
% path_out='/home/asus/Programs/Gadget-2.0.7/ICs/';
% mkdir(path_out,'wake');
% filename_out=strcat(path_out,'wake/','ics_cosmo_64p.dat');

 cd('../../gadget/processing');

% filename_in=strcat(path_in,file_in);
% filename_out=strcat(path_out,file_out);

mkdir(path_out);

xv_files_list=dir(strcat(path_in,file_in,'*'));
xv_files_list={xv_files_list.name};
xv_files_list=sort_nat(xv_files_list);

% Gmu=1E-5;
% z_insert=31;

Mpc_to_km=3.086e+19;

cd('../../parameters')

[ h OmegaBM OmegaCDM OmegaM OmegaL clight zi t_0 Hzero tensor_tilt spectral_indice sigma8 T_cmb_t0 Scalar_amplitude ] = cosmology(  );

vSgammaS=clight*(sqrt(3))/3; %speed of cosmic string times Lorentz factor in Mpc per second units*/

displacement=((12*3.14)/5)*Gmu*t_0*vSgammaS*(sqrt(1+zi))/(1+z_insert);    %displacement in comoving coordinates

vel_pert=((8.*3.14)/5.)*(Gmu)*vSgammaS*(sqrt(1+zi))*(sqrt(1+(z_insert)));  %velocity perturbation in comoving coordinates

for out = 1 : length(xv_files_list)

file_i=char(xv_files_list(out));
% fid_o=char(xv_files_list(out));

node=file_i(strfind(file_i,'.')+1:end);

filename_in=strcat(path_in,file_i);
filename_out=strcat(path_out,file_out,'.',node);
   
%%now we will read, modify and write the snapshot


%read header

fid = fopen(strcat(filename_in));
block_size_1_head=fread(fid, 1, 'uint','l') ;
Npart=fread(fid, [6 1], 'uint','l') ;
Massarr=fread(fid, [6 1], 'double','l') ;
Time=fread(fid,1, 'double','l') ;
Redshift=fread(fid,1, 'double','l') ;
FlagSfr=fread(fid, 1, 'int','l') ;
FlagFeedback=fread(fid, 1, 'int','l') ;
Nall=fread(fid, [6 1], 'int','l') ;
FlagCooling=fread(fid, 1, 'int','l') ;
NumFiles=fread(fid, 1, 'int','l') ;
BoxSize=fread(fid,1, 'double','l') ;
Omega0=fread(fid,1, 'double','l') ;
OmegaLambda=fread(fid,1, 'double','l') ;
HubbleParam=fread(fid,1, 'double','l') ;
FlagAge=fread(fid, 1, 'int','l') ;
FlagMetals=fread(fid, 1, 'int','l') ;
NallHW=fread(fid, [6 1], 'int','l') ;
flag_entr_ics=fread(fid, 1, 'int','l') ;
garbage=fread(fid, [15 1], 'int','l') ;
block_size_1_tail=fread(fid, 1, 'uint','l') ;



%write header

fid_o = fopen(filename_out,'w');
fwrite(fid_o,block_size_1_head,'uint','l');
fwrite(fid_o,Npart,'uint','l'); 
fwrite(fid_o,Massarr,'double','l');
fwrite(fid_o,Time,'double','l');
fwrite(fid_o,Redshift,'double','l');
fwrite(fid_o,FlagSfr,'int','l');
fwrite(fid_o,FlagFeedback,'int','l');
fwrite(fid_o,Nall,'int','l');
fwrite(fid_o,FlagCooling,'int','l');
fwrite(fid_o,NumFiles,'int','l');
fwrite(fid_o,BoxSize,'double','l');
fwrite(fid_o,Omega0,'double','l');
fwrite(fid_o,OmegaLambda,'double','l');
fwrite(fid_o,HubbleParam,'double','l');
fwrite(fid_o,FlagAge,'int','l');
fwrite(fid_o,FlagMetals,'int','l');
fwrite(fid_o,NallHW,'int','l');
fwrite(fid_o,flag_entr_ics,'int','l');
fwrite(fid_o,garbage,'int','l');
fwrite(fid_o,block_size_1_tail,'int','l');

% read positions

block_size_2_head=fread(fid, 1, 'uint','l') ;
pos_0=fread(fid, [3 Npart(1+0)], 'single','l') ;
pos_1=fread(fid, [3 Npart(1+1)], 'single','l') ;
pos_2=fread(fid, [3 Npart(1+2)], 'single','l') ;
pos_3=fread(fid, [3 Npart(1+3)], 'single','l') ;
pos_4=fread(fid, [3 Npart(1+4)], 'single','l') ;
pos_5=fread(fid, [3 Npart(1+5)], 'single','l') ;
block_size_2_tail=fread(fid, 1, 'uint','l') ;


%displace towards the wake
        
        dist_to_wake3=pos_1(3,:)-BoxSize/2; %is the vector that points to the wake at Z=nc/2 plane
%         displacement_to_wake3=-sign(pos_1(3,:)-BoxSize/2)*displacement; %the particles will be displaced towards the wake
        pos_1(3,:)=pos_1(3,:)-sign(dist_to_wake3)*displacement;

% write positions

fwrite(fid_o,block_size_2_head,'uint','l');
fwrite(fid_o,pos_0,'single','l');
fwrite(fid_o,pos_1,'single','l');
fwrite(fid_o,pos_2,'single','l');
fwrite(fid_o,pos_3,'single','l');
fwrite(fid_o,pos_4,'single','l');
fwrite(fid_o,pos_5,'single','l');
fwrite(fid_o,block_size_2_tail,'uint','l');

clearvars pos_1

%read velocities

block_size_3_head=fread(fid, 1, 'uint','l') ;
vel_0=fread(fid, [3 Npart(1+0)], 'single','l') ;
vel_1=fread(fid, [3 Npart(1+1)], 'single','l') ;
vel_2=fread(fid, [3 Npart(1+2)], 'single','l') ;
vel_3=fread(fid, [3 Npart(1+3)], 'single','l') ;
vel_4=fread(fid, [3 Npart(1+4)], 'single','l') ;
vel_5=fread(fid, [3 Npart(1+5)], 'single','l') ;
block_size_3_tail=fread(fid, 1, 'uint','l') ;

 %give hte velocity kick
        
%         kick_to_wake3=-sign(dist_to_wake3(1,:))*vel_pert;
        vel_1(3,:)=vel_1(3,:)-sign(dist_to_wake3(1,:))*vel_pert*Mpc_to_km*(1/(1+z_insert));

%write velocities

fwrite(fid_o,block_size_3_head,'uint','l');
fwrite(fid_o,vel_0,'single','l');
fwrite(fid_o,vel_1,'single','l');
fwrite(fid_o,vel_2,'single','l');
fwrite(fid_o,vel_3,'single','l');
fwrite(fid_o,vel_4,'single','l');
fwrite(fid_o,vel_5,'single','l');
fwrite(fid_o,block_size_3_tail,'uint','l');

clearvars vel_1 dist_to_wake3

%read particle ids

block_size_4_head=fread(fid, 1, 'uint','l') ;
pid_0=fread(fid, [1 Npart(1+0)], 'uint','l') ;
pid_1=fread(fid, [1 Npart(1+1)], 'uint','l') ;
pid_2=fread(fid, [1 Npart(1+2)], 'uint','l') ;
pid_3=fread(fid, [1 Npart(1+3)], 'uint','l') ;
pid_4=fread(fid, [1 Npart(1+4)], 'uint','l') ;
pid_5=fread(fid, [1 Npart(1+5)], 'uint','l') ;
block_size_4_tail=fread(fid, 1, 'uint','l') ;

%write particle ids

fwrite(fid_o,block_size_4_head,'uint','l');
fwrite(fid_o,pid_0,'uint','l');
fwrite(fid_o,pid_1,'uint','l');
fwrite(fid_o,pid_2,'uint','l');
fwrite(fid_o,pid_3,'uint','l');
fwrite(fid_o,pid_4,'uint','l');
fwrite(fid_o,pid_5,'uint','l');
fwrite(fid_o,block_size_4_tail,'uint','l');


%from now on a more carefull test must be made, since only the pure dm case
%was tested

%read Variable particle masses

Nm=int8(dot(single(Massarr==0),single(Npart~=0)));

block_size_5_head=fread(fid, int8(Nm~=0), 'uint','l') ;
var_masses=fread(fid, [1 Nm], 'single','l') ;
block_size_5_tail=fread(fid, Nm, 'uint','l') ;

%write Variable particle masses

fwrite(fid_o,block_size_5_head,'uint','l');
fwrite(fid_o,var_masses,'single','l');
fwrite(fid_o,block_size_5_tail,'uint','l');

%read internal energy gas

block_size_6_head=fread(fid, int8(Npart(1+0)~=0), 'uint','l') ;
u=fread(fid, [1 Npart(1+0)], 'single','l') ;
block_size_6_tail=fread(fid, int8(Npart(1+0)~=0), 'uint','l') ;

%write internal energy gas

fwrite(fid_o,block_size_6_head,'uint','l');
fwrite(fid_o,u,'single','l');
fwrite(fid_o,block_size_6_tail,'uint','l');

%read density gas

block_size_7_head=fread(fid, int8(Npart(1+0)~=0), 'uint','l') ;
rho=fread(fid, [1 Npart(1+0)], 'single','l') ;
block_size_7_tail=fread(fid, int8(Npart(1+0)~=0), 'uint','l') ;

%write density gas

fwrite(fid_o,block_size_7_head,'uint','l');
fwrite(fid_o,rho,'single','l');
fwrite(fid_o,block_size_7_tail,'uint','l');


%read smoothing length gas

block_size_8_head=fread(fid, int8(Npart(1+0)~=0), 'uint','l') ;
hsml=fread(fid, [1 Npart(1+0)], 'single','l') ;
block_size_8_tail=fread(fid, int8(Npart(1+0)~=0), 'uint','l') ;

%write smoothing length gas

fwrite(fid_o,block_size_8_head,'uint','l');
fwrite(fid_o,hsml,'single','l');
fwrite(fid_o,block_size_8_tail,'uint','l');


%%%%%
%from now one there will be problems if we want to recover those following
%quantities (will not affect a sucesfull copy-paste) since its presence
%(maximum four blocks) is determined in compilation and not know here
%%%%%

%read gravitational potential

block_size_9_head=fread(fid, 1, 'uint','l') ;
pot=fread(fid, [1 block_size_9_head/4], 'single','l') ;
block_size_9_tail=fread(fid, 1, 'uint','l') ;

%write gravitational potential

fwrite(fid_o,block_size_9_head,'uint','l');
fwrite(fid_o,pot,'single','l');
fwrite(fid_o,block_size_9_tail,'uint','l');

%read Accelerations:

block_size_10_head=fread(fid, 1, 'uint','l') ;
acc=fread(fid, [1 block_size_10_head/4], 'single','l') ;
block_size_10_tail=fread(fid, 1, 'uint','l') ;

%write Accelerations:

fwrite(fid_o,block_size_10_head,'uint','l');
fwrite(fid_o,acc,'single','l');
fwrite(fid_o,block_size_10_tail,'uint','l');

%read Rate of entropy production

block_size_11_head=fread(fid, 1, 'uint','l') ;
dAdt=fread(fid, [1 block_size_11_head/4], 'single','l') ;
block_size_11_tail=fread(fid, 1, 'uint','l') ;

%write Rate of entropy production

fwrite(fid_o,block_size_11_head,'uint','l');
fwrite(fid_o,dAdt,'single','l');
fwrite(fid_o,block_size_11_tail,'uint','l');


%read Timesteps of particles

block_size_12_head=fread(fid, 1, 'uint','l') ;
dt=fread(fid, [1 block_size_12_head/4], 'single','l') ;
block_size_12_tail=fread(fid, 1, 'uint','l') ;

%write Timesteps of particles

fwrite(fid_o,block_size_12_head,'uint','l');
fwrite(fid_o,dt,'single','l');
fwrite(fid_o,block_size_12_tail,'uint','l');



fclose(fid);
fclose(fid_o);

system(char(strcat({'ln -s '},{' '},{filename_out},{' '},{strcat(path_out,file_out,'.dat.',node)})))
system(char(strcat({'ln -s '},{' '},{filename_out},{' '},{strcat(path_out,file_out,'.dat',node)})))

% display(char(strcat({'ln -s '},{' '},{strcat(path_out,file_out,'.dat.',node)},{' '},{filename_out})));

end

cd('../wake_insertion/gadget');

end

