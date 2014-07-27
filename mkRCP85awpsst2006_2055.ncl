    ; loading our libraries...

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

    ;load global data file
files=systemfunc("ls /Volumes/data4/atmos/hardi091/CMIP5/RCP8.5/modeloutput/tos/tos_Omon_CNRM-CM5_rcp85_r1i1p1_*.nc")
allfiles=addfiles(files, "r")
    ;loading some of the global files, converting time to annual data
glblsst=allfiles[0:4]->tos
daysince=allfiles[0:4]->time
yyyymm=cd_calendar(daysince,-1)
annfutsst=month_to_annual_weighted(yyyymm(0:599),glblsst(0:599,:,:),1)
annfutsst!1="latitude"  ;j is lat
annfutsst!2="longitude" ;i is lon
annfutsst@_FillValue=0
    ; change from K to C

;printVarSummary(annfutsst)     ;annfutsst has annual data for the AWP from the rcp8.5. where there is no sst data, value 0 is used

    ;make a new array to fill in for just the AWP with ssts
futawp=new((/50,292,362/),float,0)
copy_VarMeta(annfutsst,futawp)
;printVarSummary(futawp)
    ;fill in futawp with ssts
        futawp(:,178:193,189:248)=where(annfutsst(:,178:193,189:248).ne.0,annfutsst(:,178:193,189:248),annfutsst@_FillValue)
        futawp(:,175:178,200:248)=where(annfutsst(:,175:178,200:248).ne.0,annfutsst(:,175:178,200:248),annfutsst@_FillValue)
        futawp(:,170:175,203:248)=where(annfutsst(:,170:175,203:248).ne.0,annfutsst(:,170:175,203:248),annfutsst@_FillValue)
        futawp(:,168:170,205:248)=where(annfutsst(:,168:170,205:248).ne.0,annfutsst(:,168:170,205:248),annfutsst@_FillValue)
        futawp(:,161:168,211:248)=where(annfutsst(:,161:168,211:248).ne.0,annfutsst(:,161:168,211:248),annfutsst@_FillValue)
fh=addfile("/Users/orris012/Data/CNRM-CM5/RCP8.5/RCP85awpsst.nc", "rw")
fh->ssts=futawp
  t = fh->ssts              ; degK
  t = t - 273.15            ; change values
  t@units = "deg C"          ; update appropriate attribute

  fh->ssts = t               ; overwrite
