local triggered = false

AddEventHandler("playerSpawned", function()
    if not triggered then 
        triggered = true
        Citizen.CreateThread(function()
            Citizen.Wait(1000 * 20) -- Wait 20 seconds
            TriggerServerEvent('Dead_Discord_API:PlayerLoaded')
        end)
    end
end)