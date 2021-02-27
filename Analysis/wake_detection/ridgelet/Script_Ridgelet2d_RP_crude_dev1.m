function [ ] = Script_Ridgelet2d_RP_crude_dev1()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

clearvars;
%Construct the sample image


% nc=128;
% nc=16;
% nc=8;
% nc=9;
% nc=3;
ncx=31;ncy=3;

% ncx=nc;ncy=nc/2;
% ncx=nc;ncy=nc;

% ncx=5;ncy=32;

% X=ones(ncx,ncy);
% X=zeros(ncx,ncy);
% X(1+ncx/4:3*ncx/4,1+ncy/4:3*ncy/4)=1;

% X(:,nc/8)=1;
% X(:,nc/2)=1;
% for i=1:ncx
% %     X(i,min(max(round(i/4),1),ncy))=1;
%     X(i,10+min(max(round(i/8),1),ncy))=1;
% 
% end
% X=X+0.5*randn([ncx,ncy]);
X=randn([ncx,ncy]);

figure; imagesc(X);colorbar;

% 
% 
% nc=1+2*64;
% % nc=1+2*16;
% % nc=1+2*8;
% % nc=1+2*4;
% ncx=nc;ncy=1+(nc-1)/2;
% % ncx=nc;ncy=nc;
% X=zeros(ncx,ncy);
% X(1+(ncx-1)/4:end-(ncx-1)/4,1+(ncy-1)/4:end-(ncy-1)/4)=1;
% % X(1+3*(ncx-1)/8:end-3*(ncx-1)/8,1+3*(ncy-1)/8:end-3*(ncy-1)/8)=1;
% % X=ones(ncx,ncy);
% % 
% % nc=129;
% % ncx=nc;ncy=nc;
% % X=ones(ncx,ncy);
% 

% figure; imagesc(X);colorbar;

% figure; histogram(X(:));

%build in matlab rad transf
figure;
% theta = 0:180;
% theta-linspace()
theta = 180/nc:180/nc:180;
[R,xp] = radon(X,theta);
imagesc(theta,xp,R);colorbar;
% imagesc(R(1+(ncx-1)/4:end-(ncx-1)/4,1:(end-1)/2)); colorbar;
% imagesc(R(-(ncx-1)/4+(end+1)/2:(ncx-1)/4+(end+1)/2,1:(end-1)/2)); colorbar;

clearvars A A_ B B_ C C_
% A=rand([10,1]);
A=rand([11,1]);
for j=1:length(A)
A_(j,1)=((-1)^(j-1))*A(j);
end
B=fft(A);
B_=fft(A_);
C=ifft(B);
C_=ifft(B_);


A=rand([5,1]);
A_=[zeros(size(A));A;zeros(size(A))];
B=fft(A);
B_=fft(A_);
C=ifft(B);
C_=ifft(B_);




%Radon Transformation

[ Radon_hor_h_, Radon_vert_v_] = Ridgelet2d_RP_crude_forwards_dev1(X);


figure;imagesc(real(Radon_hor_h_)); colorbar;
xlabel('displacement', 'interpreter', 'latex', 'fontsize', 20);
ylabel('angle', 'interpreter', 'latex', 'fontsize', 20);

figure;imagesc(real(Radon_vert_v_)); colorbar;
xlabel('displacement', 'interpreter', 'latex', 'fontsize', 20);
ylabel('angle', 'interpreter', 'latex', 'fontsize', 20);


figure;imagesc(imag(Radon_hor_h_)); colorbar;
xlabel('displacement', 'interpreter', 'latex', 'fontsize', 20);
ylabel('angle', 'interpreter', 'latex', 'fontsize', 20);

figure;imagesc(imag(Radon_vert_v_)); colorbar;
xlabel('displacement', 'interpreter', 'latex', 'fontsize', 20);
ylabel('angle', 'interpreter', 'latex', 'fontsize', 20);


% figure; histogram(real(Radon_hor_(:)));
% 
% figure; histogram(real(Radon_vert_(:)));


[ X_rec_phase ] = Ridgelet2d_RP_crude_backwards_dev1( Radon_hor_h_, Radon_vert_v_ );

figure; imagesc(real(X_rec_phase));colorbar;

figure; imagesc(imag(X_rec_phase));colorbar;



max(abs(X_rec_phase(:)-X(:)))




for i=1:ncx_v+(1-is_odd_ncx_v)
    for j=1:ncy_v
        Radon_vert_phase_rec_v(i,j)=(exp(1i*pi*(j-1)*(1-is_odd_ncy_v/ncy_v)))*Radon_vert_v_(i,j);
    end
end

for i=1:ncx_h
    for j=1:ncy_h+(1-is_odd_ncy_h)
        Radon_hor_phase_rec_h(j,i)=(exp(1i*pi*(i-1)*(1-is_odd_ncx_h/ncx_h)))*Radon_hor_h_(j,i);
    end
end


% % max(abs(Radon_hor_phase_rec_h(:)-Radon_hor_h(:)))


RPinterp_vert_rec_v=(fft(Radon_vert_phase_rec_v.').');
RPinterp_hor_rec_h=(fft(Radon_hor_phase_rec_h.').');


max(abs(RPinterp_hor_rec_h(:)-RPinterp_hor_h(:)))





RPinterp_vert_rec_v=(fft(Radon_vert_v.').');
RPinterp_hor_rec_h=(fft(Radon_hor_h.').');


max(abs(RPinterp_hor_rec_h(:)-RPinterp_hor_h(:)))

% previous = fftw('planner','estimate') 

Radon_vert_v = (ifft(double(vpa(RPinterp_vert_v)).').');
RPinterp_vert_rec_v=(fft(double(vpa(Radon_vert_v)).').');


max(abs(double(vpa(RPinterp_vert_rec_v(:)-RPinterp_vert_v(:)))))



RPinterp_vert_vA=RPinterp_vert_v(1,:);

Radon_vert_v = (ifft(RPinterp_vert_vA.').');
RPinterp_vert_rec_v=(fft(Radon_vert_v.').');



max(abs(RPinterp_vert_rec_v(:)-RPinterp_vert_vA(:)))


end

