bib_id={}
bib_array={}
cite_num=0
--------rdata----------
bib_map=rdata["bib_map"]
if (bib_map==nil) then
	bib_map={}
end
------wdata--------
wbib_map={}
wdata["bib_map"]=wbib_map
function write_bib_map(id)
	wbib_map[id]=bib_map[id]
end
-------------------
function get_bib_id(key)
    if bib_id[key]==nil then
        if bib_map[key]==nil then
            return -1
        else
            cite_num=cite_num+1
            bib_id[key]=cite_num
            bib_array[cite_num]=key
        end
    end
    return bib_id[key]
end
function bib_fetch(keys)
	local word
	--tex.print(";"..keys..";\\string\\")
	for word in keys:gmatch("[^,]+") do
		--tex.print("\\immediate\\write\\@auxout\{\\directlua\{local temp=\""..word.."\"\}\}")
		--tex.print(";"..word.." "..get_bib_id(word)..";")
		--tex.print(123)
		get_bib_id(word)
	end
end
function get_cite_str(keys)
	local word
	local str="["
	local k=0
	local last=0
	local arr={}
	local err={}
	for word in keys:gmatch("[^,]+") do
		local a=get_bib_id(word)
		if (a>0) then
			table.insert(arr,a)
			k=k+1
		else
			table.insert(err,word)
		end
	end
	if (k>0) then
		table.sort(arr)
		str=str..arr[1]
		last=arr[1]
		for i=2,k do
			if arr[i-1]+1 ~= arr[i] then
				if (last~=arr[i-1]) then
					if (last+1==arr[i-1]) then
						str=str..","
					else
						str=str.."-"
					end
					str=str..arr[i-1]
				end
				str=str..","..arr[i]
				last=arr[i]
			end
		end
		if (last~=arr[k]) then
			if last+1==arr[k] then
				str=str..","
			else
				str=str.."-"
			end
			str=str..arr[k]
		end
	end
	for _,v in pairs(err) do
		str=str..","..v
	end
	str=str.."]"
	return str
end
function bibliography()
	local str=""
	for i=1,cite_num do
		str=str.."{[" .. i .."] "..bib_map[bib_array[i]].."}\\par"
		--texio.write_nl("log","debug",str)
		--tex.print(str)
	end
	--texio.write_nl("log","debug",str)
	tex.print(str)
end
function register_bib(key,value)
	bib_map[key]=value
	write_bib_map(key)
end
function read_bib_file()
	local bib_file=io.open("./bibliography.in","r")
	if (bib_file~=nil) then
		io.close(bib_file)
		local sw=0
		local k,v,line
		k=""
		v=""
		for line in io.lines(lfs.currentdir().."/bibliography.in") do
			if string.len(line)>0 then
				sw=sw+1
				if (sw==1) then
					k=""..line
					v=""
				else
					v=v..line.." "
				end
			else
				sw=0
				bib_map[k]=v
				write_bib_map(k)
				k=""
				v=""
			end
		end
		if (string.len(k)>0) then
			bib_map[k]=v
			write_bib_map(k)
			k=""
			v=""
		end
	end
end