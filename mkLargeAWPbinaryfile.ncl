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

if (.not.all(ismissing(lsmask))) then               ; Check that lsmask has no missing values, if not, continue with loop
    do i=262.5,350.5                                ; Do the following loop between i=262.5 and i=350.5
    do j=30.5,17.5,1                                ; Do the following loop between j=30.5 and j=17.5 (this will happen for every i between 262.5 and 350.5
            if (lsmask(:,{j},{i}) .ne. 0)then       ; If the value of lsmask at the specified coordinates is not equal to zero, then
                ocean(:,{j},{i}) = 1                  ; Set the value of ocean at these given coordinates to one
            else                                    ; Or else, if condition in line 26 not met,
                ocean(:,{j},{i})=0                    ; Set the value of ocean at these given coordinates to zero
            end if                                  ; Ending all the loops
    end do
    end do
;------ second region of AWP
    do i=270.5,350.5
    do j=17.5,14.5,1
            if (lsmask(:,{j},{i}) .ne. 0)then
                ocean(:,{j},{i}) = 1
            else
                ocean(:,{j},{i})=0
            end if
    end do
    end do
;------ third region of AWP
    do i=275.5,350.5
    do j=14.5,10.5,1
            if (lsmask(:,{j},{i}) .ne. 0)then
                ocean(:,{j},{i}) = 1
            else
                ocean(:,{j},{i})=0
            end if
    end do
    end do
;------ fourth region of AWP (otherside of landbridge)
        do i=283.5,350.5
        do j=10.5,4.5,1
            if (lsmask(:,{j},{i}) .ne. 0)then
                ocean(:,{j},{i}) = 1
            else
                ocean(:,{j},{i})=0
            end if
        end do
        end do
end if
;------ building landbridge, demarcating water on the Atlantic side.
printVarSummary(ocean)
ocean(:,{10.5},{276.5})=0
ocean(:,{9.5},{278.5 :282.5})=1
ocean(:,{8.5},{279.5})=1

printVarSummary(ocean)
fh=addfile("/Users/orris012/Data/OISST/lrgawpsstbinary.nc", "c")
fh->ocean = ocean
