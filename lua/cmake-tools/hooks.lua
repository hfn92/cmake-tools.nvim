local M = {
  on_progress = nil,
}

---@class  progress
---@field kind string begin, end
---@field percentage nil|number

---@param prog progress
function M:handle_on_progress(prog)
  if M.on_progress then
    M.on_progress(prog)
  end
end

return M
