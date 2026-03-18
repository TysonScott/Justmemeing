print("SCRIPT LOADED:", tick())

local startTime = tick()
local detected = false

local leavesFolder = workspace:WaitForChild("Interactive"):WaitForChild("Leaves")

local trackedLeaves = {}

local function trackLeaf(leaf)
    if not (leaf:IsA("BasePart") and leaf.Name == "Circle") then return end

    -- mark initial state
    trackedLeaves[leaf] = {
        wasInvisible = (leaf.Transparency == 1)
    }

    -- listen for changes
    leaf:GetPropertyChangedSignal("Transparency"):Connect(function()
        if detected then return end

        local data = trackedLeaves[leaf]
        if not data then return end

        -- only trigger if it was invisible FIRST
        if data.wasInvisible and leaf.Transparency == 0 then
            detected = true

            local timeTaken = tick() - startTime

            print("------")
            print("Leaf became collectable after:", timeTaken, "seconds")
            print("Respawn baseline: 60.23s")

            if timeTaken < 60.23 then
                print("✅ Server hopping is FASTER")
            else
                print("❌ Waiting is BETTER")
            end
            print("------")
        end
    end)
end

-- Track all existing leaves
for _, v in pairs(leavesFolder:GetDescendants()) do
    trackLeaf(v)
end

-- Track new ones
leavesFolder.DescendantAdded:Connect(trackLeaf)

-- 🔥 IMPORTANT: check instant availability properly
task.delay(1, function()
    if detected then return end

    for leaf, data in pairs(trackedLeaves) do
        if leaf.Transparency == 0 then
            detected = true

            print("------")
            print("Leaf was ALREADY available on join (0s)")
            print("Respawn baseline: 60.23s")
            print("🚀 Server hopping is VERY FAST")
            print("------")
            break
        end
    end
end)
