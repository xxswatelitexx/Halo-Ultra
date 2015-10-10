function init(args)
  self.dead = false
  self.sensors = sensors.create()

  self.state = stateMachine.create({
    "idleState",
    "shootState",
  })
  self.state.leavingState = function(stateName)
    entity.setAnimationState("default", "idle")
    entity.setRunning(false)
  end

  entity.setDamageOnTouch(true)
  entity.setAggressive(true)
  entity.setAnimationState("default", "idle")
end

function main()
  if util.trackTarget(entity.configParameter("shoot.seedShotDistance")) then
    self.state.pickState({ targetId = self.targetId })
  end
  self.state.update(entity.dt())
  self.sensors.clear()
end

function damage(args)
  if entity.health() <= 0 then
    self.state.pickState({ die = true })
  else
    self.state.pickState({ targetId = args.sourceId })
  end
end

--------------------------------------------------------------------------------
idleState = {}

function idleState.enter()
  return { }
end

function idleState.update(dt, stateData)
  entity.setAnimationState("default", "idle")

  return true
end

--------------------------------------------------------------------------------
shootState = {}

function shootState.enterWith(args)
  if args.targetId == nil then return nil end
  
  local targetPosition = world.entityPosition(args.targetId)
  if targetPosition == nil then return nil end

  return {
    targetId = args.targetId,
    targetPosition = targetPosition,
    shotFired = false,
    timer = entity.configParameter("shoot.fireTime"),
    recoilTimer = entity.configParameter("shoot.recoilTime"),
  }
end

function shootState.update(dt, stateData)
  entity.setAnimationState("default", "shoot")

  stateData.timer = stateData.timer - dt
  if stateData.timer <= 0 then
    if not stateData.shotFired then
      local randDir = math.random() * math.pi -- 0 to pi
      local direction = {
        math.cos(randDir),
        math.sin(randDir)
      }
      local oldTid = self.targetId
      self.targetId = nil
      if util.trackTarget(entity.configParameter("shoot.pollenShotDistance")) then
        entity.setFireDirection({0, 0}, direction)
        entity.startFiring("pollen")
      else
        self.targetId = oldTid
        entity.setFireDirection({0, 0}, direction)
        entity.startFiring("seed")
      end
      stateData.shotFired = true
    else
      entity.stopFiring()
    end
    stateData.recoilTimer = stateData.recoilTimer - dt
  end

  if stateData.recoilTimer <= 0 then
    self.targetId = nil
    return true
  end

  return false
end
