-- title:  CrabCrib
-- author: game developer
-- desc:   short description
-- script: lua
SpriteSize = 8
DefaultInvisableColor = 14
ShellLists = {}
BonusLists = {}
FallingList = {}
brickCountWidth = 19
brickCountHeight = 12
gravity = 0.1
jumpTimes = 0
mapX = 0
mapY = 0
mapWidth = 30
mapHeight = 17
levelCount = 20

function getLevel()
    return mapX // 30 + mapY // 17 * 8
end
-- 屏幕绘制对象基类
Base = {
    x = 0, -- 横坐标
    y = 0, -- 纵坐标
    f = 0, -- 翻转
    s = 1, -- 缩放
    r = 0 -- 旋转
}

-- 通过传入o参数派生对象
-- [flip][scale][rotate]
-- f:0=No Flip, 1=Flip horizontally, 2=Flip vertically, 3=Both1,2
-- r:clockwise 0, 90, 180, 270
function Base:new(obj, x, y, scale, flip, rotate)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    obj.x = x or 0
    obj.y = y or 0
    obj.s = scale or 1
    obj.f = flip or 0
    obj.r = rotate or 0
    return obj
end

-- 对象类型，初始只包括图元信息
Object = {
    -- 对应Sprite的id, 当其值为-1时，表示绘制矩形
    id = -1,
    -- 宽
    width = 1,
    -- 高
    height = 1,
    -- 透明颜色, 当绘制矩形时为矩形颜色
    color = DefaultInvisableColor
}

-- load，实例化图元
function Object:load(id, width, height, color)
    local e = {}
    setmetatable(e, self)
    self.__index = self
    e.id = id or -1
    e.width = width or 1
    e.height = height or 1
    e.color = color or DefaultInvisableColor
    return e
end

-- init，通过实例化图元初始化屏幕中对象
function Object:init(class, x, y, s, f, r)
    local obj = Base:new(class, x, y, s, f, r)
    setmetatable(obj, self)
    self.__index = self
end

-- 绘制
function Object:draw()
    if self.id == -1 then
        if self.r % 2 == 0 then
            rect(self.x, self.y, self.width * self.s, self.height * self.s, self.color)
        else
            rect(self.x, self.y, self.height * self.s, self.width * self.s, self.color)
        end
    else
        spr(self.id, self.x, self.y, self.color, self.s, self.f, self.r, self.width, self.height)
    end
end

-- 获取对象横向长度
function Object:getWidth()
    if self.r % 2 == 0 then
        if self.id == -1 then
            return self.width * self.s
        else
            return self.width * self.s * SpriteSize
        end
    else
        if self.id == -1 then
            return self.height * self.s
        else
            return self.height * self.s * SpriteSize
        end
    end
end

-- 获取对象纵向长度
function Object:getHeight()
    if self.r % 2 == 1 then
        if self.id == -1 then
            return self.width * self.s
        else
            return self.width * self.s * SpriteSize
        end
    else
        if self.id == -1 then
            return self.height * self.s
        else
            return self.height * self.s * SpriteSize
        end
    end
end

function Object:rotate(by90deg)
    r = r or 1
    self.r = (self.r + r) % 4
end

function Object:scale(bigOrSmall)
    bigOrSmall = bigOrSmall or 0
    if bigOrSmall == 0 and self.s ~= 8 then
        self.s = self.s * 2
    elseif bigOrSmall == 1 and self.s ~= 1 then
        self.s = self.s / 2
    end
end

function Object:flip(flipType)
    flipType = flipType or 1
    if self.f == flipType then
        self.f = 0
    else
        self.f = flipType
    end
end

function Object:getTilesAround(direction)
    direction = direction or 0
    if direction == 0 then
        return -- 上 右 下 左 重叠
        myMget(self.x // SpriteSize, (self.y - 1) // SpriteSize),
            myMget((self.x + self:getWidth()) // SpriteSize, self.y // SpriteSize),
            myMget(self.x // SpriteSize, (self.y + self:getHeight()) // SpriteSize),
            myMget((self.x - 1) // SpriteSize, self.y // SpriteSize), myMget(self.x // SpriteSize, self.y // SpriteSize)
    elseif direction == 1 then
        return myMget(self.x // SpriteSize, (self.y - 1) // SpriteSize)
    elseif direction == 2 then
        return myMget((self.x + self:getWidth()) // SpriteSize, self.y // SpriteSize)
    elseif direction == 3 then
        return myMget(self.x // SpriteSize, (self.y + self:getHeight()) // SpriteSize)
    elseif direction == 4 then
        return myMget((self.x - 1) // SpriteSize, self.y // SpriteSize)
    elseif direction == 5 then
        return myMget(self.x // SpriteSize, self.y // SpriteSize)
    end
end

Player = {
    speedX = 0,
    speedY = 0,
    maxSpeed = 1.5,
    -- 按键时加速度
    speedJump = -2.6,
    accelerate = 1,
    -- 摩擦力减速度
    friction = 0.5,
    withShell = false,
    withShellType = -1,
    waterFriction = 0.4,
    -- 存档点
    homeX = -1,
    homeY = -1,
    bonusCount = 0,
    deathCount = 0
}

function Player:aboveShell()
    for i, shell in pairs(ShellLists[getLevel()]) do
        -- get parameters
        local x = shell.x
        local y = shell.y
        local w = shell:getWidth()
        local h = shell:getHeight()

        if self.speedY > 0 and self.y <= y then
            -- collide left or right side
            if collide(self, shell) then
                return true
            end
        end
    end
    return false
end

function Player:exactOverShell()
    for i, shell in pairs(ShellLists[getLevel()]) do
        -- get parameters
        local x = shell.x
        local y = shell.y
        local w = shell:getWidth()
        local h = shell:getHeight()
        if self.y + self:getHeight() == y and (self.x + self:getWidth()) >= x and self.x <= (x + w) then
            return true
        end
    end
    return false
end

function Player:groundCollision() -- false empty
    if self:belowDetection() == 1 or self:belowDetection() == 2 or self:aboveShell() then
        return true
    else
        return false
    end
end

function Object:belowDetection() -- 1:rock 2:sand 3: water 4:poision
    if myMget((self.x) // SpriteSize, (self.y + self:getHeight()) // SpriteSize) == 1 or
        myMget((self.x + self:getWidth() - 1) // SpriteSize, (self.y + self:getHeight()) // SpriteSize) == 1 then
        return 1
    end
    if myMget((self.x) // SpriteSize, (self.y + self:getHeight()) // SpriteSize) == 2 or
        myMget((self.x + self:getWidth() - 1) // SpriteSize, (self.y + self:getHeight()) // SpriteSize) == 2 then
        return 2
    end
    if myMget((self.x) // SpriteSize, (self.y + self:getHeight()) // SpriteSize) == 3 and
        myMget((self.x + self:getWidth() - 1) // SpriteSize, (self.y + self:getHeight()) // SpriteSize) == 3 then
        return 3
    end
    if myMget((self.x) // SpriteSize, (self.y + self:getHeight()) // SpriteSize) == 4 and
        myMget((self.x + self:getWidth() - 1) // SpriteSize, (self.y + self:getHeight()) // SpriteSize) == 4 then
        return 4
    end
end

function Player:ceilingCollision()
    if self.speedY < 0 and self:rockUpCollision() and self.withShell == true then
        if self.shell.restBreakTimes ~= 0 then -- is shell still ok
            self.shell.restBreakTimes = self.shell.restBreakTimes - 1
            -- break a rock
            sfx(2)
            myMset((self.x + self:getWidth() / 2 - 1) // SpriteSize, (self.y - 1) // SpriteSize, 0)
            self.speedY = 0
            Fall((self.x + self:getWidth() / 2 - 1) // SpriteSize, (self.y - 1) // SpriteSize)
            if self.shell.restBreakTimes <= 0 then
                -- the shell broke
                music("00")
                self.id = 272
                self.height = 1
                self.y = self.y + SpriteSize
                self.withShell = false
                self.withShellType = 0
            end
        end
    end
    return self:getTilesAround(1) ~= 0 or
               myMget((self.x + self:getWidth() - 1) // SpriteSize, (self.y - 1) // SpriteSize) ~= 0
end

function Fall(xIndex, yIndex)
    -- 从打碎岩石位置向上遍历地图，将sand块插入FallingList
    for i = yIndex, -1, -1 do
        -- sand sprite judge sand & not on Rock or Sand
        if myMget(xIndex, i) == 2 and myMget(xIndex, i + 1) ~= 1 and myMget(xIndex, i + 1) ~= 2 then
            myMset(xIndex, i, 0)
            SandLook = Object:load(2, 1, 1)
            local sand = {}
            SandLook:init(sand, xIndex * SpriteSize, i * SpriteSize)
            -- local exist = false
            -- for j, sand0 in pairs(FallingList) do
            --     if sand.y == sand0.y then
            --         exist = true
            --     end
            -- end
            -- if exist == false then
            table.insert(FallingList, sand)
            -- end
        end
    end
end

function Player:update()
    self:wallCollision()
    -- 摩擦力减速至0
    if self.speedX > 0 then
        self.speedX = self.speedX - self.friction
        if self.speedX < 0 then
            self.speedX = 0
        end
    elseif self.speedX < 0 then
        self.speedX = self.speedX + self.friction
        if self.speedX > 0 then
            self.speedX = 0
        end
    end
    self.x = self.x + self.speedX
    if self:groundCollision() == false and (self:getTilesAround(5) == 3 or self:getTilesAround(5) == 4) then
        self.speedY = self.speedY + gravity - 0.02
    elseif self:groundCollision() == false then
        self.speedY = self.speedY + gravity
    end
    self.y = self.y + self.speedY
    if self.speedY > 0 and self:groundCollision() == true then
        self.y = self.y // 8 * 8
        self.speedY = 0
    end
    if self:ceilingCollision() == true then
        self.speedY = 0
    end
    -- 进入毒
    if self:getTilesAround(5) == 4 then
        -- sfx(4)
        if self.withShellType ~= 3 then
            self.deathCount = self.deathCount + 1
            self:die()
        end
    end
end

function Player:die()
    sfx(1)
    self.x = self.homeX
    if self.withShell then
        self.y = self.homeY
    else
        self.y = self.homeY
    end
end

function Player:shellWeight(withShellType)
    if withShellType == 0 then -- nothing
        self.speedY = self.speedY
    end
    if withShellType == 1 then -- normal shell
        self.speedY = self.speedY - 0.3
    end
    if withShellType == 2 then -- sharp shell
        self.speedY = self.speedY - 0.5
    end
    if withShellType == 3 then -- anti posion shell
        self.speedY = self.speedY - 0.2
    end
    return self.speedY
end

function Player:anim()
    local step = 0
    if self.withShell then
        step = 32
    else
        step = 1
    end
    self.id = self.id + step
end

-- return the index of collided shell
function Player:shellCollision()
    for i, shell in pairs(ShellLists[getLevel()]) do
        if collide(self, shell) then
            return i
        end
    end
    return -1
end

function Player:input()
    -- left
    if btn(2) then
        if self:getTilesAround(5) == 3 or self:getTilesAround(5) == 4 then
            self.speedX = math.max(self.speedX - self.accelerate + self.waterFriction,
                -self.maxSpeed + self.waterFriction)
        else
            self.speedX = math.max(self.speedX - self.accelerate, -self.maxSpeed)
        end
        self:wallCollision(2)
    end
    -- right
    if btn(3) then
        if self:getTilesAround(5) == 3 or self:getTilesAround(5) == 4 then
            self.speedX = math.min(self.speedX + self.accelerate - self.waterFriction,
                self.maxSpeed - self.waterFriction)
        else
            self.speedX = math.min(self.speedX + self.accelerate, self.maxSpeed)
        end
        self:wallCollision(3)
    end
    if self:groundCollision() == true then
        jumpTimes = 0
    end
    -- space
    if (keyp(48) and self:groundCollision() == true) or (keyp(48) and self:exactOverShell() == true) then -- if press space button,then jump 
        self.speedY = self.speedJump
        self.speedY = self:shellWeight(withShellType)
    elseif keyp(48) and (self:getTilesAround(5) == 3 or self:getTilesAround(5) == 4) then
        self.speedY = self.speedJump - 0.3
        self.speedY = self:shellWeight(withShellType)
    end
    -- p
    -- if keyp(16) then
    -- Up
    if btnp(0) then
        pos = self:shellCollision()
        if pos ~= -1 then -- press p to pick shell or switch shell or drop shell	
            music(0, 0, -1, false)
            if self.withShell == false then
                self.withShell = true
                -- change Player apperence
                self.id = ShellLists[getLevel()][pos].id + 32
                self.height = 2
                self.y = self.y - SpriteSize
                --------------------------
                self.withShellType = ShellLists[getLevel()][pos].shellType
                self.shell = ShellLists[getLevel()][pos]
                table.remove(ShellLists[getLevel()], pos)
            else
                -- drop current shell
                local shell = self.shell
                ShellLook:init(shell, self.x, self.y + SpriteSize)
                table.insert(ShellLists[getLevel()], shell)
                -- change the homeXY
                self.homeX = self.x
                self.homeY = self.y
                -- pick new shell
                self.id = ShellLists[getLevel()][pos].id + 32
                self.withShellType = ShellLists[getLevel()][pos].shellType
                self.shell = ShellLists[getLevel()][pos]
                table.remove(ShellLists[getLevel()], pos)
            end
        elseif self.withShell then
            -- change Player apperence
            self.id = 272
            self.height = 1
            self.y = self.y + SpriteSize
            --------------------------
            self.withShell = false
            self.withShellType = 0
            -- drop current shell
            local shell = self.shell
            ShellLook:init(shell, self.x, self.y)
            table.insert(ShellLists[getLevel()], shell)
            -- change the homeXY
            self.homeX = self.x
            self.homeY = self.y - self:getHeight()
        end
    end
    -- d
    -- if keyp(4) then
    -- Down
    if btnp(1) then
        if self:sandCollision() then
            sfx(5)
            myMset((self.x + self:getWidth() / 2) // SpriteSize, (self.y + self:getHeight()) // SpriteSize, 0)

        end
    end
    -- h
    if keyp(8) then
        self:die()
    end
end

function Player:sandCollision()
    return self:getTilesAround(3) == 2
end

function Player:rockUpCollision()
    return myMget((self.x + self:getWidth() / 2 - 1) // SpriteSize, (self.y - 1) // SpriteSize) == 1
end

function Player:sandDownCollision()
    return myMget((self.x + self:getWidth() / 2 - 1) // SpriteSize, (self.y + self:getHeight()) // SpriteSize) == 2
end

function Player:wallCollision(btnId)
    if btnId == 2 then
        if self:getTilesAround(4) ~= 0 or
            myMget((self.x - 1) // SpriteSize, (self.y + self:getHeight() - 1) // SpriteSize) ~= 0 then
            if self:getTilesAround(4) == 1 or
                myMget((self.x - 1) // SpriteSize, (self.y + self:getHeight() - 1) // SpriteSize) == 1 or
                self:getTilesAround(4) == 2 or
                myMget((self.x - 1) // SpriteSize, (self.y + self:getHeight() - 1) // SpriteSize) == 2 then
                self.speedX = 0
            end
        end
    elseif btnId == 3 then
        if self:getTilesAround(2) ~= 0 or
            myMget((self.x + self:getWidth()) // SpriteSize, (self.y + self:getHeight() - 1) // SpriteSize) ~= 0 then
            if self:getTilesAround(2) == 1 or
                myMget((self.x + self:getWidth()) // SpriteSize, (self.y + self:getHeight() - 1) // SpriteSize) == 1 or
                self:getTilesAround(2) == 2 or
                myMget((self.x + self:getWidth()) // SpriteSize, (self.y + self:getHeight() - 1) // SpriteSize) == 2 then
                self.speedX = 0
            end
        end
    end
end

NormalShell = {
    id = 256,
    shellType = 1,
    restBreakTimes = 0
}

SuperShell = {
    id = 257,
    shellType = 2,
    restBreakTimes = 999
}

PoisonShell = {
    id = 258,
    shellType = 3,
    restBreakTimes = 0
}

function INIT()
    -- 导入图元
    PlayerLook = Object:load(272, 1, 1)
    ShellLook = Object:load(256, 1, 1)
    BonusLook = Object:load(291, 2, 2)
    -- 对象化图元
    -- !这里实际上Player是MovableObject的引用，通过init包装对象即可，无需赋值
    -- Player = TIC80:init(MovableObject, 10, 10)
    PlayerLook:init(Player, 3 * SpriteSize, 12 * SpriteSize)

    -- for i = 0, 1, 1 do
    --     local shell = {
    --         weight = 100,
    --         type = 1,
    --         HP = 100
    --     }
    --     ShellLook:init(shell, 160 + i * 16, 96)
    --     shell.id = shell.id + i
    --     table.insert(ShellList, shell)
    -- end

    for j = 0, levelCount, 1 do
        ShellLists[j] = {}
    end

    for k = 0, levelCount, 1 do
        BonusLists[k] = {}
    end

    -- 第0关布置
    local Bonus0 = {}
    BonusLook:init(Bonus0, 55, 6)
    table.insert(BonusLists[0], Bonus0)

    -- 第1关布置
    local shell1 = NormalShell
    ShellLook:init(shell1, 16 * 8, 13 * 8)
    table.insert(ShellLists[1], shell1)

    -- 第3关布置
    local shell3 = PoisonShell
    ShellLook:init(shell3, 120, 96)
    table.insert(ShellLists[3], shell3)

    -- 第4关布置
    local Bonus4 = {}
    BonusLook:init(Bonus4, 26 * 8, 14 * 8)
    table.insert(BonusLists[4], Bonus4)

    -- 第10关布置
    local Bonus10 = {}
    BonusLook:init(Bonus10, 25 * 8, 7 * 8)
    table.insert(BonusLists[10], Bonus10)

    -- 第11关布置
    local shell11 = SuperShell
    ShellLook:init(shell11, 120, 96)
    table.insert(ShellLists[11], shell11)
    local Bonus11 = {}
    BonusLook:init(Bonus11, 22 * 8, 1 * 8)
    table.insert(BonusLists[11], Bonus11)

end

function INPUT()
    Player:input()
end

function UPDATE()
    if frame % 10 == 0 then
        for i, sand in pairs(FallingList) do
            Fall(sand.x, sand.y)
            if myMget(sand.x // SpriteSize, sand.y // SpriteSize + 1) == 1 or
                myMget(sand.x // SpriteSize, sand.y // SpriteSize + 1) == 2 then
                table.remove(FallingList, i)
                myMset(sand.x // SpriteSize, sand.y // SpriteSize, 2)
            else
                sand.y = sand.y + SpriteSize
            end
        end
    end

    for i, shell in pairs(ShellLists[getLevel()]) do
        if shell:belowDetection() ~= 1 and shell:belowDetection() ~= 2 then
            if frame % 6 == 0 then
                shell.y = shell.y + SpriteSize
                shell.y = shell.y // 8 * 8
            end
        end
    end
    Player:update()
end

function myMget(x, y)
    return mget(x + mapX, y + mapY)
end

function myMset(x, y, id)
    mset(x + mapX, y + mapY, id)
end

function DRAW()
    -- 绘制地图
    if Player.x > 240 then
        mapX = math.min(mapX + mapWidth, 240)
        if mapX ~= 239 then
            Player.x = Player.x % 240
            Player.homeX = Player.x
            Player.homeY = Player.y
        else
            mapX = 239
            Player.x = 240 - Player:getWidth()
        end
    elseif Player.x < 0 then
        mapX = math.max(mapX - mapWidth, -1)
        if mapX ~= -1 then
            Player.x = Player.x % 240
            Player.homeX = Player.x
            Player.homeY = Player.y
        else
            mapX = 0
            Player.x = 0
            Player.speedX = 0
        end
    elseif Player.y > 136 then
        mapY = math.min(mapY + mapHeight, 136)
        if mapY ~= 135 then
            Player.y = Player.y % 136
            Player.homeX = Player.x
            Player.homeY = Player.y
        else
            mapY = 135
            Player.y = 136 - Player:getHeight()
        end
    elseif Player.y < 0 then
        mapY = math.max(mapY - mapHeight, -1)
        if mapY ~= -1 then
            Player.y = Player.y % 136
            Player.homeX = Player.x
            Player.homeY = Player.y
        else
            mapY = 0
            Player.y = 0
            Player.speedY = 0
        end
    end
    map(mapX, mapY)

    if FallingList ~= nil then
        for i, sand in pairs(FallingList) do
            sand:draw()
        end
    end

    for i, shell in pairs(ShellLists[getLevel()]) do
        shell:draw()
        if collide(Player, shell) then
            print("Press Up", Player.x - 8, Player.y - 8, 2)
        end
    end

    for i, bonus in pairs(BonusLists[getLevel()]) do
        bonus:draw()
        if collide(Player, bonus) then
            music(0, 0, -1, false)
            Player.bonusCount = Player.bonusCount + 1
            table.remove(BonusLists[getLevel()], i)
        end
    end

    Player:draw()
end

function GameOver()
end

INIT()
frame = 0
music(3, 0, -1, false)
function TIC()
    frame = frame + 1
    -- cls()
    INPUT()
    UPDATE()
    DRAW()
    -- print(getLevel(), 10, 50)
    -- print("PLAYER:" .. Player.bonusCount, 10, 110)
    -- print("MAP:" .. mapX .. " " .. mapY, 10, 80)

    if getLevel() == 0 then
        print("#4 Team: XPWD", 132, 20, 3)
        print("Crab Crib", 10, 10, 3, 2, 2)
        print("Fivero: developer", 54, 92, 4)
        print("HUDD: developer", 32, 80, 10)
        print("LR: !FullStack", 76, 104, 13)
    end

    if getLevel() == 1 then
        print("Press Down to dig", 24, 20, 3)
    end

    if getLevel() == 3 then
        print("Press H to back Home", 24, 8, 3)
    end

    if getLevel() == 12 then
        print("Thanks for playing!", 24, 20, 3)
        print("FoundCribs: " .. Player.bonusCount .. "/4", 54, 92, 4)
        print("DeathCount: " .. Player.deathCount, 32, 80, 10)
    end
end

function collide(a, b)
    -- get parameters from a and b
    local ax = a.x
    local ay = a.y
    local aw = a:getWidth()
    local ah = a:getHeight()
    local bx = b.x
    local by = b.y
    local bw = b:getWidth()
    local bh = b:getHeight()

    -- check collision
    if ax < bx + bw and ax + aw > bx and ay < by + bh and ah + ay > by then
        -- collision
        return true
    end
    -- no collision
    return false
end

-- <TILES>
-- 001:eeeeefeeeffeeeeeeeefeeefeeeeeefeeeeefeeeeffeeefefeeeeeefeeeeffee
-- 002:444444444c444c44444c444c444444444c4444c444c4c44444444c4444444444
-- 003:aaaaaaaaabaabaaaabaabaaaab9ab9aaaabaabaaaabaabaaaaaaaaaaaaaaaaaa
-- 004:1111111111611111161611111161111111111611111161611111161111111111
-- 017:ccccccceceeceeceeccccceeeececeeeccccccceecececeeeccceceeeeeeeeee
-- 018:eccccceeeceeeceeeccccceeeceeceeeecccccceecececeeceeccceeeeeeeeee
-- 019:eccecccececceececccecceecececcceeccccceeecececeeccccceceeeeeeeee
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <SPRITES>
-- 000:eeefeeeeeefdfeeeefdfdfeeefdddfeefdfffdfeff00dffef00000fefff00ffe
-- 001:eeeaeeeeeebcbeeeebcbcbeeebcccbeeacbbbcbeab00cbaeb00000bebbb00bbe
-- 002:eee1eeeeee151eeee15151eee15551ee1511151e1100511e1000001e1110011e
-- 003:033333000343233034443233333333333ffffff3333fff330033330000000000
-- 004:3030030333000033002002003332233330222203033223300300003000000000
-- 005:2020000023000000033333300032333300023332000333320030303000303030
-- 016:2e2ee2e222eeee22e2e0fe2eee2222eee222222eee3223ee223333222e2e2e2e
-- 017:22eeee2222eeee22e2e0fe2eee2222eee222222eee3223ee22333322e2e2e2e2
-- 018:8880008800088888808888880000000880808088008080888808800888888888
-- 019:ee33ee33e30e33cc30e333cc3e3300c0e300000030e33303e3ee33e3eeeee3ee
-- 020:33ee33ee3333e03ecc333e030c0033e30000003e30333e033e33ee3eee3eeeee
-- 021:020000001300000013200d0d12000c2c01212333001133330211211101000000
-- 022:0020000000320000023200000012000021200000320000001320000001200000
-- 023:ee2eeeeee2eeeeeee22eeeeee2ee020e22e22222e222222222222222ee222222
-- 024:2000000002000000220000000200000002200000220000002220000020000000
-- 025:2e2ee2e222eeee22e2e0fe2eee2222eee222222eee3223ee223333222e2e2e2e
-- 026:22eeee2222eeee22e2e0fe2eee2222eee222222eee3223ee22333322e2e2e2e2
-- 032:eeefeeeeeefdfeeeefdfdfeeefdddfeefddfddfefdfffdfeffdfdffefddddddf
-- 033:eeeaeeeeeebcbeeeebcbcbeeebcccbeeaccbccbeacbbbcaebbcbcbbebccccccb
-- 034:eee1eeeeee151eeee15151eee15551ee1551551e1511151e1151511e15555551
-- 035:eee00000ee024334e0343342e044224304343342042422430434332204234244
-- 036:0000eeee33430eee242230ee3433440e24243320343422302224244044423430
-- 039:0220000000000000000000000000000000000000000000000000000000000000
-- 040:2200000000000000000000000000000000000000000000000000000000000000
-- 048:fd0f0ddfff2d2fffe22222ee22222222e23332ee22232222e2eee2ee2e2e2e2e
-- 049:bb0c0bbbab2b2baae22222e22222222ee23332ee22232222e2eee2ee2e2e2e2e
-- 050:1501055111252111e22222e22222222ee23332ee22232222e2eee2ee2e2e2e2e
-- 051:0433244303424434e0004424eee04424eee04424eee03432eee02344eeee0000
-- 052:23442330443423403424244022342440444234202223430e444420ee00000eee
-- 064:eeeefeeeeeefdfeeeefdfdfeeefdddfeefddfddfefdfffdfeffdfdfffddddddf
-- 065:eeeeaeeeeeebcbeeeebcbcbeeebcccbeebccbccaeacbbbcaebbcbcbbbccccccb
-- 066:eeee1eeeeee151eeee15151eee15551ee1551551e1511151e115151115555551
-- 080:fd0f0ddfff2d2fff2222222ee22222e22233322ee22322eeee2eee2ee2e2e2e2
-- 081:bbb0c0bbaab2b2ba2e22222ee2222222ee23332e22223222ee2eee2ee2e2e2e2
-- 082:15010551112521112222222ee22222e22233322ee22322eeee2eee2ee2e2e2e2
-- </SPRITES>

-- <MAP>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010100000000000000000000000000000000000000010101010101000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010100000000000000000000000000000000000000010102010101000000000000000000000000000101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010100000000000000000000000000000000000000010101010101000000000000000000000000000101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:202020202020202020202020303030303030303030303030303030303030303030303030100000101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010100000000000000000000000000000000000000010101010101000000000000000000000000000101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:202020202020202020202020303030303030303030303030303030303030303030303030100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010100000000000000000000000101010101000000010102020101000000000000000000000000000101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:202020202020202020202020203030303030303030303030303030303030303030303030100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010100000000000000000000000101010101000000010101020201000000000000000000000000000101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:202020202020202020202020202030303030303030303030303030202020202020202020100000000000000000000010101010100000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010100000000000000000000000101010101000000010101010101000000000000000000010101010101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:202020202020202020202020202030303030303030303030303020202020202020202020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010100000000000000000000000101010101000000010101010101000000000000000000010102020201010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:202020202020202020202020202020303030303030303030303020202020202020101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010100000000000000000000000101010101000000010202010101000000000000000000010201010102010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:202020202020202020202020202020303030303030303030303020202020201010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000010101010101010101000000010101010101000000000000000000010101010201010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000010101010101010101000000010101010101000000000000000000010101020101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:101000000000000000000010101010000000000000000000000000000000000000000000000000101010202020202020202020201010101000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000010101010101010101000000010101010101000000000001010101010101020101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:101000000000000000000000000000000000000000000000000000000000000000000000001010101010202020200020202020201010101010100000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000010101010101010101000000000000000000000000000001010101010101010101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:101000000000000000000000000000000000000020201010202000000000000000000010101010101010202020202020202020201010101010101010101010101010101010101010000000000000000000000010404040401010101000000000000000000000000000000010101010101010101000000000000000000000000000001010101010101020101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010202020202010101010101010101010101010101010101010101010101010000000000010101010404040401010101010101010101010101010101010101010101010101010101000000000000000000000000000001010101010101010101010101000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:101010101010101010101010101010101010101010101010101010101010101010101010101020101010101010202020202010101010102010101010101010101020201010101010000000000000000010101010404040401010101010101010101010101010101010101010101010101010101020202000000000000000000000001010101010101010101010101010102020201010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:000000000000000000000000000000000000000000000000000000000000101010101010102020101010101010000000000010101020101010101010101010101010101010201010000000000000000010101010404040401010101000000000000000000000000000000000000000000000000010101010101010101010101010101010101010101010101010101010102020201010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:000000000000000000000000000000000000000000000000000000000000101020101010102010101010101010000000000010101010101010101010202020101010101010201010000000000010101010101010404040401010101000000000000000000000000020000000000000000000000000101010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:000000000000000000000000000000000000000000000000000000000000101010101010101010101010100000000000000000101010101010101010101010101020101010201010000000000000000010101010404040401010101000000000000000000000002020000000000000000000000000001010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:000000000000000000000000000000000000000000000000000000000000101010101010101010101000000010101010000000000010101010201010101010101020101010101010101010000000000010101010404040401010101000000000000000000000001010000010101010101010000000001010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:000000000000000000000000000000000000000000000000000000000000101020202010101010000000000000000000000000000000001010101010101010101020101010101010000000000000000010101010404040401010101000000000000000000000000000000000000000000000000000001010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:000000000000000000000000000000000000000000000000000000000000101010101010100000000000000000000000000000000000000000101010101010101020201010101010000000000000000010101010404040401010101000000000000000000000000000000000000000000000000000001010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 023:000000000000000000000000000000000000000000000000000000000000101010101000000000000000000000000000101010101010000000000010101010101010202020101010000000000010101010101010202020201010101000000000000000000000000000000000000000000000000000001010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 024:000000000000000000000000000000000000000000000000000000000000101010000000000000000000000000000000000000000000000000000000101010101010101010101010000000000000000010101010200000201010101000000000000000002000000000000000000000000000000000001010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 025:000000000000000000000000000000000000000000000000000000000000100000000000000000000010101010101000000000000000000000000000101010101010101010101010000000000000000010101010200000201010101000000000000000202000000000000000000000000000000000001010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 026:000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000101010101010101010101010101010000000000010101010202020201010101000000000000000101000001010101010101000000000000000001010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 027:000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101000000000000000000000000000000000000000000000000000001010101000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 028:000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 029:000000000000000000000000000000000000000000000000000000000000101000001010000000000000001000101010101010101000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 030:000000000000000000000000000000000000000000000000000000000000100000001010101010101010102010101020101010000010101010101010101010101010101010101010102020202020201010101010101010101010101010000000000000000000000000000000000000000000000000101010101010101000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 031:000000000000000000000000000000000000000000000000000000000000100000101010000000100000101010101010101010101010101010000000101010101010101010101010102020202020201010101010101010101010101010101010000000000000000000000000000000000000101010101010101010101010000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:000000000000000000000000000000000000000000000000000000000000100000101010000000100000100010201010101000102010001010101000101010101010101010101010101020202020101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 033:000000000000000000000000000000000000000000000000000000000000101010101010001010101010101010101000001000100010000000101010101010101010101010101010101020202020101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 050:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:021bbbaa988876554432211aaaabbbb7
-- 001:0123456789abcdeffedcba9876542210
-- 002:0123456789abcdef0123456789abcdef
-- 003:00ffffffffffffff00ffffffffffffff
-- 004:00ffffffffffffff0000000000ffffff
-- 005:0123456789abcdedca86420123453223
-- 006:0000000000000000134567899a000cbb
-- </WAVES>

-- <SFX>
-- 000:030013002300330043005300630073008300830093009300a300a300b300b300c300c300d300d300e300e300f300f300f300f300f300f300f300f300409000000000
-- 001:00403050605080509060a060a070b070b080c090c090c0a0c0a0c0a0c0a0c090c090c080c080c070c060c060c060c060c050c050c050d040e030f030206000000000
-- 002:f6501652e6f31684c6851685c6861636c637063716370693c664066dc66c069bc6da36dac62a4629c6385678c678767e96218623d6d3b6d4e625f626201000000000
-- 003:060046307630963aa600b630b630c630c630c630d600d600d600d600e600e600e600e600e600f600f600f600f600f600f600f600f600f600f600f600204000000000
-- 004:04000400140014002400240034003400440044005400540064006400740074008400840094009400a400a400b400b400c400c400d400d400e400f400204000000000
-- 005:018e019001900190019001900190019f018f018f018f018f018e018e018e018e018e019e019e019e019e01ad01ae01ae019e219e419ea19ee18ef18e000000000000
-- </SFX>

-- <PATTERNS>
-- 000:500008800008c00008d00008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:600006800006c0000ad0000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:400004400004400004400004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:400000700000700000700000900000c00000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:a00000a00000100000b00000a00000100000d00000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:b00004b00014b00014b00014b00014b00014b00014b00014b00014b00014b00014b00014b00014b00014b00014b00014000020000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:600044600044600044600044600044600044600044600044600044600044600044600044600044600044600044600044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:600024600024400024400024600024600024400024400024600065600024400024400024600024600024400024400024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:400024400024700024700024400024400024700024700024400024400024700024700024400024400024700024700024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:400020000020600020000020800020000000a00020000000b00020000000c00020000000d00020000000e00020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:400028000020600028000020800028000000900028000000a00028000000b00028000000c00028000000d00028000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:d00006c00006800006d00006100000c00008800008000000d00008c00008800006d0000a100000c00006800006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:500008900008c00008d00008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:18034300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000023c200
-- 001:6c1842000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:ac2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ab0000
-- 004:441000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

