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
futlrgawp=new((/50,292,362/),float,0)
copy_VarMeta(annfutsst,futlrgawp)
;printVarSummary(futlrgawp)
    ;fill in futawp with ssts
        futlrgawp(:,178:193,189:278)=where(annfutsst(:,178:193,189:278).ne.0,annfutsst(:,178:193,189:278),annfutsst@_FillValue)
        futlrgawp(:,175:178,200:278)=where(annfutsst(:,175:178,200:278).ne.0,annfutsst(:,175:178,200:278),annfutsst@_FillValue)
        futlrgawp(:,170:175,203:278)=where(annfutsst(:,170:175,203:278).ne.0,annfutsst(:,170:175,203:278),annfutsst@_FillValue)
        futlrgawp(:,168:170,205:278)=where(annfutsst(:,168:170,205:278).ne.0,annfutsst(:,168:170,205:278),annfutsst@_FillValue)
        futlrgawp(:,161:168,211:278)=where(annfutsst(:,161:168,211:278).ne.0,annfutsst(:,161:168,211:278),annfutsst@_FillValue)
fh=addfile("/Users/orris012/Data/OISST/RCP85lrgawpsst.nc", "rw")
fh->ssts=futlrgawp
    ;changing degrees K to degrees C
  t = fh->ssts              ; degK
  t = t - 273.15            ; change values
  t@units = "C"             ; update appropriate attribute

  fh->ssts = t               ; overwrite
