class "StoreManager"

function StoreManager:Dispatch(p_Key, p_Value)
    -- print(string.format("vext.dispatch('%s', %s)", p_Key, json.encode(p_Value)))
    WebUI:ExecuteJS(string.format("StoreDispatch('%s', %s)", p_Key, json.encode(p_Value)))
end

function StoreManager:Commit(p_Key, p_Value)
    -- print(string.format("vext.dispatch('%s', %s)", p_Key, json.encode(p_Value)))
    WebUI:ExecuteJS(string.format("StoreCommit('%s', %s)", p_Key, json.encode(p_Value)))
end

return StoreManager()