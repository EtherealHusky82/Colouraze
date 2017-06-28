--this class spawns random numbers 
local class = {}

function class.generateRandNum (max, amt_to_generate)
  math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,10)) )
	local randDecNum, randNum
  local randNumTbl = {}
  local oldrandom = math.random 
  local randomtable
  math.random = function ()

      if randomtable == nil then
        randomtable = {}
        for i = 1, 97 do
        	randomtable[i] = oldrandom() 
        end
      end
  local x = oldrandom() 
  local i = 1 + math.floor(97*x)
  x, randomtable[i] = randomtable[i], x
  return x
  end

  for i = 1, amt_to_generate do
    randDecNum = math.random ()
    randNum = math.ceil(randDecNum*max)
    randNumTbl[#randNumTbl+1] = randNum
  end
  
  return randNumTbl
end
return class