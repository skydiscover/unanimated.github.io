-- The original purpose was to cut lead out for multiple lines, since TPP can't do that.
-- While I was at it, I added a few other logical options. It's like a custom mini-TPP.
-- Leads should never overlap with previous/next line after running this [aside from shifting].

script_name="ShiftCut"
script_description="Time Machine."
script_author="unanimated"
script_version="2.31"

-- SETTINGS	these are default settings with which the GUI loads. change them as you want, but check the comments for correct values.

apply_to="Apply to selected"	-- Options: "Apply to selected","Apply to all lines"
add_leadin=false		-- true for adding leadin, false for cuting leadin
add_leadout=false		-- same for leadout
shift_right=false		-- true for shift right [forward], false for shift left [backward]
leadin_value=0			-- value for adding/cutting leadin. also accepts negative values as an alternative to the "add" checkbox
leadout_value=0			-- same for leadout
shift_value=0			-- same for shifting
line_linking_gap=400		-- gap for line linking, like in TPP. any positive value, no quotation marks.
linking_bias="0.8"		-- similar to TPP. 0.8 is 80% to the right. options: "0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","1"
fix_overlaps=false		-- [true/false] this is part of line linking. if you want only overlaps, set linking gap to 0.
overlap_value=500		-- value for fixing overlaps - overlaps smaller than this value will be fixed. [must be consecutive lines in script]
overlap_bias="0.5"		-- works same as linking bias. same options: "0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","1"
styles_to_apply_to="All Default"-- "All Default" are all styles that match 'Defa'. "Default+Alt" are any that match "Defa" or "Alt".
starts_before=0			-- just like TPP. distance from a keyframe that will be snaped. values in frames. minimum=0, maximum=250. 
ends_before=0			-- same
starts_after=0			-- same
ends_after=0			-- same
use_preset=true			-- use preset for keyframes [true/false]
kf_snap_preset="6,10,8,12"	-- options: "1,1,1,1","2,2,2,2","6,6,8,12","6,6,10,12","6,10,8,12","8,8,8,12","0,0,0,10","7,12,10,13"
prevent_cut_overlaps=true	-- prevent overlaps from adding lead in/out [true/false]
prevent_kf_overlaps=true	-- prevent overlaps from snapping [true/false] - useful for example when ends_before is higher than starts_before.

-- this is a table with all presets for kf snapping. you can add your own, as long as you don't fuck up the pattern.
kf_snap_presets={"1,1,1,1","2,2,2,2","6,6,8,12","6,6,10,12","6,10,8,12","8,8,8,12","0,0,0,10","7,12,10,13"}

-- END OF SETTINGS

function style(subs)
styles={"All","All Default","Default+Alt","----------------"}
  for i=1, #subs do
    if subs[i].class=="style" then
      local st=subs[i]
      table.insert(styles,st.name)
    end
  end
  return styles
end

function runcheck()
	run=0
	if res.stail=="All" then run=1 end
	if res.stail=="All Default" and line.style:match("Defa") then run=1 end
	if res.stail=="Default+Alt" and line.style:match("Defa") then run=1 end
	if res.stail=="Default+Alt" and line.style:match("Alt") then run=1 end
	if res.stail==line.style then run=1 end
	return run
end
		
function cutout(subs, sel)
	for z, i in ipairs(sel) do
	    line=subs[i]
		ut=res.ut
		start=line.start_time
		endt=line.end_time
		if i<#subs then nextline=subs[i+1]
		nextart=nextline.start_time end
		run=runcheck()
		
	    if run==1 then
		if not res.addout then	-- cut
		  if (endt-ut)>start then endt=(endt-ut) else endt=start end
		else
		  endt=(endt+ut)	-- add
		  if res.preventcut and i<#subs and endt>nextart then endt=nextart end
		end
	    line.end_time=endt
	    subs[i]=line
	    end
	end
end

function cutin(subs, sel)
	for z, i in ipairs(sel) do
	    line=subs[i]
		inn=res.inn
		start=line.start_time
		endt=line.end_time
		prevline=subs[i-1]
		if prevline.class=="dialogue" then
		prevend=prevline.end_time end
		run=runcheck()
		
	    if run==1 then
		if not res.addin then	-- cut
		  if (start+inn)<endt then start=(start+inn) else start=endt end
		else
		  start=(start-inn)	-- add
		  if res.preventcut and prevline.class=="dialogue" and start<prevend then start=prevend end
		end
	    line.start_time=start
	    subs[i]=line
	    end
	end
end

function shiift(subs, sel)
	for z, i in ipairs(sel) do
	    line=subs[i]
		shift=res.shifft
		start=line.start_time
		endt=line.end_time
		run=runcheck()
		
	    if run==1 then
		if not res.shit then
		start=(start-shift)
		endt=(endt-shift)
		else
		start=(start+shift)
		endt=(endt+shift)
		end
	    line.start_time=start
	    line.end_time=endt
	    subs[i]=line
	    end
	end
end

function linklines(subs, sel)
	marker=0
	for z, i in ipairs(sel) do
	    line=subs[i]
		lnk=res.link
		start=line.start_time
		endt=line.end_time
		if i<#subs then nextline=subs[i+1]
		nextart=nextline.start_time end
		if marker==1 then start=start-diff2 end	-- link line 2
		if markover==1 then start=start+diffo end	-- overlap line 2
		marker=0
		markover=0
		run=runcheck()
		
	    if run==1 then
		-- linking
		if nextart>endt and nextart-endt<lnk and z~=#sel then
		 gap=nextart-endt
		 diff=gap*res.bias
		 endt=endt+diff
		 diff2=gap-diff
		 marker=1
		end
		
		-- overlaps
		if res.over and endt>nextart and endt-nextart<res.overlap and z~=#sel then
		lap=endt-nextart
		diffo=lap*res.bios
		endt=nextart+diffo
		markover=1
		end
	    line.start_time=start
	    line.end_time=endt
	    subs[i]=line
	    end
	end
end

function keyframesnap(subs, sel)
	for z, i in ipairs(sel) do
	    line=subs[i]
	    if res.pres then kfsb,kfeb,kfsa,kfea=res.preset:match("(%d+),(%d+),(%d+),(%d+)") 
		kfsb=tonumber(kfsb)
		kfeb=tonumber(kfeb)
		kfsa=tonumber(kfsa)
		kfea=tonumber(kfea)
	    end
	    if not res.pres then kfsb=res.sb kfeb=res.eb kfsa=res.sa kfea=res.ea end
		run=runcheck()
		
	    if run==1 then

	    -- snapping to keyframes
		
		start=line.start_time		-- start time
		endt=line.end_time		-- end time
		startemp=start
		endtemp=endt
		if z~=#sel then nextline=subs[i+1]
		nextart=nextline.start_time end
		if z~=1 then prevline=subs[i-1]
		prevend=prevline.end_time end
		ms2fr=aegisub.frame_from_ms
		fr2ms=aegisub.ms_from_frame
		
		keyframes=aegisub.keyframes()	-- keyframes table
		startf=ms2fr(start)		-- startframe
		endf=ms2fr(endt)		-- endframe
		
		diff=250
		diffe=250
		startkf=keyframes[1]
		endkf=keyframes[#keyframes]
		
		-- check for nearby keyframes
		for k,kf in ipairs(keyframes) do
		
			-- startframe snap up to 24 frames back [scroll down to change default] and 5 frames forward
			if kf>=startf-kfsa and kf<=startf+kfsb then 
			tdiff=math.abs(startf-kf)
			if tdiff<=diff then diff=tdiff startkf=kf end
			startemp=fr2ms(startkf)
			
			stopstart=0
			if res.prevent and z~=1 and startemp<prevend and start>=prevend then stopstart=1 end
			if stopstart==0 then start=startemp end
			end
			
			-- endframe snap up to 24 frames forward [scroll down to change default] and 10 frames back
			if kf>=endf-kfea and kf<=endf+kfeb then
			tdiff=math.abs(endf-kf)
			if tdiff<diffe then diffe=tdiff endkf=kf end
			endtemp=fr2ms(endkf)
			
			stopend=0
			if res.prevent and z~=#sel and endtemp>nextart and endkf-endf>kfsb then stopend=1 end
			if stopend==0 then endt=endtemp end
			end
			
		end
	    line.start_time=start
	    line.end_time=endt
	    subs[i]=line
	    end
	end
end

function selectall(subs, sel)
sel={}
    for i=1,#subs do
	if subs[i].class=="dialogue" then table.insert(sel,i) end
    end
    return sel
end

function konfig(subs, sel)
	style(subs)
	dialog_config=
	{
	    {x=0,y=0,width=2,height=1,class="label",label="ShiftCut v2.3" },
	    {x=2,y=0,width=2,height=1,class="dropdown",name="slct",items={"Apply to selected","Apply to all lines"},value=apply_to},
	    {x=4,y=0,width=3,height=1,class="label",label="" },
	    
	    {x=0,y=1,width=2,height=1,class="label",label="Styles to aply to:" },
	    {x=2,y=1,width=2,height=1,class="dropdown",name="stail",items=styles,value=styles_to_apply_to},
	    {x=4,y=1,width=2,height=1,class="label",label="" },
	    
	    -- cut/shift
	    {x=0,y=2,width=1,height=1,class="label",name="01",label="cut leadin [or" },
	    {x=1,y=2,width=1,height=1,class="checkbox",name="addin",label="add]",value=add_leadin },
	    {x=0,y=3,width=2,height=1,class="floatedit",name="inn",value=leadin_value,hint="ms" },
	    
	    {x=2,y=2,width=1,height=1,class="label",name="02",label="cut leadout [or" },
	    {x=3,y=2,width=1,height=1,class="checkbox",name="addout",label="add]",value=add_leadout },
	    {x=2,y=3,width=2,height=1,class="floatedit",name="ut",value=leadout_value,hint="ms" },
	    
	    {x=4,y=2,width=1,height=1,class="label",name="03",label="shift left [or" },
	    {x=5,y=2,width=1,height=1,class="checkbox",name="shit",label="right]",value=shift_right },
	    {x=4,y=3,width=2,height=1,class="floatedit",name="shifft",value=shift_value,hint="ms" },
	    
	    {x=0,y=4,width=4,height=1,class="checkbox",name="preventcut",
	    label="prevent overlaps from adding lead in/out",value=prevent_cut_overlaps},
	    
	    -- linking
	    {x=0,y=5,width=2,height=1,class="label",label="Line linking:   max gap:" },
	    {x=2,y=5,width=2,height=1,class="floatedit",name="link",value=line_linking_gap,min=0 },
	    {x=4,y=5,width=1,height=1,class="label",label="ms    Bias:" },
	    {x=5,y=5,width=1,height=1,class="dropdown",name="bias",
	    items={"0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","1"},value=linking_bias,hint="higher number=closer to 2nd line"},
	    
	    -- overlaps
	    {x=0,y=6,width=2,height=1,class="checkbox",name="over",label="fix overlaps up to:",value=fix_overlaps,hint="This is part of line linking. If you want only overlaps, set linking gap to 0." },
	    {x=2,y=6,width=2,height=1,class="floatedit",name="overlap",value=overlap_value,min=0 },
	    {x=4,y=6,width=1,height=1,class="label",label="ms    Bias:" },
	    {x=5,y=6,width=1,height=1,class="dropdown",name="bios",
	    items={"0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","1"},value=overlap_bias,hint="higher number=closer to 2nd line"},
	    
	    -- keyframes
	    {x=7,y=0,width=1,height=1,class="label",label="Keyframes", },
	    
	    {x=7,y=1,width=1,height=1,class="label",label="Starts before:" },
	    {x=7,y=2,width=1,height=1,class="label",label="Ends before:" },
	    {x=7,y=3,width=1,height=1,class="label",label="Starts after:" },
	    {x=7,y=4,width=1,height=1,class="label",label="Ends after:" },
	    
	    {x=8,y=1,width=1,height=1,class="floatedit",name="sb",value=starts_before,min=0,max=250,hint="frames, not ms" },
	    {x=8,y=2,width=1,height=1,class="floatedit",name="eb",value=ends_before,min=0,max=250,hint="frames, not ms" },
	    {x=8,y=3,width=1,height=1,class="floatedit",name="sa",value=starts_after,min=0,max=250,hint="frames, not ms" },
	    {x=8,y=4,width=1,height=1,class="floatedit",name="ea",value=ends_after,min=0,max=250,hint="frames, not ms" },
	    
	    {x=7,y=5,width=1,height=1,class="checkbox",name="pres",label="Preset:",value=use_preset },
	    {x=8,y=5,width=1,height=1,class="dropdown",name="preset",items=kf_snap_presets,value=kf_snap_preset},
	    
	    {x=7,y=6,width=2,height=1,class="checkbox",name="prevent",label="Prevent overlaps by snapping",value=prevent_kf_overlaps },
	    
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,
		{"[ cut or add lead in ]","[ cut or add lead out ]","shift times","line linking","kf snapping","cancel"},{cancel='cancel'})
	if res.slct=="Apply to all lines" then sel=selectall(subs, sel) end
	
	if pressed=="[ cut or add lead in ]" then cutin(subs, sel) end
	if pressed=="[ cut or add lead out ]" then cutout(subs, sel) end
	if pressed=="shift times" then shiift(subs, sel) end
	if pressed=="line linking" then linklines(subs, sel) end
	if pressed=="kf snapping" then keyframesnap(subs, sel) end
	if pressed=="cancel" then aegisub.cancel() end
	return sel
end

function shiftcut(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, shiftcut)