--[[

 Bottom dropdown menu chooses mode:
	Colorize letter by letter:
 Alternates between 2-5 colours character by character, like 121212, 123123123, or 123412341234.
 Works for primary/border/shadow/secondary (only one of those).
 Nukes all comments and inline tags. Only first block of tags is kept.
	Shift:
 Shift can be used on an already colorized line to shift the colours by one letter.
 You have to set the right number of colours for it to work correctly!
 If shift base is "line", then it takes the colour for the first character from the last character.
 
   "Don't join with other tags" will keep {initial tags}{colour} separated (ie won't nuke the "}{"). 
 This helps some other scripts to keep the colour as part of the "text" without initial tags.
 
   "Continuous shift line by line" - If you select a bunch of the same colorized lines, this shifts the colours line by line.
 This kind of requires that no additional weird crap is done to the lines, otherwise malfunctioning can be expected.
 
	Match/switch \c and \3c:
 This should be obvious from the names and should apply to all new colour tags in the line.
 
	Adjust RGB / Brightness
 Simple and lame way of increasing/decreasing brightness for one (RGB) or all (Brightness) colours.
 This works for lines with multiple same-type colour tags, including gradient by character.
 You can select from -10 to 10. One step is 1/16 of the spectrum.
 (The way this works: If colour is \c&H9D9337&, it's split to 9D 93 37, and the first number/letter of each is raised by one -> ADA347.)
 Check types of colours you want it to apply to.
 "Apply even to colours without tags in line" means it will be applied to the colour set in style.

--]]

script_name="Colorize"
script_description="Does things with colours"
script_author="unanimated"
script_version="1.92"

function colors(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=line.text
	
	    col1=res.c1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res.c2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=res.c3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=res.c4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col5=res.c5:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    
	    if res.kol=="primary" then k="\\c" text=text:gsub("\\1?c&H%x+&","") end
	    if res.kol=="border" then k="\\3c" text=text:gsub("\\3c&H%x+&","") end
	    if res.kol=="shadow" then k="\\4c" text=text:gsub("\\4c&H%x+&","") end
	    if res.kol=="secondary" then k="\\2c" text=text:gsub("\\2c&H%x+&","") end
	    
	    k1=k..col1
	    k2=k..col2
	    k3=k..col3
	    k4=k..col4
	    k5=k..col5

	    tags=""
	    if text:match("^{\\[^}]*}") then tags=text:match("^({\\[^}]*})") end
	    text=text:gsub("{[^}]*}","")
	    text=text:gsub("%s*$","")

	    if res.clrs=="2" then text=text:gsub("%s","  ") text=text.."*"
		text=text:gsub("([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	    end
	    
	    if res.clrs=="3" then text=text:gsub("%s","   ") text=text:gsub("\\N","\\N~") text=text.."**"
		text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2{"..k3.."}%3")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
		text=text:gsub("{\\[1234]?c&H%x+&}~","")
	    end
	    
	    if res.clrs=="4" then text=text:gsub("%s","    ") text=text:gsub("\\N","\\N\\N") text=text.."***"
		text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2{"..k3.."}%3{"..k4.."}%4")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	    end
	    
	    if res.clrs=="5" then text=text:gsub("%s","     ") text=text:gsub("\\N","\\N\\N~") text=text.."****"
	text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2{"..k3.."}%3{"..k4.."}%4{"..k5.."}%5")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
		text=text:gsub("{\\[1234]?c&H%x+&}~","")
	    end

	    text=text:gsub("{\\[1234]?c&H%x+&}%*","")
	    text=text:gsub("%*+$","")

	text=text:gsub("{\\[1234]?c&H%x+&}\\{\\[1234]?c&H%x+&}N","\\N")
	text=text:gsub("\\N\\N","\\N")
	text=tags..text
	if res.join==false then text=text:gsub("}{","") end
	line.text=text
        subs[i]=line
    end
end

function shift(subs, sel)
	klrs=tonumber(res.clrs)	-- how many colours we're dealing with
	count=1				-- start line counter
	if res.shit=="line" then sline=true else sline=false end
    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=line.text

	    -- check if line looks colorized
	    if not text:match("{(\\[1234]?c)&H%x+&}[%w%p]") then aegisub.dialog.display({{class="label",
		label="Line "..x.." does not \nappear to be colorized",x=0,y=0,width=1,height=2}},{"OK"}) aegisub.cancel()
	    end

	    -- determine which colour has been used to colorize - 1c, 2c, 3c, 4c
	    if sline then ctype,shc=text:match("{(\\[1234]?c)(&H%x+&)}[^{]*$") first="{"..ctype..shc.."}" else
		ctype=text:match("{(\\[1234]?c)&H%x+&}[%w%p]$") 

		-- get colours 2, 3, 4, 5, and create sequences for shifting
		a,c2,b,c3,c,c4,d,c5=text:match("([%w%p]%s?)({"..ctype.."&H%x+&})([%w%p]%s?)({"..ctype.."&H%x+&})([%w%p]%s?)({"..ctype.."&H%x+&})([%w%p]%s?)({"..ctype.."&H%x+&})")
		if klrs==2 then first=c2 end
		if klrs==3 then first=c3 second=c2 end
		if klrs==4 then first=c4 second=c3 third=c2 end
		if klrs==5 then first=c5 second=c4 third=c3 fourth=c2 end
	    end

	    -- don't run for 1st lines in sequences
	    if count>1 or not res.cont then

		-- separate first colour tag from other tags, save initial tags
		tags=""
		if text:match("^{\\[^}]*"..ctype.."&") then text=text:gsub("^({\\[^}]*)("..ctype.."&H%x+&)([^}]*})","%1%3{%2}") end
		if not text:match("^{\\[1234]?c&H%x+&}") then tags=text:match("^({\\[^}]*})") text=text:gsub("^{\\[^}]*}","") end

		-- shifting colours happens here
		switch=1
		repeat 
		text=text:gsub("({\\[1234]?c&H%x+&})([%w%p])","%2%1")
		text=text:gsub("({\\[1234]?c&H%x+&})(%s)","%2%1")
		text=text:gsub("({\\[1234]?c&H%x+&})(\\N)","%2%1")
		text=text:gsub("({\\[1234]?c&H%x+&})$","")
		text=first..text
		switch=switch+1
		if not sline then
		  if switch==2 then first=second end
		  if switch==3 then first=third end
		  if switch==4 then first=fourth end
		else
		  first=text:match("({\\[1234]?c&H%x+&})[^{]*$")
		end
		  for cl1,cl2,cl3 in text:gmatch("({\\[1234]?c&H%x+&})([%w%p%s])({\\[1234]?c&H%x+&})") do
		    if cl1==cl3 then 
		    text=text:gsub(cl1..cl2..cl3,cl1..cl2)
		    end
		  end
		until switch>=count

		if tags~=nil then text=tags..text end
		if res.join==false then text=text:gsub("}{","") end
	    end

	-- line counter
	if res.cont then count=count+1 end
	if not sline and count>klrs then count=1 end
	line.text=text
        subs[i]=line
    end
end

function matchcolors(subs, sel)
if res.mode=="adjust RGB / brightness" then
	rgb_config=
	{
	{x=0,y=0,width=1,height=1,class="label",label="Red: "},
	{x=1,y=0,width=2,height=1,class="intedit",name="R",value=0,min=-10,max=10},
	{x=0,y=1,width=1,height=1,class="label",label="Green: "},
	{x=1,y=1,width=2,height=1,class="intedit",name="G",value=0,min=-10,max=10},
	{x=0,y=2,width=1,height=1,class="label",label="Blue: "},
	{x=1,y=2,width=2,height=1,class="intedit",name="B",value=0,min=-10,max=10},
	{x=0,y=4,width=1,height=1,class="label",label="Brightness:"},
	{x=1,y=4,width=2,height=1,class="intedit",name="bright",value=0,min=-10,max=10},
	{x=0,y=3,width=5,height=1,class="label",label="From -10 to 10. 1 step is 1/16 of the spectrum."},
	{x=0,y=5,width=5,height=1,class="label",label="1 step for brightness equals 1 step for R+G+B."},

	{x=0,y=6,width=1,height=1,class="checkbox",name="k1",label="\\c       ", value=true  },
	{x=1,y=6,width=1,height=1,class="checkbox",name="k3",label="\\3c      ",value=false },
	{x=2,y=6,width=1,height=1,class="checkbox",name="k4",label="\\4c      ",value=false },
	{x=3,y=6,width=1,height=1,class="checkbox",name="k2",label="\\2c",value=false },
	{x=0,y=7,width=5,height=1,class="checkbox",name="mktag",label="apply even to colours without tags in line", value=false },
	}
	press,rez=aegisub.dialog.display(rgb_config,{"RGB","Brightness","Cancel"},{ok='RGB',close='Cancel'})
	if press=="Cancel" then    aegisub.cancel() end
end


    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=line.text
	styleref=stylechk(subs,line.style)
	
		stylecol={}
		
		primary=styleref.color1:gsub("H%x%x","H")	sc1=primary	table.insert(stylecol,sc1)
		pri=text:match("^{[^}]-\\c(&H%x+&)")		if pri~=nil then primary=pri end
		
		secondary=styleref.color2:gsub("H%x%x","H")	sc2=secondary	table.insert(stylecol,sc2)
		sec=text:match("^{[^}]-\\3c(&H%x+&)")		if sec~=nil then secondary=sec end
		
		outline=styleref.color3:gsub("H%x%x","H")	sc3=outline	table.insert(stylecol,sc3)
		out=text:match("^{[^}]-\\3c(&H%x+&)")		if out~=nil then outline=out end
		
		shadow=styleref.color4:gsub("H%x%x","H")	sc4=shadow	table.insert(stylecol,sc4)
		sha=text:match("^{[^}]-\\c(&H%x+&)")		if sha~=nil then shadow=sha end
		
	    if res.kol=="primary" then k="\\c" end
	    if res.kol=="border" then k="\\3c" end
	    if res.kol=="shadow" then k="\\4c" end
	    if res.kol=="secondary" then k="\\2c" end
	    text=text:gsub("\\1c","\\c")
	    if not text:match("^{\\") then text=text:gsub("^","{\\}") end

	-- 1->3   match outline to primary
	if res.mode=="\\c -> \\3c (match outline to primary)" then
	    for ctags in text:gmatch("({\\[^}]-})") do
		ctags2=nil
		if ctags:match("\\3c") and not ctags:match("\\1?c") then ctags2=ctags:gsub("\\3c&H%w+&","\\3c"..primary) end
		if ctags:match("\\1?c") and ctags:match("\\3c") then 
		  tempc=ctags:match("\\1?c(&H%w+&)") ctags2=ctags:gsub("\\3c&H%w+&","\\3c"..tempc) end
		if ctags:match("\\1?c") and not ctags:match("\\3c") then
		  ctags2=ctags:gsub("\\1?c(&H%w+&)","\\c%1\\3c%1") end
		if ctags==text:match("^({\\[^}]-})") and not ctags:match("\\3c") and not ctags:match("\\1?c") then
		  ctags2=ctags:gsub("^({\\[^}]-)}","%1\\3c"..primary.."}") end
		ctags=esc(ctags)
		if ctags2~=nil then ctags=esc(ctags) text=text:gsub(ctags,ctags2) end
	    end
	end

	-- 3->1   match primary to outline
	if res.mode=="\\3c -> \\c (match primary to outline)" then
	    for ctags in text:gmatch("({\\[^}]-})") do
		ctags2=nil
		if ctags:match("\\1?c") and not ctags:match("\\3c") then ctags2=ctags:gsub("\\1?c&H%w+&","\\c"..outline) end
		if ctags:match("\\1?c") and ctags:match("\\3c") then 
		  tempc=ctags:match("\\3c(&H%w+&)") ctags2=ctags:gsub("\\1?c&H%w+&","\\c"..tempc) end
		if ctags:match("\\3c") and not ctags:match("\\1?c") then
		  ctags2=ctags:gsub("\\3c(&H%w+&)","\\c%1\\3c%1") end
		if ctags==text:match("^({\\[^}]-})") and not ctags:match("\\1?c") and not ctags:match("\\3c") then
		  ctags2=ctags:gsub("^({\\[^}]-)}","%1\\c"..outline.."}") end
		if ctags2~=nil then ctags=esc(ctags) text=text:gsub(ctags,ctags2) end
	    end
	end
	
	-- 3->4   match shadow to outline
	if res.mode=="\\3c -> \\4c (match shadow to outline)" then
	    for ctags in text:gmatch("({\\[^}]-})") do
		ctags2=nil
		if ctags:match("\\4c") and not ctags:match("\\3c") then ctags2=ctags:gsub("\\4c&H%w+&","\\4c"..outline) end
		if ctags:match("\\4c") and ctags:match("\\3c") then 
		  tempc=ctags:match("\\3c(&H%w+&)") ctags2=ctags:gsub("\\4c&H%w+&","\\4c"..tempc) end
		if ctags:match("\\3c") and not ctags:match("\\4c") then
		  ctags2=ctags:gsub("\\3c(&H%w+&)","\\3c%1\\4c%1") end
		if ctags==text:match("^({\\[^}]-})") and not ctags:match("\\4c") and not ctags:match("\\3c") then
		  ctags2=ctags:gsub("^({\\[^}]-)}","%1\\4c"..outline.."}") end
		if ctags2~=nil then ctags=esc(ctags) text=text:gsub(ctags,ctags2) end
	    end
	end

	-- 1<->3   switch primary and border
	if res.mode=="\\c <--> \\3c (switch primary and border)" then
	    if text:match("^{\\") then
		tags=text:match("^({\\[^}]-})")
		if tags:match("\\1?c") then tags=tags:gsub("\\1?c","\\tempc")
		else tags=tags:gsub("({\\[^}]-)}","%1\\tempc"..primary.."}") end
		if tags:match("\\3c") then tags=tags:gsub("\\3c","\\c")
		else tags=tags:gsub("({\\[^}]-)}","%1\\c"..outline.."}") end
		tags=tags:gsub("\\tempc","\\3c")
		after=text:match("^{\\[^}]-}(.*)")
		after=after:gsub("\\1?c","\\tempc")
		after=after:gsub("\\3c","\\c")
		after=after:gsub("\\tempc","\\3c")
		text=tags..after
	    else
		tags="{\\c"..outline.."\\3c"..primary.."}"
		after=text
		after=after:gsub("\\1?c","\\tempc")
		after=after:gsub("\\3c","\\c")
		after=after:gsub("\\tempc","\\3c")
		text=tags..after
	    end
	end


	-- RGB Colour / BRIGHTNESS
	if res.mode=="adjust RGB / brightness" then
	    lvlr=rez.R lvlg=rez.G lvlb=rez.B
	    brite=rez.bright
	    corols={}
	    if rez.k1 then table.insert(corols,"1") end
	    if rez.k2 then table.insert(corols,"2") end
	    if rez.k3 then table.insert(corols,"3") end
	    if rez.k4 then table.insert(corols,"4") end
	    tagz=text:match("^({\\[^}]-})")
	    
	    for i=1,#corols do
		n=tonumber(corols[i])
		local kl="\\"..n.."c"
		kl=kl:gsub("\\1c","\\c")
		
		if rez.mktag and not tagz:match(kl) then
		    text=text:gsub("^({\\[^}]-)}","%1"..kl..stylecol[n].."}")
		end 
	      
		if press=="RGB" then
		  for kol1,kol2,kol3 in text:gmatch(kl.."&H(%x%x)(%x%x)(%x%x)&") do
		    kol1n=brightness(kol1,lvlb)
		    kol2n=brightness(kol2,lvlg)
		    kol3n=brightness(kol3,lvlr)
		  text=text:gsub(kol1..kol2..kol3,kol1n..kol2n..kol3n)
		  end
		end
		
		if press=="Brightness" then
		  for kol1,kol2,kol3 in text:gmatch(kl.."&H(%x%x)(%x%x)(%x%x)&") do
		    kol1n=brightness(kol1,brite)
		    kol2n=brightness(kol2,brite)
		    kol3n=brightness(kol3,brite)
		  text=text:gsub(kol1..kol2..kol3,kol1n..kol2n..kol3n)
		  end
		end
	    end
	end

	text=text:gsub("\\\\","\\")
	text=text:gsub("\\}","}")
	text=text:gsub("{}","")
	line.text=text
        subs[i]=line
    end
end

function brightness(klr,lvl)
    ka,kb=klr:match("(%x)(%x)")
    ka=tonumber(ka,16)
    ka=ka+lvl
    ka=tohex(ka)
    klr2=ka..kb
return klr2
end

function tohex(num)
    if num<1 then num="0"
    elseif num>14 then num="F"
    elseif num==10 then num="A"
    elseif num==11 then num="B"
    elseif num==12 then num="C"
    elseif num==13 then num="D"
    elseif num==14 then num="E" end
return num
end

function stylechk(subs,stylename)
    for i=1, #subs do
        if subs[i].class=="style" then
	    local st=subs[i]
	    if stylename==st.name then
		styleref=st	    
	    end
	end
    end
    return styleref
end

function esc(str)
str=str
:gsub("%%","%%%%")
:gsub("%(","%%%(")
:gsub("%)","%%%)")
:gsub("%[","%%%[")
:gsub("%]","%%%]")
:gsub("%.","%%%.")
:gsub("%*","%%%*")
:gsub("%-","%%%-")
:gsub("%+","%%%+")
:gsub("%?","%%%?")
return str
end

function repetition()
	if res.mode=="repeat with last settings" then
	res.clrs=lastclrs
	res.shit=lastshit
	res.kol=lastkol
	res.c1=lastc1
	res.c2=lastc2
	res.c3=lastc3
	res.c4=lastc4
	res.c5=lastc5
	res.join=lastjoin
	res.cont=lastcont
	end
end

function colorize(subs, sel)
	dialog_config=
	{
	{x=0,y=0,width=1,height=1,class="label",label="Colours"},
	{x=1,y=0,width=1,height=1,class="dropdown",name="clrs",items={"2","3","4","5"},value="2"},
	
	{x=0,y=1,width=1,height=1,class="label",label="Shift base:"},
	{x=1,y=1,width=1,height=1,class="dropdown",name="shit",items={"# of colours","line"},value="# of colours"},
	
	{x=0,y=2,width=1,height=1,class="label",label="Apply to:  "},
	{x=1,y=2,width=1,height=1,class="dropdown",name="kol",items={"primary","border","shadow","secondary"},value="primary"},
	    
	{x=3,y=0,width=1,height=1,class="label",label="  1 "},
	{x=3,y=1,width=1,height=1,class="label",label="  2 "},
	{x=3,y=2,width=1,height=1,class="label",label="  3 "},
	{x=3,y=3,width=1,height=1,class="label",label="  4 "},
	{x=3,y=4,width=1,height=1,class="label",label="  5 "},
	
	{x=4,y=0,width=1,height=1,class="color",name="c1" },
	{x=4,y=1,width=1,height=1,class="color",name="c2" },
	{x=4,y=2,width=1,height=1,class="color",name="c3" },
	{x=4,y=3,width=1,height=1,class="color",name="c4" },
	{x=4,y=4,width=1,height=1,class="color",name="c5" },
	
	{x=0,y=3,width=2,height=1,class="checkbox",name="join",label="Don't join with other tags",value=false },
	{x=0,y=4,width=3,height=1,class="checkbox",name="cont",label="Continuous shift line by line",value=false },
	
	{x=0,y=5,width=6,height=1,class="dropdown",name="mode",
		items={"colorize letter by letter","repeat with last settings","\\c -> \\3c (match outline to primary)","\\3c -> \\c (match primary to outline)","\\3c -> \\4c (match shadow to outline)","\\c <--> \\3c (switch primary and border)","adjust RGB / brightness"},value="colorize letter by letter"},
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,{"Colorize","Shift","Cancel"},{ok='Colorize',close='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	if pressed=="Colorize" then
		if res.mode=="colorize letter by letter" or res.mode=="repeat with last settings" then repetition() colors(subs, sel)
		else repetition() matchcolors(subs, sel) end
	end
	if pressed=="Shift" then   repetition() shift(subs, sel) end
	
	if res.mode~="repeat with last settings" then
	lastclrs=res.clrs
	lastshit=res.shit
	lastkol=res.kol
	lastc1=res.c1
	lastc2=res.c2
	lastc3=res.c3
	lastc4=res.c4
	lastc5=res.c5
	lastjoin=res.join
	lastcont=res.cont
	end
    
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, colorize)