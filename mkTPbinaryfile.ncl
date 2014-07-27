    ; loading our libraries...

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------


a=addfile("/Users/orris012/Data/OISST/sst.mnmean.nc", "r")
b=addfile("/Users/orris012/Data/OISST/lsmask.nc", "r")

lsmask=short2flt(b->mask)

ocean=new((/390,180,360/),float,0)
time=fspan(66443,78282,390)
lat=fspan(-89.5,89.5,180)
lon=fspan(0.5,359.5,360)
ocean!0="time"
ocean&time=time
ocean!1="lat"
ocean&lat=lat
ocean!2="lon"
ocean&lon=lon

ocean(:,:,:)=0
ocean(:,{-4.5:5.5},{190.5:240.5})=1

printVarSummary(ocean)
fh=addfile("/Users/orris012/Data/OISST/tpsstbinary.nc", "c")
fh->ocean = ocean