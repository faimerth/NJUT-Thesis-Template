equation={}
wequation={}
wdata["equation"]=wequation
if rdata and rdata["equation"] then
	equation=rdata["equation"]
end
function write_equation(k)
	wequation[k]=equation[k]
end
---------------------
function register_equation(key,value)
	equation[key]=value
	write_equation(key)
end
