require "imageLoad"
function love.load()
    OS = 1
    CPU = "Intex 80284 @ 6 MHz"
    iGPU = "Monochrome 1-bit"
    dGPU = "-"
    RAM = 0.5
    FDD = "5.25\""
    HDD = 16
    monitorType = "CRT"
    monitorSize = 9
    totalColors = 2
    colorZones = 1
    segmentsToFill = 4
    systemYear = 1984
    font12 = love.graphics.newFont(12)
    font18 = love.graphics.newFont(18)
    level = 1
    score = 0
    totalScore = 0
    isSegmentError = 0
    errorProb = 20
    minusProb = 10
    typeRNG = 0
    screen = "nongame"
    progressDespawnTiming = 1000
    untilSegmentSpawn = 1800
    progressControl = true
    openWindows = {}
    segments = {}
    progressbar = {}
    progressSegments = {}
    imageLoad()
end

function love.mousepressed(x, y, button)
    if x >= 6 and x <= 106 and y >= 974 and y <= 1074 and screen == "nongame" then
        screen = "game"
        createBar()
    end
    if x >= 1814 and x <= 1914 and y >= 16 and y <= 116 and screen == "nongame" then
        createWindow(760, 240, 400, 600, "System information", "OS: Progresscolor " .. OS .. "\nCPU: " .. CPU .. "\niGPU (Grayscale): " .. iGPU .. "\ndGPU (Color): " .. dGPU .. "\nRAM: " .. RAM .. "MB\nFDD: " .. FDD .. "\nHDD: " .. HDD .. "MB\nMonitor: " .. monitorType .. " " .. monitorSize .. "\"\nTotal colors: " .. totalColors .. "\nColor zones: " .. colorZones .. "\nSegment zones: " .. segmentsToFill .. "\nSystem release: " .. systemYear)
    end
    for i,v in ipairs(openWindows) do
        if x >= (v.x + v.width) - 33 and x <= (v.x + v.width) - 2 and y >= v.y + 2 and y <= v.y + 32 then
            table.remove(openWindows, i)
        end
    end
end

function createWindow(x, y, width, height, title, text)
    window = {}
    window.x = x
    window.y = y
    window.width = width
    window.height = height
    window.title = title
    window.text = text
    table.insert(openWindows, window)
end

function createSegment()
    if screen == "game" then
        segment = {}
        segment.x = math.random(0, 1905)
        segment.y = 0
        segment.speed = math.min(240 + level * 12, 720)
        typeRNG = math.random(1, 100)
        if typeRNG <= errorProb then
            segment.type = "r"
        elseif typeRNG > errorProb and typeRNG <= errorProb + minusProb then
            segment.type = "m"
        else
            segment.type = "b"
        end
        table.insert(segments, segment)
    end
end

function createBar()
    progressbar = {}
    bar = {}
    if progressControl == true then
        bar.x = love.mouse.getX()
        bar.y = love.mouse.getY()
    else
        bar.x = 800
        bar.y = 516
    end
    table.insert(progressbar, bar)
end

function switchControl()
    if progressControl == false then
        progressControl = true
    else
        progressControl = false
    end
end

function switchGMode()
    if screen == "nongame" then
        screen = "game"
    else
        screen = "nongame"
    end
end

function love.update(dt)
    if screen == "game" then
        openWindows = {}
        if untilSegmentSpawn > 0 then
            untilSegmentSpawn = untilSegmentSpawn - 1000 * dt
        else
            for i=1,2 do
                createSegment()
            end
            untilSegmentSpawn = 2400
        end
    end
    for i,v in ipairs(segments) do
        v.y = v.y + v.speed * dt
        if #progressbar ~= 0 and v.x >= progressbar[1].x and v.x <= progressbar[1].x + 320 and v.y >= progressbar[1].y and v.y <= progressbar[1].y + 48 then
            if v.type == "r" then
                segments = {}
                progressbar = {}
                score = score - 1000
                totalScore = score - 1000
                untilSegmentSpawn = 2400
                screen = "nongame"
                progressSegments = {}
            elseif v.type == "m" then
                table.remove(segments, i)
                table.remove(progressSegments, #progressSegments)
            elseif v.type == "b" then
                table.remove(segments, i)
                table.insert(progressSegments, "w")
            end
        end
    end
    for i,v in ipairs(progressbar) do
        if progressControl == true then
            v.x = love.mouse.getX() - 160
            v.y = love.mouse.getY() - 48
        end
    end
    if #progressSegments >= segmentsToFill then
        segments = {}
        progressControl = true
        progressbar[1].x = 800
        progressbar[1].y = 100
        if progressDespawnTiming > 0 then
            progressDespawnTiming = progressDespawnTiming - dt * 1000
            untilSegmentSpawn = 2400
        else
            progressDespawnTiming = 1000
            untilSegmentSpawn = 2400
            progressSegments = {}
            progressControl = true
            progressbar = {}
            score = score + (700 + 100 * level)
            totalScore = totalScore + (700 + 100 * level)
            level = level + 1
            if totalScore >= 25000 and totalScore < 60000 then
                if OS ~= 2 then
                    score = 0
                end
                OS = 2
                CPU = "Intex 80384 @ 12 MHz"
                iGPU = "Grayscale 2-bit"
                RAM = 1
                HDD = 16
                totalColors = 4
                segmentsToFill = 6
                systemYear = 1986
            elseif totalScore >= 60000 then
                if OS ~= 3 then
                    score = 0
                end
                OS = 3
                CPU = "Intex 80484 @ 20 MHz"
                iGPU = "Grayscale 4-bit"
                RAM = 4
                FDD = "3.5\""
                HDD = 40
                totalColors = 16
                segmentsToFill = 8
                systemYear = 1989
            end
            screen = "nongame"
        end
    end
end

function love.draw(dt)
    love.graphics.setFont(font18)
    love.graphics.printf(string.format("Level %d", level), 760, 10, 400, "center")
    love.graphics.setFont(font12)
    love.graphics.printf(string.format("Score: %d (%.2f%% to next OS)", score, score/25000*100), 760, 32, 400, "center")
    love.graphics.printf(string.format("Total Score: %d", totalScore), 760, 48, 400, "center")
    if OS == 1 then
        love.graphics.draw(about_system, 1814, 16, 0, 0.390625)
        love.graphics.draw(logo_img, 6, 974, 0, 0.390625)
    elseif OS == 2 then
        love.graphics.draw(about_system2, 1814, 16, 0, 0.390625)
        love.graphics.draw(logo_img2, 6, 974, 0, 0.390625)
    elseif OS == 3 then
        love.graphics.draw(about_system3, 1814, 16, 0, 0.390625)
        love.graphics.draw(logo_img3, 6, 974, 0, 0.390625)
    end
    love.graphics.print("v0.1 01.02.2024", 1810, 0)
    for i,v in ipairs(progressbar) do
        if OS == 1 then
            love.graphics.draw(progressbar_img, v.x, v.y)
        elseif OS == 2 then
            love.graphics.draw(progressbar_img2, v.x, v.y)
        elseif OS == 3 then
            love.graphics.draw(progressbar_img3, v.x, v.y)
        end
        love.graphics.setColor(0,0,0)
        love.graphics.setFont(font18)
        love.graphics.printf(string.format("%d%%", (#progressSegments / segmentsToFill * 100)), v.x, v.y + 14, 320, "center")
        love.graphics.setFont(font12)
        love.graphics.setColor(1,1,1)
    end
    for i,v in ipairs(segments) do
        if OS == 1 then
            if v.type == "r" then
                love.graphics.draw(segment_r, v.x, v.y, 0, 1)
            elseif v.type == "m" then
                love.graphics.draw(segment_m, v.x, v.y, 0, 1)
            elseif v.type == "b" then
                love.graphics.draw(segment_b, v.x, v.y, 0, 1)
            end
        elseif OS == 2 then
            if v.type == "r" then
                love.graphics.draw(segment_r2, v.x, v.y, 0, 1)
            elseif v.type == "m" then
                love.graphics.draw(segment_m2, v.x, v.y, 0, 1)
            elseif v.type == "b" then
                love.graphics.draw(segment_b2, v.x, v.y, 0, 1)
            end
        elseif OS == 3 then
            if v.type == "r" then
                love.graphics.draw(segment_r3, v.x, v.y, 0, 1)
            elseif v.type == "m" then
                love.graphics.draw(segment_m3, v.x, v.y, 0, 1)
            elseif v.type == "b" then
                love.graphics.draw(segment_b3, v.x, v.y, 0, 1)
            end
        end
    end
    for i,v in ipairs(openWindows) do
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
        love.graphics.draw(close, (v.x + v.width) - 33, v.y + 2, 0, 0.12)
        love.graphics.setColor(0,0,0)
        love.graphics.setFont(font18)
        love.graphics.printf(v.title, v.x, v.y + 5, v.width, "center")
        love.graphics.printf(v.text, v.x + 8, v.y + 45, v.width - 8, "left")
        love.graphics.setFont(font12)
        love.graphics.setColor(1,1,1)
    end
end