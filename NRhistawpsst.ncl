load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"                    ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

files=systemfunc("ls /Users/orris012/Data/CNRM-CM5/historical/tos_Omon_CNRM-CM5_historical_r1i1p1_*.nc")
allfiles=addfiles(files, "r")
    ;loading some of the global files, converting K to C, time to annual data
glblsst=allfiles[13:15]->tos
glblsst=glblsst-273.15
glblsst@units="deg C"
daysince=allfiles[13:15]->time
yyyymm=cd_calendar(daysince,-1)
annsst=month_to_annual_weighted(yyyymm(0:311),glblsst(0:311,:,:),1)
annsst!1="latitude"  ;j is lat
annsst!2="longitude" ;i is lon
    ;make a new array to fill in for just the AWP with ssts
hist=new((/26,292,362/),float,1e+20)
copy_VarMeta(annsst,hist)
    ;fill in hist with ssts
        hist(:,178:193,189:248)=where(annsst(:,178:193,189:248).ne.0,annsst(:,178:193,189:248),annsst@_FillValue)
        hist(:,175:178,200:248)=where(annsst(:,175:178,200:248).ne.0,annsst(:,175:178,200:248),annsst@_FillValue)
        hist(:,170:175,203:248)=where(annsst(:,170:175,203:248).ne.0,annsst(:,170:175,203:248),annsst@_FillValue)
        hist(:,168:170,205:248)=where(annsst(:,168:170,205:248).ne.0,annsst(:,168:170,205:248),annsst@_FillValue)
        hist(:,161:168,211:248)=where(annsst(:,161:168,211:248).ne.0,annsst(:,161:168,211:248),annsst@_FillValue)
        
    ;Weighted area avgs
rad= 4.0*atan(1.0)/180.0
lat=fspan(0,179,292)
clat= cos(lat*rad)
clat!0="latitude"
clat&latitude=lat
    
avgannsst=wgt_areaave_Wrap(hist,clat,1.0,0)
printVarSummary(avgannsst)
fh=addfile("/Users/orris012/Data/CNRM-CM5/historical/awpSST.nc", "c")
fh->sst=avgannsst