load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"                    ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

;This script will make a plot with six panels: 1) historical data from obsv. 2) historical model output 3) RCP4.5 from all of the 21st century, 4) RCP4.5 from half the 21st century, 3) RCP8.5 from all of the 21st century, 4) RCP8.5 from half the 21st century.

;Historical observed data
    a=addfile("/Users/orris012/Data/OISST/lrgawpsst.nc", "r")
    sst=(a->atlantmp)
    time=a->time
    yyyymm=cd_calendar(time,-1)
    annobsv=month_to_annual_weighted(yyyymm(1:288),sst(1:288,:,:),1)
;Weighted area avg
    rad    = 4.0*atan(1.0)/180.0
    lat=a->lat
    clat   = cos(lat*rad)
    clat!0="latitude"
    clat&latitude=lat

    histobsv=wgt_areaave_Wrap(annobsv,clat(:),1.0,0)

;RCP4.5 long model output
    c=addfile("/Users/orris012/Data/GFDL-CM3/RCP4.5/lrgawpSST2006_2100.nc", "r")
    longrcp45=c->sst

;RCP4.5 short model output
    d=addfile("/Users/orris012/Data/GFDL-CM3/RCP4.5/lrgawpSST2006_2100.nc", "r")
    rcp45=c->sst({2050:2100})

;Historical CNRM-CM5 model output
    b=addfile("/Users/orris012/Data/GFDL-CM3/historical/lrgawpSST.nc", "r")
    histmod=b->sst({1982:2005})

;RCP8.5 long model output
    e=addfile("/Users/orris012/Data/GFDL-CM3/RCP8.5/lrgawpSST2006_2100.nc","r")
    longrcp85=e->sst

;RCP8.5 short model output
    e=addfile("/Users/orris012/Data/GFDL-CM3/RCP8.5/lrgawpSST2006_2100.nc","r")
    rcp85=e->sst({2050:2100})

;printVarSummary(histobsv)
;printVarSummary(longrcp45)
;printVarSummary(rcp45)
;printVarSummary(histmod)
;printVarSummary(longrcp85)
;printVarSummary(rcp85)

;-----------------------------
;Data
;-----------------------------

;0, historic obsv
stddev0=dim_stddev_n_Wrap(histobsv,0)
    x0=ispan(1982,2005,1)
    data0=new((/4,dimsizes(x0)/),float)
    data0(0,:)=histobsv
reg0=regline(x0,histobsv)
    data0(1,:)=reg0*x0+reg0@yintercept
    data0(2,:)=data0(1,:)+stddev0
    data0(3,:)=data0(1,:)-stddev0

;1, longrcp4.5
stddev1=dim_stddev_n_Wrap(longrcp45,0)
    x1=ispan(2006,2100,1)
    data1=new((/4,dimsizes(x1)/),float)
    data1(0,:)=longrcp45
reg1=regline(x1,longrcp45)
    data1(1,:)=reg1*x1+reg1@yintercept
    data1(2,:)=data1(1,:)+stddev1
    data1(3,:)=data1(1,:)-stddev1
printVarSummary(reg1)
;2, shortrcp4.5
stddev2=dim_stddev_n_Wrap(rcp45,0)
    x2=ispan(2050,2100,1)
    data2=new((/4,dimsizes(x2)/),float)
    data2(0,:)=rcp45
reg2=regline(x2,rcp45)
    data2(1,:)=reg2*x2+reg2@yintercept
    data2(2,:)=data2(1,:)+stddev2
    data2(3,:)=data2(1,:)-stddev2

;3, historic model output
stddev3=dim_stddev_n_Wrap(histmod,0)
    x3=ispan(1982,2005,1)
    data3=new((/4,dimsizes(x3)/),float)
    data3(0,:)=histmod
reg3=regline(x3,histmod)
    data3(1,:)=reg3*x3+reg3@yintercept
    data3(2,:)=data3(1,:)+stddev3
    data3(3,:)=data3(1,:)-stddev3

;4, longrcp8.5
stddev4=dim_stddev_n_Wrap(longrcp85,0)
    x4=ispan(2006,2100,1)
    data4=new((/4,dimsizes(x4)/),float)
    data4(0,:)=longrcp85
reg4=regline(x4,longrcp85)
    data4(1,:)=reg4*x4+reg4@yintercept
    data4(2,:)=data4(1,:)+stddev4
    data4(3,:)=data4(1,:)-stddev4

;5, shortrcp8.5
stddev5=dim_stddev_n_Wrap(rcp85,0)
    x5=ispan(2050,2100,1)
    data5=new((/4,dimsizes(x5)/),float)
    data5(0,:)=rcp85
reg5=regline(x5,rcp85)
    data5(1,:)=reg5*x5+reg5@yintercept
    data5(2,:)=data5(1,:)+stddev5
    data5(3,:)=data5(1,:)-stddev5

;-----------------------------
;Plotting
;-----------------------------

wks=gsn_open_wks("pdf","GFDLlrgawpsst")
res=True

res@gsnDraw=False
res@gsnFrame=False

pnlres=True
pnlres@txString="Time Series of Full Atlantic Warming Pool SST: Observations and GFDL-CM3"
plots=new(6,graphic)

;Plot 0
    res@gsnPaperOrientation = "auto"
    res@gsnMaximize=True
    res@tiMainString="Average Annual Full AWP Sea Surface Temperature 1982-2013, OISST"
    res@tiMainFontHeightF = 0.015
    res@tmXTOn=False
    res@tmYROn=False
    res@xyLineColors =(/"black","red","blue","blue"/)
    res@tiYAxisString="Degrees (C)"
    res@tiXAxisString="Year"
    res@trYMaxF=29.0
    res@trYMinF=24.0
    res@vpWidthF=1.0
    res@xyDashPatterns    = 0                         ; choose dash patterns

    plots(0)=gsn_csm_xy(wks,x0,data0,res)

    txres=True
    txres@txFontHeightF = 0.02
    label = "Standard deviation is "+ decimalPlaces(reg0@rstd,4,True) +""
    t = gsn_add_text(wks,plots(0),label,2000,24.5 ,txres)

;Plot 1
    res1=res   
    res1=True
    res1@tiMainString="Average Annual Full AWP Sea Surface Temperature 2006-2100, RCP4.5"

    plots(1)=gsn_csm_xy(wks,x1,data1,res1)
    
    txres=True
    txres@txFontHeightF = 0.02
    label = "Standard deviation is "+ decimalPlaces(reg1@rstd,4,True) +""
    t = gsn_add_text(wks,plots(1),label,2070,24.5 ,txres)

;Plot 2
    res2=res
    res2=True
    res2@tiMainString="Average Annual Full AWP Sea Surface Temperature 2006-2100, RCP4.5"

    plots(2)=gsn_csm_xy(wks,x2,data2,res2)

;Plot 3
    res3=res
    res3=True
    res3@tiMainString="Average Annual Full AWP Sea Surface Temperature 1982-2005, GFDL-CM3"

;Set up resources for a customized legend.

  lgres                    = True
  lgres@lgLineColors       = (/"blue","red","black"/)
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .61            ; legend label font thickness
  lgres@vpWidthF           = 0.25           ; width of legend (NDC)
  lgres@vpHeightF          = 0.25           ; height of legend (NDC)
  lgres@lgPerimOn          = False
  lgres@lgMonoDashIndex    = True
  lgres@lgMonoMarkerThickness = True
  lgres@legMarkerThicknessF = 1.5
  lgres@lgDashIndex        = 0
  
 labels =(/"   One std. dev. from Mean","   Annual SST Regression","   Average Annual Sea Surface Temperature"/)
nitems = dimsizes(labels)

    amres                  = True
    amres@amJust           = "TopRight"        ; Lg location, (0,0) is center of plot
    amres@amParallelPosF   = .1             ; Move legend to right
    amres@amOrthogonalPosF = .9               ; Move legend down

; Create legend
    lbid = gsn_create_legend(wks,nitems,labels,lgres)
    ;add legend to plot

    plots(3)=gsn_csm_xy(wks,x3,data3,res3)

   annoid0 = gsn_add_annotation(plots(3),lbid,amres)


;Plot 4
    res4=res
    res4=True
    res4@tiMainString="Average Annual Full AWP Sea Surface Temperature 2006-2100, RCP8.5"

    plots(4)=gsn_csm_xy(wks,x4,data4,res4)


;Plot 5
    res5=res
    res5=True
    res5@tiMainString="Average Annual Full 0AWP Sea Surface Temperature 2006-2100, RCP8.5"

    plots(5)=gsn_csm_xy(wks,x5,data5,res5)



gsn_panel(wks,(/plots/),(/2,3/),pnlres)     ; the command that puts the panels on the page together (/rows,columns/)


