-- utility for scheduling tasks
-- For each task, the key is the scheduled time and the value is the function
tasks = {}

function steptasks(scenarioTime)
    -- First argument should be the scenario time
    if next(tasks) then
        toRemove = {}
        for key, value in pairs(tasks) do
            if scenarioTime > key then
                value()
                toRemove[#toRemove + 1] = key
            end
        end
        for _, doneTask in ipairs(toRemove) do
            table.remove(tasks, doneTask)
        end
    end
end

function addTask(task, time)
    tasks[time] = task
end