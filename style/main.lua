--if style_prefix==nil then style_prefix=lfs.currentdir().."/style" end
--if resource_prefix==nil then resource_prefix=lfs.currentdir().."/figure" end
if style_prefix==nil then style_prefix="./style" end
if resource_prefix==nil then resource_prefix="./figure" end

rdata=nil
wdata={}
data_path="./tmp/"..tex.jobname..".tbl"

page_id=0
linestretch=1.0
require(style_prefix .. "/core.lua")
require(style_prefix .. "/debug.lua")
require(style_prefix .. "/chs.lua")
require(style_prefix .. "/tex_wrapper.lua")

function load_data()
	local data_file=io.open(data_path,"r")
	if (data_file) then
		rdata=read_data(data_file)
		data_file:close()
	end
	if (rdata==nil) then rdata={} end
end

function save_data()
	if wdata then
		local data_file=io.open(data_path,"w")
		write_table(data_file,wdata)
		data_file:close()
	end
end

load_data()

---------------------------module----------------------------
require(style_prefix .. "/section.lua")
require(style_prefix .. "/image.lua")
require(style_prefix .. "/tabular.lua")
require(style_prefix .. "/equation.lua")
require(style_prefix .. "/bibliography.lua")

read_bib_file()







--function test(p1,p2,p3,p4,p5,p6)
	--tex.write("\\writefile{toc}{\\ttl@change@i {\\@ne }{".. token.get_macro(p1) .."}{" .. token.get_macro(p2) .. "}{" .. token.get_macro(p3) .. "}{" .. token.get_macro(p4) .. "}{" .. token.get_macro(p5) .. "}{" .. token.get_macro(p6) .."}\\relax}")
	--tex.write("\\writefile{toc}{\\ttl@change@v {" .. token.get_macro(p1) .. "}{}{}{}\relax}")
--function setgeometry(str)
	--local tbl={[1]="pagetopoffset",[2]="pagebottomoffset",[3]="pageleftoffset",[4]="pagerightoffset"}
	--local i,a,word
	--i=0
	--for word in str:gmatch("[^,]+") do
		--i=i+1
		--if (i>4) then break end
		--a=tonumber(word)
		--tex[tbl[i]]=math.floor(a*65536);
	--end
	--tex.dimen["topmargin"]=0
	--tex.dimen["headheight"]=0
	--tex.dimen["headsep"]=0
	--tex.dimen["footskip"]=0
	--tex.dimen["oddsidemargin"]=0
	--tex.dimen["evensidemargin"]=0
	----tex.hoffset=0
	----tex.voffset=0
	--tex.hsize=tex.pagewidth
	--tex.vsize=tex.pageheight
	--tex.dimen["marginparwidth"]=tex.pagewidth
	--tex.dimen["textheight"]=tex.pageheight
	--tex.dimen["textwidth"]=tex.pagewidth
	--tex.dimen["linewidth"]=tex.pagewidth
	----texio.write_nl("log","DEBUG",tex.dimen["linewidth"])
--end
--18446744069414584321