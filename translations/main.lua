local Text = {}

translate = function(resource, language, _format)
    language = Text[language] and language or "xx"
    
    local obj = unreference(Text[language])
    for key in resource:gmatch("%S+") do
        if type(obj) == "table" then
            obj = obj[key]
            if not obj then
                break
            end
        else
            break
        end
    end
    
    if obj then
        if type(_format) == "table" then
            for key, value in next, _format do
                local keyv = "%$" .. key .. "%$"
                obj = obj:gsub(keyv, tostring(value))
            end
        else
            return tostring(obj)
        end
    else
        if language ~= "xx" then
            translate(resource, "xx", _format)
        else
            obj = resource:gsub(" ", "%.")
        end
    end
    
    return obj
end

require("en")

Text["xx"] = Text["en"]

require("es")

require("br")