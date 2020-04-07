hey = {};
hey.sora = true; -- Prevent my files from crashing
hey.themeDebugMode = true;

function hey.Debug(text)
    if SCREENMAN and hey.themeDebugMode then
        SCREENMAN:SystemMessage(text); -- Screen + Console
    else
        Trace(text); -- Console
    end
end

-- hey.GetField ( string k )
function hey.GetField(f)
    local v = _G;
    for w in string.gfind(f, '[%w_]+') do
        if v then
            v = v[w];
        else
            return nil;
        end
    end
    return v;
end

-- hey.Trim( string str )
function hey.Trim(str)
    return ({string.gsub(str, '^%s*(.-)%s*$', '%1')})[1];
end

-- hey.Split( string str, string separator = ',' )
function hey.Split(str, sep)
    local sep = sep or ',';
    local ret = {};
    local pattern = string.format('([^%s]+)', sep)
    string.gsub(str, pattern, function(c)
        table.insert(ret, hey.Trim(c))
    end);
    return ret;
end

-- hey.PrintR ( mixed v )
-- Inspired from https://github.com/robmiracle/print_r/blob/master/print_r.lua
-- Removed Lua >5.0 things, used ITG-compatible syntax
function hey.PrintR(t) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            Trace(indent..'*'..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=='table') then
                local tLen = table.getn(t)
                for i = 1, tLen do
                    local val = t[i]
                    if (type(val)=='table') then
                        Trace(indent..'#['..i..'] => '..tostring(t)..' {')
                        sub_print_r(val,indent..string.rep(' ',string.len(i)+8))
                        Trace(indent..string.rep(' ',string.len(i)+6)..'}')
                    elseif (type(val)=='string') then
                        Trace(indent..'#['..i..'] => "'..val..'"')
                    else
                        Trace(indent..'#['..i..'] => '..tostring(val))
                    end
                end
                for pos,val in pairs(t) do
                    if type(pos) ~= 'number' or math.floor(pos) ~= pos or (pos < 1 or pos > tLen) then
                        if (type(val)=='table') then
                            Trace(indent..'['..pos..'] => '..tostring(t)..' {')
                            sub_print_r(val,indent..string.rep(' ',string.len(pos)+8))
                            Trace(indent..string.rep(' ',string.len(pos)+6)..'}')
                        elseif (type(val)=='string') then
                            Trace(indent..'['..pos..'] => "'..val..'"')
                        else
                            Trace(indent..'['..pos..'] => '..tostring(val))
                        end
                    end
                end
            else
                Trace(indent..tostring(t))
            end
        end
    end
    
   if (type(t)=='table') then
        Trace(tostring(t)..' {')
        sub_print_r(t,'  ')
        Trace('}')
    else
        sub_print_r(t,'  ')
    end
    return '(table, check console)'; -- For hey.ParseVar(), or anything which prints the result.
end

-- hey.ParseVar ( mixed v )
function hey.ParseVar(v)
    if v or v == false then
        local t = type(v);
        if t == 'userdata' then
            return '(Actor)';
        elseif t == 'thread' then
            return '(Thread)';
        elseif t == 'table' then
            return hey.PrintR(v);
            -- Old code, kept for archival purposes
            --[[local tableText = '{ ';
            for i2,v2 in pairs(v) do
                if v2 ~= _G then
                    tableText = tableText .. '"' .. i2 .. '":' .. hey.ParseVar(v2) .. ', ';
                end
            end
            tableText = string.sub(tableText, 0, -3);
            return tableText .. ' }';]]
        elseif t == 'function' then
            return '(function)';
        elseif t == 'boolean' then
            return (v and 'true' or 'false');
        elseif t == 'string' then
            return '"' .. v .. '"';
        elseif t == 'number' then
            return hey.Round(v, 3);
        else
            return '(wtf ?)';
        end
    elseif v == nil then
        return '(nil)';
    else
        return '(wtf ?)';
    end
end

function hey.GetCurBPM()
    return hey.Round(GAMESTATE:GetCurBPS()*60, 4);
end

function hey.RandomFloat(l, g)
    if l and g and type(l) == 'number' and type(g) == 'number' then
        return l + math.random() * (g-l);
    end
    hey.Debug('You forgot an argument when calling hey.RandomFloat().');
    return math.random();
end

function hey.IsNAN(v)
    return v ~= v;
end

function hey.GetPercentage(n)
    if n and (n == 1 or n == 2) then
        if GAMESTATE:IsPlayerEnabled(n-1) then
            local stage = STATSMAN:GetCurStageStats():GetPlayerStageStats(n-1);
            local ret = stage:GetActualDancePoints() * 100 / stage:GetPossibleDancePoints();
            return hey.IsNAN(ret) and 0 or ret;
        else
            hey.Debug('The player ' .. n .. ' is not enabled !');
            return 0;
        end
    elseif n then
        hey.Debug('hey.GetPercentage(): Invalid second argument. It must be 1 or 2. You wrote :' .. n);
    end
    return 0;
end

function hey.Round(n, d)
    if n and type(n) == 'number' then
        --if d and d>0 then
            --local m = 10^math.floor(d+0.5);
            local m = 10^((d and d>0) and math.floor(d+0.5) or 0);
            return math.floor(n*m+0.5)/m;
        --end
        --return math.floor(n+0.5);
    elseif n then
        hey.Debug('Arguments of hey.Round() aren\'t numbers.');
    else
        hey.Debug('You forgot the arguments of hey.Round().');
    end
    return 1;
end

function hey.GetSubtitle(song)
    return string.sub(song:GetDisplayFullTitle(), string.len(song:GetDisplayMainTitle()) + 2);
end

function hey.GetStepsDescriptionText(song)
    local st = GAMESTATE:GetCurrentSteps(1);
    if not st then
        st = GAMESTATE:GetCurrentSteps(2);
        if not st then
            return '(Unknown)';
        end
    end
    local ret = st:GetDescription();
    local tmp = string.lower(ret);
    if tmp == 'blank'
    or tmp == '.'
    or tmp == 'unknown'
    or string.find(tmp, 'copied from') then
        return '';
    end
    return ret;
end

-- config --
hey.enableRemote = false;
hey.updateSleep = 0.2;
-- /config --

if not hey.enableRemote then
    hey.updateSleep = 99999;
end

function hey.UpdateCommand()
    if hey.enableRemote then
        Trace(' ');
        Trace(' ');
        Trace(' ');
        Trace('heyupdate');
        Trace(' ');

        Trace('CHECKING IF WAITING CMD');
        local wc = io.open(hey.basePath .. 'waiting_cmd.txt');
        if not wc then
            Trace('NOT WAITING, ABORTING');
            return;
        end
        wc:close();

        Trace('CHECKING IF SENT RESPONSE');
        local sr = io.open(hey.basePath .. 'sent_res.txt');
        if sr then
            Trace('ALREADY SENT ANSWER, ABORTING');
            sr:close();
            return;
        end

        Trace('WAITING AND NOT ANSWERED: CREATING RES');
        local res = io.open(hey.basePath .. 'res.txt', 'w');
        if not res then
            Trace('ERROR WHEN CREATING RES, ABORTING');
            return;
        end

        res:seek('set');
        Trace('RES READY TO WRITE, COMPILING CMD');

        local c,e = loadfile(hey.basePath .. 'cmd.txt');
        if type(c) == 'function' then
            Trace('COMPILATION DONE! PCALL')
            local res2 = {pcall(c)};
            if res2[1] then
                Trace('PCALL TRUE: WRITING OUTPUT');
                res:write(hey.ParseVar(res2[2]) .. '\n');
            else
                Trace('PCALL FALSE: WRITING ERROR')
                res:write('Error: ' .. hey.ParseVar(res2[2]) .. '\n');
            end
        else
            Trace('COMPILATION FAILED: ' .. tostring(e));
            res:write('Compilation error: ' .. hey.ParseVar(res[2]) .. '\n');
        end

        Trace('FINISHED EXECUTING CMD, SAVING AND CLOSING RES');
        res:flush();
        res:close();

        Trace('SENDING RES');
        sr = io.open(hey.basePath .. 'sent_res.txt', 'w');
        if not sr then
            Trace('ERROR WHEN CREATING SENT_RES?');
        end
        sr:flush();
        sr:close();

        Trace('DONE');

        Trace(' ');
        Trace(' ');
        Trace(' ');
    end
end

hey.streamMode = false;
hey.basePath = 'C:\\Users\\Daikyi\\Documents';
hey.JF, hey.JFE = io.open(hey.basePath .. 'judgments.txt', 'w+');
hey.SF, hey.SFE = io.open(hey.basePath .. 'songinfos.txt', 'w+');
if not hey.JFE and io.type(hey.JF) == 'file'
and not hey.SFE and io.type(hey.SF) == 'file' then -- Streaming mode !

    hey.streamMode = true;

    function hey.WriteJudgment(resetScore)
        local s = '';
        for i,v in ipairs(hey.GJ) do
            s = s .. v .. '\n';
        end
        for i,v in ipairs(hey.J) do
            s = s .. v .. '\n';
        end
        if not resetScore then
            s = s .. math.max(math.floor(hey.GetPercentage(1)*100)/100, 0) .. '\n';
            if (GAMESTATE:IsPlayerEnabled(0)) then
                s = s .. math.floor(SCREENMAN:GetTopScreen():GetLife(0)*100 + 0.5) .. '\n';
            else
                s = s .. math.floor(SCREENMAN:GetTopScreen():GetLife(1)*100 + 0.5) .. '\n';
            end
        else
            s = s .. '0\n50\n';
        end
        hey.JF:seek('set'); -- Set cursor to 0
        hey.JF:write(s);
        hey.JF:flush(); -- Save
    end 
    
    function hey.WriteSongInfos(s)
        hey.SF:seek('set'); -- Set cursor to 0
        hey.SF:write(s);
        hey.SF:flush(); -- Save
    end

    function hey.ResetJudgment()
        hey.JF:close();
        hey.JF = io.open(hey.basePath .. 'judgments.txt', 'w+');
        hey.JF:flush();
    end

    function hey.ResetSongInfos()
        hey.SF:close();
        hey.SF = io.open(hey.basePath .. 'songinfos.txt', 'w+');
        hey.JF:flush();
    end

    hey.GJ = {0,0,0,0,0,0};
    hey.J = {0,0,0,0,0,0};

    hey.ResetJudgment();
    hey.ResetSongInfos();
    hey.Debug('Stream mode enabled!');

else
    for i=1,50 do
        hey.Debug('Stream mode unable to start : ' .. hey.ParseVar(hey.JFE) .. ' / ' .. hey.ParseVar(hey.SFE));
    end
end