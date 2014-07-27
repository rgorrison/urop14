    ; loading our libraries...

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

a=addfile("/Users/orris012/Data/OISST/tpsst.nc", "r")

sst=(a->pactmp)
sst@_FillValue=0.

; weighted area avgs
    rad    = 4.0*atan(1.0)/180.0
    lat=a->lat
    clat   = cos(lat*rad)
    clat!0="latitude"
    clat&latitude=lat

wgtareasst=wgt_areaave_Wrap(sst,clat(:),1.0,0)  ; weighted averages for the region, value/389 months
printVarSummary(wgtareasst)
time=a->time
yyyymm=cd_calendar(time,-1)
annsst=month_to_annual_weighted(yyyymm(1:384),wgtareasst(1:384),1)

stddevsst=dim_stddev_n_Wrap(annsst,0)

;data
    x=ispan(1982,2013,1)
    data=new((/4,dimsizes(x)/),float)
    data(0,:)=annsst
reg=regline(x,annsst)
    data(1,:)=reg*x+reg@yintercept
    data(2,:)=data(1,:)+stddevsst
    data(3,:)=data(1,:)-stddevsst
printVarSummary(reg)
print(reg)
;plotting

wks=gsn_open_wks("pdf", "TimSerBaseTPsst")
res=True
res@gsnFrame    = False
res@gsnDraw     = False

    res@gsnPaperOrientation = "auto"
    res@gsnMaximize=True
    res@tiMainString="Average Annual ENSO 3.4 Sea Surface Temperature, 1982-2013, OISST"
    res@tiMainFontHeightF = 0.015
    res@tmXTOn=False
    res@tmYROn=False
    res@xyLineColors =(/"black","red","blue","blue"/)
    res@tiYAxisString="Degrees (C)"
    res@tiXAxisString="Year"
    res@trYMaxF=29.0
    res@trYMinF=25.0
    res@vpWidthF=1.0
    res@xyDashPatterns    = 0                         ; choose dash patterns

;Set up resources for a customized legend.

  lgres                    = True
  lgres@lgLineColors       = (/"blue","red","black"/)
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .6            ; legend label font thickness
  lgres@vpWidthF           = 0.18           ; width of legend (NDC)
  lgres@vpHeightF          = 0.12           ; height of legend (NDC)
  lgres@lgPerimOn          = False
  lgres@lgMonoDashIndex    = True
  lgres@lgMonoMarkerThickness = True
  lgres@legMarkerThicknessF = 1.5
  lgres@lgDashIndex        = 0

labels =(/"   One std. dev. from Mean","   Annual SST Regression","   Average Annual Sea Surface Temperature"/)
nitems = dimsizes(labels)                

amres                  = True
    amres@amJust           = "BottomRight"    ; Use bottom right corner of box
; for determining its location, where (0,0) is center of plot
  amres@amParallelPosF   = -0.09              ; Move legend to right
  amres@amOrthogonalPosF = 0.5              ; Move legend down

; Create legend
    lbid = gsn_create_legend(wks,nitems,labels,lgres)
;make plot
    plot=gsn_csm_xy(wks,x,data,res)
;add legend to plot
   annoid = gsn_add_annotation(plot,lbid,amres)
       
tres  =  True
tres@txFontHeightF = 0.02
gsn_text(wks,plot,"y=-0.014x+54.94",2005,25.5,tres)

    pdfres=True
    maximize_output(wks,pdfres)
