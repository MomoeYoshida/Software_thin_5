function [correlation_map]=get_correlation_map(obs_map, lmin, lmax);
% Function to create correlation map from observation map.

% Create square matrices (lmin x lmin and lmax x lmax) filled with ones.
% These matrices will act as convolution kernels to count how many valid observations are in a local window of size lmin x lmin and lmax x lmax.
use1=ones(lmin);
use2=ones(lmax);

% Perform a 2D convolution.
% e.g., c1(i,j) counts how many 1s (i.e., valid obs) are in the lmin x lmin window centered at (i,j); over every single pixel.
c1=conv2(obs_map,use1,'same'); % 'same' ensures the output is the same size as the input map; inside a 8x8 box
c2=conv2(obs_map,use2,'same'); % inside a 32x32 box

% Calculate the total number of grid cells in the lmin and lmax windows (i.e., for normalization).
n1=lmin*lmin;
n2=lmax*lmax;

% Calculate a weight alpha between 0 and 1 to decide which box size to trust more.
% low alpha: high density, closer to lmin
% high alpha: low density, closer to lmax
% c1/n1 = local small-scale data density
% c2/n2 = local large-scale data density
alpha=2/pi*atan2((c2/n2),(1-c1/n1));

% A weighted interpolation between lmax and lmin.
% Blend the two box sizes (8 & 32) together based on that alpha
% low alpha: high density, near lmin >>> 8
% high alpha: low density, approach lmax >>> 32
correlation_map=lmax*(1-alpha)+alpha*lmin;
  
