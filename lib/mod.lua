local mod = require 'core/mods'

if note_players == nil then
    note_players = {}
end

local function add_euro_voice_params(idx)
    params:add_group("txo_euro_" .. idx, "txo euro " .. idx, 1)

    params:add_number(
        "cv_slew_" .. idx,
        "Slew Time (ms) ",
        0,
        1000,
        12,
        function(param) return param:get() * 10 .. 'ms' end
    )
    params:set_action("cv_slew_" .. idx, function(param)
        local ms = param * 10
        crow.ii.txo.cv_slew(idx, ms)
    end)

    params:hide("txo_euro_" .. idx)
end

local function add_euro_voice(idx)
    local player = {
        count = 0,
        idx = idx
    }

    function player:add_params()
        add_euro_voice_params(idx)
    end

    function player:play_note(note, vel, length, properties)
        self:note_on(note, vel, properties)
        clock.run(function()
            clock.sleep(length*clock.get_beat_sec())
            self:note_off(note)
        end)
    end

    function player:note_on(note, vel)
        crow.ii.txo.tr_tog(player.idx)

        local v8 = (note - 60)/12
        crow.ii.txo.cv(player.idx, v8) 
    end

    function player:note_off(note)
        crow.ii.txo.tr_tog(player.idx)
    end

    function player:set_time(ms)
        crow.ii.txo.tr_time(idx, ms)
    end

    function player:set_slew(ms)
        crow.ii.txo.cv_slew(idx, ms)
    end

    function player:describe()
        return {
            name = "txo euro " .. idx
        }
    end

    function player:active()
        if self.name ~= nil then
            crow.ii.txo.tr_init(player.idx)
            crow.ii.txo.cv_init(player.idx)
            params:show("txo_euro_" .. idx)
            _menu.rebuild_params()
        end
    end

    function player:inactive()
        if self.name ~= nil then
            params:hide("txo_euro_" .. idx)
            _menu.rebuild_params()
        end
    end


       
    note_players["txo euro " .. idx] = player
end

mod.hook.register("script_pre_init", "nb txo euro voice pre init", function()
    for n=1,4 do
        add_euro_voice(n)
    end
end)



