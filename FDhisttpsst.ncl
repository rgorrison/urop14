load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"                    ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

files=systemfunc("ls /Users/orris012/Data/GFDL-CM3/historical/tos_Omon_GFDL-CM3_historical_r1i1p1_*.nc")
allfiles=addfiles(files, "r")
    ;loading some of the global files, converting K to C, time to annual data
glblsst=allfiles[0:5]->tos
glblsst=glblsst-273.15
glblsst@units="deg C"
daysince=allfiles[0:5]->time
yyyymm=cd_calendar(daysince,-1)
annsst=month_to_annual_weighted(yyyymm(0:311),glblsst(0:311,:,:),1)
annsst!1="latitude"  ;j is lat
annsst!2="longitude" ;i is lon
    ;make a new array to fill in for just the TP with ssts
hist=new((/26,200,360/),float,1e+20)
copy_VarMeta(annsst,hist)
    ;fill in hist with ssts

        hist(:,83:108,109:159)=where(annsst(:,83:108,109:159).ne.0,annsst(:,83:108,109:159),annsst@_FillValue)
        
    ;Weighted area avgs
rad= 4.0*atan(1.0)/180.0
lat=fspan(0,179,200)
clat= cos(lat*rad)
clat!0="latitude"
clat&latitude=lat
    
avgannsst=wgt_areaave_Wrap(hist,clat,1.0,0)
printVarSummary(avgannsst)
fh=addfile("/Users/orris012/Data/GFDL-CM3/historical/tpSST.nc", "c")
fh->sst=avgannsst