function wp=fill_wp(fp, fp_index) 
% This function creates and fills a structure with the minimum data 
% retrieved from a LIDO flighplan 
% Input:  
%       fp = LIDO flighplan from SimBrief 
%       fp_index = Number of waypoint in flightplan to import 
% Output: 
%       wp:wp structure with the following fields:
%           name,lat,lon,alt,desc,tas,head,gs,track,vr,wind,wdir,dist,time

 wp = create_wp(); 
 
%Waypoint names and coordinates: 
wp.name = fp.OFP.navlog.fix{1, fp_index}.ident.Text; 
wp.desc = fp.OFP.navlog.fix{1, fp_index}.name.Text; 
wp.lat  = str2num(fp.OFP.navlog.fix{1, fp_index}.pos_lat.Text);
wp.lon  = str2num(fp.OFP.navlog.fix{1, fp_index}.pos_long.Text); 

% Wind forecast at each waypoint: 
wp.wdir=str2num(fp.OFP.navlog.fix{1, fp_index}.wind_dir.Text);
wp.wind=str2num(fp.OFP.navlog.fix{1, fp_index}.wind_spd.Text); 

end 