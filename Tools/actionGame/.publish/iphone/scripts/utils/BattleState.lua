
local Component = require("framework.cc.components.Component")
local BattleState = class("BattleState", Component)

--[[--

port from Javascript State Machine Library

https://github.com/jakesgordon/javascript-state-machine

JS Version: 2.2.0

]]

BattleState.VERSION = "2.2.0"

-- the event transitioned successfully from one state to another
BattleState.SUCCEEDED = 1
-- the event was successfull but no state transition was necessary
BattleState.NOTRANSITION = 2
-- the event was cancelled by the caller in a beforeEvent callback
BattleState.CANCELLED = 3
-- the event is asynchronous and the caller is in control of when the transition occurs
BattleState.PENDING = 4
-- the event was failure
BattleState.FAILURE = 5

-- caller tried to fire an event that was innapropriate in the current state
BattleState.INVALID_TRANSITION_ERROR = "INVALID_TRANSITION_ERROR"
-- caller tried to fire an event while an async transition was still pending
BattleState.PENDING_TRANSITION_ERROR = "PENDING_TRANSITION_ERROR"
-- caller provided callback function threw an exception
BattleState.INVALID_CALLBACK_ERROR = "INVALID_CALLBACK_ERROR"

BattleState.WILDCARD = "*"
BattleState.ASYNC = "ASYNC"
function BattleState:ctor()
    BattleState.super.ctor(self, "BattleState")
end

function BattleState:setupState(cfg)
    -- assert(type(cfg) == "table", "BattleState:ctor() - invalid config")

    -- cfg.initial allow for a simple string,
    -- or an table with { state = "foo", event = "setup", defer = true|false }
    if type(cfg.initial) == "string" then
        self.initial_ = {state = cfg.initial}
    else
        self.initial_ = clone(cfg.initial)
    end
    -- 支持叠加状态，如何眩晕可以叠加在其他所有状态上面
    self.eventdj_ = ""

    self.terminal_   = cfg.terminal or cfg.final
    self.events_     = cfg.events or {}
    self.callbacks_  = cfg.callbacks or {}
    self.map_        = {}
    self.mapbd_      = {}   
    self.current_    = "none"
    self.inTransition_ = false    
    self.logCount_   = 0 

    if self.initial_ then
        self.initial_.event = self.initial_.event or "startup"
        self:addEvent_({name = self.initial_.event, from = "none", to = self.initial_.state})
    end

    for _, event in ipairs(self.events_) do
        self:addEvent_(event)
    end

    if self.initial_ and not self.initial_.defer then
        self:doEvent(self.initial_.event)
    end

    return self
end

function BattleState:isReady()
    return self.current_ ~= "none"
end

function BattleState:getState()
    return self.current_
end

function BattleState:isState(state)
    if type(state) == "table" then
        for _, s in ipairs(state) do
            if s == self.current_ then return true end
        end
        return false
    else
        return self.current_ == state
    end
end

function BattleState:canDoEvent(eventName)
    return not self.inTransition_
        and (self.map_[eventName][self.current_] ~= nil or self.map_[eventName][BattleState.WILDCARD] ~= nil)
end

function BattleState:cannotDoEvent(eventName)
    return not self:canDoEvent(eventName)
end

function BattleState:isFinishedState()
    return self:isState(self.terminal_)
end

function BattleState:setUpEventdj(eventName)
    self.eventdj_=eventName
end

function BattleState:TransitonEventdj()
    self.eventdj_=""
end

function BattleState:doEventForce(name, ...)    
    local from = self.current_
    local map = self.map_[name]
    local to = (map[from] or map[BattleState.WILDCARD]) or from
    local args = {...}

    local event = {
        name = name,
        from = from,
        to = to,
        args = args,
    }

    if self.inTransition_ then self.inTransition_ = false end
    if self:beforeEvent_(event) == false then
        return BattleState.CANCELLED
    end
    -- 当我普通受击时候使用
    if name=="ptshoujicmd" then
        return 
    end
    -- if from == to then
    --     self:afterEvent_(event)
    --     return BattleState.NOTRANSITION
    -- end

    self.current_ = to
    self:enterState_(event)
    self:changeState_(event)
    self:afterEvent_(event)
    return BattleState.SUCCEEDED
end

function BattleState:doEvent(name, ...)
    -- assert(self.map_[name] ~= nil, string.format("BattleState:doEvent() - invalid event %s", tostring(name)))
    local from = self.current_
    local map = self.map_[name]
    local to = (map[from] or map[BattleState.WILDCARD]) or from
    local args = {...}

    local event = {
        name = name,
        from = from,
        to = to,
        args = args,
    }
    -- 当有叠加状态时候，只有当时被动事件时候可以迁移状态
    if self.eventdj_ ~="" and self.mapbd_[name]== nil then
        self:onError_(event,
                      BattleState.INVALID_TRANSITION_ERROR,
                      "eventdj transition did not complete")
        return BattleState.FAILURE
    end

    if self.inTransition_ then
        -- self:onError_(event,
        --               BattleState.PENDING_TRANSITION_ERROR,
        --               "event " .. name .. " inappropriate because previous transition did not complete")
        return BattleState.FAILURE
    end

    if self:cannotDoEvent(name) then
        self:onError_(event,
                      BattleState.INVALID_TRANSITION_ERROR,
                      "event " .. name .. " inappropriate in current state " .. self.current_)
        return BattleState.FAILURE
    end

    if self:beforeEvent_(event) == false then
        return BattleState.CANCELLED
    end
    -- 当我普通受击时候使用
    if name=="ptshoujicmd" then
        return 
    end
    if from == to then
        self:afterEvent_(event)
        return BattleState.NOTRANSITION
    end

    event.transition = function()
        self.inTransition_  = false
        self.current_ = to -- this method should only ever be called once
        self:enterState_(event)
        self:changeState_(event)
        self:afterEvent_(event)
        return BattleState.SUCCEEDED
    end

    event.cancel = function()
        -- provide a way for caller to cancel async transition if desired
        event.transition = nil
        self:afterEvent_(event)
    end

    self.inTransition_ = true
    local leave = self:leaveState_(event)
    if leave == false then
        event.transition = nil
        event.cancel = nil
        self.inTransition_ = false
        return BattleState.CANCELLED
    elseif string.upper(tostring(leave)) == BattleState.ASYNC then
        return BattleState.PENDING
    else
        -- need to check in case user manually called transition()
        -- but forgot to return BattleState.ASYNC
        if event.transition then
            return event.transition()
        else
            self.inTransition_ = false
        end
    end
end

function BattleState:exportMethods()
    self:exportMethods_({
        "setupState",
        "isReady",
        "getState",
        "isState",
        "canDoEvent",
        "cannotDoEvent",
        "isFinishedState",
        "doEventForce",
        "doEvent",
    })
    return self
end

function BattleState:onBind_()
end

function BattleState:onUnbind_()
end

function BattleState:addEvent_(event)
    local from = {}
    if type(event.from) == "table" then
        for _, name in ipairs(event.from) do
            from[name] = true
        end
    elseif event.from then
        from[event.from] = true
    else
        -- allow "wildcard" transition if "from" is not specified
        from[BattleState.WILDCARD] = true
    end
    self.mapbd_[event.name]=event.bdevent or nil
    self.map_[event.name] = self.map_[event.name] or {}
    local map = self.map_[event.name]
    for fromName, _ in pairs(from) do
        map[fromName] = event.to or fromName
    end
end

local function doCallback_(callback, event)
    if callback then return callback(event) end
end

function BattleState:beforeAnyEvent_(event)
    return doCallback_(self.callbacks_["onbeforeevent"], event)
end

function BattleState:afterAnyEvent_(event)
    return doCallback_(self.callbacks_["onafterevent"] or self.callbacks_["onevent"], event)
end

function BattleState:leaveAnyState_(event)
    return doCallback_(self.callbacks_["onleavestate"], event)
end

function BattleState:enterAnyState_(event)
    return doCallback_(self.callbacks_["onenterstate"] or self.callbacks_["onstate"], event)
end

function BattleState:changeState_(event)
    return doCallback_(self.callbacks_["onchangestate"], event)
end

function BattleState:beforeThisEvent_(event)
    return doCallback_(self.callbacks_["onbefore" .. event.name], event)
end

function BattleState:afterThisEvent_(event)
    return doCallback_(self.callbacks_["onafter" .. event.name] or self.callbacks_["on" .. event.name], event)
end

function BattleState:leaveThisState_(event)
    return doCallback_(self.callbacks_["onleave" .. event.from], event)
end

function BattleState:enterThisState_(event)
    return doCallback_(self.callbacks_["onenter" .. event.to] or self.callbacks_["on" .. event.to], event)
end

function BattleState:beforeEvent_(event)
    if self:beforeThisEvent_(event) == false or self:beforeAnyEvent_(event) == false then
        return false
    end
end

function BattleState:afterEvent_(event)
    self:afterThisEvent_(event)
    self:afterAnyEvent_(event)
end

function BattleState:leaveState_(event, transition)
    local specific = self:leaveThisState_(event, transition)
    local general = self:leaveAnyState_(event, transition)
    if specific == false or general == false then
        return false
    elseif string.upper(tostring(specific)) == BattleState.ASYNC
        or string.upper(tostring(general)) == BattleState.ASYNC then
        return BattleState.ASYNC
    end
end

function BattleState:enterState_(event)
    self:enterThisState_(event)
    self:enterAnyState_(event)
end

function BattleState:onError_(event, error, message)
    printf("ERROR: error %s, event %s, from %s to %s", tostring(error), event.name, event.from, event.to)
    -- echoError(message)
end

return BattleState
