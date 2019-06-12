local chs={
    [0]="零",[1]="一",[2]="二",[3]="三",[4]="四",[5]="五",[6]="六",[7]="七",
    [8]="八",[9]="九",[10]="十",[100]="百",[1000]="千",[10000]="万"}
function chsnum(x)
    local i,a,b=10000,0,0
    while x<i do
        i=i/10
    end
    local out=""
    if x<20 then
        if x>10 then
            out=out..chs[10]
            x=x-10
        end
        out=out..chs[x]
    else
        while x>0 do
            a=math.floor(x/i)
            if (a+b>0) then
                out=out..chs[a]
            end
            if (a>0) then
                out=out..chs[i]
            end
            b=a
            x=x-a*i
            i=i/10
        end
    end
    tex.print(out)
end